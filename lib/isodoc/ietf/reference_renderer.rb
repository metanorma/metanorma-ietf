require "sterile"

module IsoDoc
  module Ietf
    #
    # Renders a semantic bibitem as the RFC XML v3 content of a <reference>
    # element: an optional <stream>, a <front> (title, authors, date,
    # keywords, abstract), <seriesInfo> for the DOI and each authoritative
    # identifier (or a <refcontent> summary for non-IETF documents), and a
    # <ref-included> wrapper per `includes` relation.
    #
    # This is the native replacement for the relaton-render liquid stack
    # this gem carried under lib/relaton/render: that stack subclassed
    # relaton-render 1.x internals (Parse/Fields/Date/Template::Name) that
    # the 1.4 engine no longer exposes, and its output was never an ISO 690
    # citation string but RFC XML structures, so it has no place in the
    # CitationStyle rendering architecture. The field semantics below are
    # those of the old stack, reimplemented over the bibitem XML:
    #
    # * docidentifier contents arrive already type-prefixed by
    #   References#bibliography_prep (isodoc docid_prefix); the rfc-anchor
    #   and I-D. filters rely on that prefix
    # * the cleanme markers on <date>/<abstract> are consumed by
    #   Cleanup#biblio_date_cleanup and #biblio_abstract_cleanup
    # * a person with a surname but no initials renders no author at all
    #   (the old template's empty variable was stripped wholesale)
    # * at most three authors render (the old name template's cap)
    # * included documents render no sub-series <seriesInfo>: the old
    #   template referenced the outer document's series inside ref-included
    #   by accident, and no output ever carried it
    class ReferenceRenderer
      XML2RFC_STREAMS = {
        "iab" => "IAB", "ietf" => "IETF", "irtf" => "IRTF",
        "independent" => "independent",
        "independent submission" => "independent"
      }.freeze

      HOME_PUBLISHERS = ["Internet Engineering Task Force", "IETF",
                         "RFC Publisher"].freeze

      CREATOR_ROLE_ORDER = %w(author performer adapter translator editor
                              publisher distributor authorizer).freeze

      # roles that never surface as an author/@role attribute
      ROLE_ATTR_SUPPRESSED = %w(author publisher distributor authorizer).freeze

      EXCLUDED_ID_TYPES = %w(METANORMA METANORMA-ORDINAL AUTHOR-DATE TITLE
                             URN ISO-REFERENCE ISSN ISBN DOI).freeze

      def initialize(language: "en")
        @lang = language
      end

      # @param bib [Nokogiri::XML::Element] semantic bibitem, post
      #   bibitem_render_prep: namespace stripped, docid_prefix applied
      # @return [String] RFC XML fragment
      def render(node)
        bib = namespace_stripped(node)
        home = home_standard?(bib)
        frag = Nokogiri::XML::DocumentFragment.parse("")
        stream(frag, bib)
        front(frag, bib)
        doi_series_info(frag, bib)
        home ? id_series_info(frag, bib) : refcontent(frag, bib)
        included(frag, bib, home)
        frag.to_xml
      end

      private

      # the semantic bibitem carries the document's default namespace;
      # query it as plain elements
      def namespace_stripped(node)
        doc = Nokogiri::XML(node.to_xml)
        doc.remove_namespaces!
        doc.root
      end

      def el(parent, name, text = nil, **attrs)
        e = parent.document.create_element(name.to_s)
        attrs.each { |k, v| e[k.to_s] = v unless v.nil? || v.to_s.empty? }
        e << parent.document.create_text_node(text) if text
        parent << e
        e
      end

      def text_of(node)
        return nil if node.nil?

        node.text.gsub(/\s*\n\s*/, " ").strip
      end

      # An Internet-Draft is an IETF-stream document even though its relaton
      # record carries no publisher contributor; without the docidentifier
      # clause, draft references fell to the refcontent branch and never got
      # the seriesInfo that makes xml2rfc render "Work in Progress,
      # Internet-Draft, ..." (#283)
      def home_standard?(bib)
        bib.xpath("./contributor[role/@type = 'publisher']/organization")
          .any? { |o| HOME_PUBLISHERS.include?(text_of(o.at("./name"))) } ||
          bib.xpath("./docidentifier[@type = 'Internet-Draft']").any?
      end

      def stream(frag, bib)
        s = bib.xpath("./series").detect { |x| x["type"] == "stream" } or
          return
        t = text_of(s.at("./title")) or return
        # values outside the xml2rfc enumeration (Legacy et al.) are omitted
        # rather than emitted verbatim, which was fatal to xml2rfc (#270)
        v = XML2RFC_STREAMS[t.downcase] or return
        el(frag, :stream, v)
      end

      def front(frag, bib)
        f = el(frag, :front)
        el(f, :title, title(bib)) if title(bib)
        authors(f, bib)
        d = date_string(bib)
        el(f, :date, d, cleanme: "true") if d
        bib.xpath("./keyword").each do |k|
          kw = keyword(k) and el(f, :keyword, kw)
        end
        ab = text_of(bib.at("./abstract"))
        el(f, :abstract, ab, cleanme: "true") unless ab.nil? || ab.empty?
      end

      def title(bib)
        titles = bib.xpath("./title")
        t = titles.select { |x| x["language"] == @lang }
        t = titles if t.empty?
        t1 = t.select { |x| x["type"] == "main" }
        t1 = t if t1.empty?
        text_of(t1.first)
      end

      # authors and editors together, in DOCUMENT order: concatenating all
      # authors then all editors re-ordered mixed lists, and organisational
      # authors were hoisted over persons (#284)
      def creators(bib)
        cr = bib.xpath("./contributor").select do |c|
          roles(c).any? { |r| %w(author editor).include?(r) }
        end
        return cr unless cr.empty?

        contributors = bib.xpath("./contributor")
        CREATOR_ROLE_ORDER.each do |r|
          bucket = contributors.select { |c| roles(c).include?(r) }
          return bucket unless bucket.empty?
        end
        []
      end

      def roles(contributor)
        contributor.xpath("./role").filter_map { |r| r["type"] }
      end

      def authors(front, bib)
        cr = creators(bib)
        cr.first(3).each { |c| author(front, c, role_attr(cr)) }
        cr
      end

      def role_attr(creators)
        r = roles(creators.first)&.first
        r unless ROLE_ATTR_SUPPRESSED.include?(r)
      end

      def author(parent, contributor, role)
        org = contributor.at("./organization")
        person = contributor.at("./person")
        if org
          name = text_of(org.at("./name"))
          name or return # an abbreviation-only organization renders no author
          a = el(parent, :author)
          el(a, :organization, name, ascii: ascii_or_nil(name),
                                          abbrev: text_of(org.at("./abbreviation")))
        elsif person
          person_author(parent, person, role)
        end
      end

      def person_author(parent, person, role)
        surname = text_of(person.at("./name/surname"))
        if surname
          initials = person_initials(person)
          initials.empty? and return
          el(parent, :author, nil, surname: surname,
                                      asciiSurname: ascii_or_nil(surname),
                                      initials: initials.join,
                                      asciiInitials: ascii_or_nil(initials.join),
                                      role: role)
        else
          cn = text_of(person.at("./name/completename")) or return
          el(parent, :author, nil, fullname: cn,
                                      asciiFullname: ascii_or_nil(cn),
                                      role: role)
        end
      end

      def person_initials(person)
        fi = text_of(person.at("./name/formatted-initials"))
        if fi
          return fi.sub(/(.)\.?$/, '\1.').split(/(?<=\.) /)
        end

        forenames = person.xpath("./name/forename")
        ini = forenames.filter_map do |f|
          f["initial"]&.sub(/(.)\.?$/, '\1.')
        end
        return ini unless ini.empty?

        forenames.filter_map { |f| text_of(f) }
          .flat_map { |t| t.split(" ") }
          .map { |w| "#{w[0]}." }
      end

      # nil when the transliteration is redundant, so downstream consumers
      # inherit already-clean output: xml2rfc strips self-equal ascii
      # attributes with a warning (#269)
      def ascii_or_nil(str)
        return nil if str.nil?

        a = Sterile.transliterate(str)
        a == str ? nil : a
      end

      def date_string(bib)
        d = pick_date(bib) or return nil
        on = text_of(d.at("./on"))
        return on if on

        from = text_of(d.at("./from")) or return nil
        to = text_of(d.at("./to"))
        to.nil? || to == from ? from : "#{from}–#{to}"
      end

      def pick_date(bib)
        dates = bib.xpath("./date")
        %w(published issued circulated).each do |t|
          d = dates.detect { |x| x["type"] == t } and return d
        end
        dates.reject { |x| x["type"] == "accessed" }.first
      end

      def keyword(k)
        v = k.at("./vocab") and return text_of(v)
        t = k.at("./taxon") and return text_of(t)
        k.at("./vocabid")&.[]("term")
      end

      def doi_series_info(frag, bib)
        bib.xpath("./docidentifier").each do |id|
          id["type"]&.match?(/\ADOI(\..*)?\z/i) or next
          v = text_of(id).sub(/\ADOI\b\s*/, "")
          v.empty? and next
          el(frag, :seriesInfo, nil, value: v, name: "DOI")
        end
      end

      def id_series_info(frag, bib)
        authoritative_ids(bib).each do |id|
          tokens = id.tr("\u00A0", " ").split(" ")
          if id.include?("I-D.")
            value = tokens.last.sub("I-D.", "")
            name = "Internet-Draft"
          else
            value = tokens.last
            name = tokens[-2]
          end
          name or next # an underivable name dropped the whole seriesInfo
          el(frag, :seriesInfo, nil, value: value, name: name)
        end
      end

      def refcontent(frag, bib)
        ids = authoritative_ids(bib)
        ids.empty? and return
        # non-breaking spaces inside identifiers, per RFC XML typography
        el(frag, :refcontent, ids.map { |i| i.tr(" ", "\u00A0") }.join(", "))
      end

      def authoritative_ids(bib)
        ids = id_scope_filter(bib.xpath("./docidentifier"))
        out = nil
        [
          ->(x) { x["language"] == @lang && x["primary"] },
          ->(x) { x["primary"] },
          ->(x) { x["language"] == @lang },
          ->(_x) { true },
        ].each do |p|
          out = ids.select do |x|
            p.call(x) && !EXCLUDED_ID_TYPES.include?(id_type_norm(x))
          end
          out.empty? or break
        end
        contents = out.map { |x| text_of(x) }
        bcp = bib.xpath("./series").detect do |s|
          %w(BCP STD).include?(series_title(s))
        end
        # label the sub-series by its own title: the unconditional "BCP"
        # prefix rendered every STD-series RFC as BCP (STD 63 -> "BCP 63",
        # #282)
        bcp and contents.unshift(
          "#{series_title(bcp)}\u00A0#{text_of(bcp.at('./number'))}",
        )
        # Internet-Draft identifiers stay: rejecting them left draft
        # references with no seriesInfo, so xml2rfc never rendered "Work in
        # Progress, Internet-Draft, draft-name" (#283). Only the unversioned
        # duplicate of the primary id is dropped, along with the rfc-anchor
        # and I-D. anchor forms.
        primary = contents.grep(/Internet-Draft/).max_by(&:length)
        contents.reject do |x|
          /rfc-anchor/.match?(x) ||
            (/Internet-Draft/.match?(x) && x != primary) ||
            (primary && /I-D\./.match?(x))
        end
      end

      def id_type_norm(id)
        t = id["type"] or return nil
        m = /\A(ISBN|ISSN)\..*/i.match(t) or return t.upcase
        m[1].upcase
      end

      # scoped identifiers (biblio-tag duplicates, IEEE trademark ids) lose
      # to scope-less ones within their type group
      def id_scope_filter(ids)
        ids.detect { |i| i["scope"] } or return ids
        ids.group_by { |i| i["type"] }.flat_map do |type, group|
          grouped = group.group_by { |i| i["scope"] }
          if type == "IEEE" then grouped["trademark"] || grouped[nil] || []
          else grouped[nil] || []
          end
        end
      end

      def series_title(series)
        text_of(series.at("./title"))
      end

      def included(frag, bib, home)
        bib.xpath("./relation[@type = 'includes']/bibitem").each do |sub|
          r = el(frag, :"ref-included", nil,
                 target: text_of(sub.at("./uri")))
          stream(r, sub)
          f = el(r, :front)
          el(f, :title, title(sub) || "[TITLE]")
          creators(sub).empty? and el(f, :author)
          authors(f, sub)
          d = date_string(sub)
          el(f, :date, d, cleanme: "true") if d
          sub.xpath("./keyword").each do |k|
            kw = keyword(k) and el(f, :keyword, kw)
          end
          ab = text_of(sub.at("./abstract"))
          el(f, :abstract, ab, cleanme: "true") unless ab.nil? || ab.empty?
          doi_series_info(r, sub)
          home ? id_series_info(r, sub) : refcontent(r, sub)
        end
      end
    end
  end
end
