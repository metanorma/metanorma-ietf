module Relaton
  module Render
    module Ietf
      class Parse < ::Relaton::Render::Parse
        def initialize(options)
          super
          @fieldsklass = Relaton::Render::Ietf::Fields
        end

        def simple_or_host_xml2hash(doc, host)
          ret = super
          ret.merge(home_standard: home_standard(doc, ret[:publisher_raw]),
                    uris: uris(doc), keywords: keywords(doc),
                    abstract: abstract(doc))
        end

        def home_standard(doc, pubs)
          pubs&.any? do |r|
            ["Internet Engineering Task Force", "IETF", "RFC Publisher"]
              .include?(r[:nonpersonal])
          end ||
            # an Internet-Draft is an IETF-stream document even though
            # its relaton record carries no publisher contributor;
            # without this, draft references fell to the refcontent
            # branch and never got the seriesInfo that makes xml2rfc
            # render "Work in Progress, Internet-Draft, ..." (#283)
            Array(doc.docidentifier)
              .any? { |i| i.type == "Internet-Draft" }
        end

        # allow publisher for standards
        def creatornames_roles_allowed
          %w(author performer adapter translator editor publisher distributor
             authorizer)
        end

        def series_xml2hash1(series, doc)
          ret = super
          plain_title = ret[:series_title]&.gsub(/<\/?esc>/, "")
          %w(BCP RFC I-D. Internet-Draft).include?(plain_title) and return {}
          ret
        end

        def uris(doc)
          Array(doc.source).map do |u|
            { content: u.content.to_s.strip, type: u.type }
          end
        end

        def keywords(doc)
          Array(doc.keyword).map { |u| keyword1(u) }.compact
        end

        def keyword1(kw)
          v = Array(kw.vocab).first
          v and return content(v)
          t = Array(kw.taxon).first
          t and return content(t)
          kw.vocabid&.term
        end

        def abstract(doc)
          Array(doc.abstract).map { |a| abstract_content(a) }.join
        end

        def abstract_content(abstract_node)
          raw = abstract_node.content
          return content(abstract_node) if raw.nil? || raw.strip.empty?

          raw_stripped = raw.strip
          if raw_stripped.include?("<p")
            raw_stripped
          else
            content(abstract_node)
          end
        end

        def extractname(contributor)
          org = contributor.organization
          person = contributor.person
          if org
            name = extract_orgname(org)
            return { nonpersonal: name,
                     nonpersonalascii: ascii_or_nil(name),
                     nonpersonalabbrev: extract_orgabbrev(org) }
          end
          return extract_personname(person) if person

          nil
        end

        def extract_orgabbrev(org)
          content(org.abbreviation)
        end

        # The ascii attributes are computed here, nil when the
        # transliteration is redundant, so the nametemplates emit them
        # through a bare presence check, and downstream consumers (incl.
        # the presentation XML transformer) inherit already-clean output:
        # xml2rfc strips self-equal ascii attributes with a warning (#269)
        def ascii_or_nil(str)
          str.nil? and return nil
          a = str.transliterate
          a == str ? nil : a
        end

        def extract_personname(person)
          sn = content(person.name.surname)
          cn = content(person.name.completename)
          given, middle, initials = given_and_middle_name(person)
          { surname: sn, completename: cn,
            given: given, middle: middle, initials: initials,
            surnameascii: ascii_or_nil(sn),
            completenameascii: ascii_or_nil(cn),
            initialsascii: ascii_or_nil(Array(initials).join) }.compact
        end

        # not just year-only
        def date(doc, host)
          ret = date1(Array(doc.date))
          host and ret ||= date1(Array(host.date))
          datepick(ret)
        end

        # return authors and editors together, in DOCUMENT order:
        # concatenating all authors then all editors re-ordered mixed
        # lists — RFC 5234 (data order Crocker (ed.), Overell)
        # rendered as "Overell, P. and D. Crocker", and organisational
        # authors were hoisted over persons (#284)
        def creatornames1(doc)
          return [] if doc.nil?

          cr = Array(doc.contributor).select do |c|
            Array(c.role).any? { |r| %w(author editor).include?(r.type) }
          end
          cr.empty? or return cr
          super
        end

        def authoritative_identifier(doc)
          ret = super
          bcp = Array(doc.series).detect do |s|
            %w(BCP STD).include?(Array(s.title).first&.content)
          end
          # label the sub-series by its own title: the unconditional
          # "BCP" prefix rendered every STD-series RFC as BCP
          # (STD 63 -> "BCP 63", #282)
          bcp and ret.unshift(
            "#{Array(bcp.title).first&.content}\u00A0#{bcp.number}",
          )
          # Internet-Draft identifiers stay: rejecting them (as the
          # rfc-anchor internals rightly are) left draft references
          # with NO seriesInfo, so xml2rfc never rendered "Work in
          # Progress, Internet-Draft, draft-name" (#283). Only the
          # unversioned duplicate of the primary id is dropped.
          primary = ret.grep(/Internet-Draft/).max_by(&:length)
          ret.reject do |x|
            /rfc-anchor/.match?(x) ||
              (/Internet-Draft/.match?(x) && x != primary) ||
              # the I-D. anchor form duplicates the real draft name
              # with an unprefixed, unversioned value — drop it when
              # a proper Internet-Draft identifier is present
              (primary && /I-D\./.match?(x))
          end
            .map { |x| x.gsub(/<\/?esc>/, "").tr(" ", "\u00A0") }
        end

        def simple_xml2hash(doc)
          super.merge(stream: stream(doc))
        end

        def series(doc)
          a = Array(doc.series).reject { |s| s.type == "stream" }
          a.empty? and return nil
          a.detect { |s| s.type == "main" } ||
            a.detect { |s| s.type.nil? } || a.first
        end

        # the enumeration <stream> admits per v3.rng, keyed by downcased
        # relaton stream title
        XML2RFC_STREAMS = {
          "iab" => "IAB", "ietf" => "IETF", "irtf" => "IRTF",
          "independent" => "independent",
          "independent submission" => "independent"
        }.freeze

        # Normalise the stream to the xml2rfc enumeration; values outside
        # it (Legacy et al.) are omitted rather than emitted verbatim,
        # which was fatal to xml2rfc (INDEPENDENT, #270)
        def stream(doc)
          a = Array(doc.series).detect { |s| s.type == "stream" } or return nil
          t = Array(a.title).first&.content or return nil
          XML2RFC_STREAMS[t.downcase]
        end

        def extract(doc)
          super.merge(included_xml2hash(doc))
        end

        def included_xml2hash(doc)
          r = Array(doc.relation).select { |x| x.type == "includes" }.map do |x|
            parse_single_bibitem(x.bibitem)
          end
          r.empty? and return {}
          { included: r }
        end

        def parse_single_bibitem(doc)
          extract(doc)
          # enhance_data(data, r.template_raw)
          # data_liquid = @fieldsklass.new(renderer: self)
          #  .compound_fields_format(data)
        end
      end
    end
  end
end
