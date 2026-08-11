# frozen_string_literal: true

require "cgi"

module Metanorma
  module Ietf
    module Transformer
      module ReferenceTransformer

        # A clause that carries <references> children renders as a
        # back-matter references GROUP — <references> with a name and
        # nested <references> — since RFC XML v3 admits references
        # only in <back> (WS3, section_spec; the released path makes
        # the same relocation)
        def transform_references_group(clause_node)
          group = Rfcxml::V3::References.new
          group.anchor = to_ncname(anchor_for(clause_node)) if anchor_for(clause_node)

          title = model_attr(clause_node, :title)
          if title
            name = Rfcxml::V3::Name.new
            name_text = ls_text(title)
            name.content = [name_text] if name_text && !name_text.empty?
            group.name = name unless name.content.nil? || name.content.empty?
          end

          to_array(model_attr(clause_node, :references)).each do |refs|
            child = transform_references_section(refs)
            safe_append(group, :references, child) if child
          end

          sub = model_attr(clause_node, :clause) || model_attr(clause_node, :subsection)
          to_array(sub).each do |c|
            next unless clause_has_references?(c)

            child = transform_references_group(c)
            safe_append(group, :references, child) if child
          end

          group
        end

        def clause_has_references?(clause_node)
          !to_array(model_attr(clause_node, :references)).empty? ||
            to_array(model_attr(clause_node, :clause) ||
                     model_attr(clause_node, :subsection))
              .any? { |c| clause_has_references?(c) }
        end

        def transform_references_section(refs_node)
          references = Rfcxml::V3::References.new
          references.anchor = to_ncname(anchor_for(refs_node)) if anchor_for(refs_node)

          title = refs_node.title
          if title
            name = Rfcxml::V3::Name.new
            name_text = ls_text(title)
            name.content = [name_text] if name_text && !name_text.empty?
            references.name = name unless name.content.nil? || name.content.empty?
          end

          src_order = refs_node.element_order
          bibitems = to_array(refs_node.references)
          bibitem_queue = bibitems.dup

          passthroughs = to_array(refs_node.passthrough)
          pass_queue = passthroughs.dup

          if src_order && src_order.any?
            src_order.each do |e|
              next if e.text?
              case e.element_tag
              when "passthrough"
                pass_model = pass_queue.shift
                raw_ref = extract_passthrough_reference(pass_model) if pass_model
                safe_append(references, :reference, raw_ref) if raw_ref
              when "bibitem"
                bib = bibitem_queue.shift
                # hidden bibitems are excluded here too (#301: the
                # check lived only in the no-order fallback branch,
                # and the ordered branch is the one 0.2.9 takes)
                next if hidden_bibitem?(bib)

                append_reference(references, transform_bibitem(bib))
              end
            end
          else
            pass_queue.each do |pass_model|
              raw_ref = extract_passthrough_reference(pass_model)
              safe_append(references, :reference, raw_ref) if raw_ref
            end
            bibitem_queue.each do |bibitem|
              next unless bibitem
              next if hidden_bibitem?(bibitem)
              append_reference(references, transform_bibitem(bibitem))
            end
          end

          references
        end

        # a group bibitem transforms to Referencegroup, which must
        # ride its own collection — appended under :reference, the
        # Reference serialisation rules get applied to it and crash
        def append_reference(references, ref)
          return unless ref

          attr = ref.is_a?(Rfcxml::V3::Referencegroup) ? :referencegroup : :reference
          safe_append(references, attr, ref)
        end

        def hidden_bibitem?(bibitem)
          return false unless bibitem

          hidden = model_attr(bibitem, :hidden)
          # bibitem@hidden is parse-ghosted on the 0.2.9 model; the F5
          # side-channel recovers it per element id (#301)
          if hidden.nil? && doc.respond_to?(:recovered_section_attrs)
            key = anchor_for(bibitem)
            key = key && to_ncname(key)
            hidden = key && doc.recovered_section_attrs[key]&.fetch("hidden", nil)
          end
          hidden == "true" || hidden == true
        end

        def extract_passthrough_reference(pass_model)
          content = pass_model.content
          return nil if content.nil? || content.strip.empty?

          content = CGI.unescapeHTML(content)

          begin
            ref = Rfcxml::V3::Reference.from_xml(content)
            return ref if ref
          rescue StandardError
            nil
          end

          nil
        end

        def transform_bibitem(bibitem)
          return nil unless bibitem

          if reference_group?(bibitem)
            return transform_referencegroup(bibitem)
          end

          if formattedref_bibitem?(bibitem)
            return transform_formattedref_bibitem(bibitem)
          end

          ref = Rfcxml::V3::Reference.new

          ref.anchor = bibitem_anchor(bibitem)

          target = extract_bibitem_target(bibitem)
          ref.target = target if target && !target.empty?

          front = Rfcxml::V3::Front.new

          title = extract_bibitem_title(bibitem)
          if title && !title.empty?
            t = Rfcxml::V3::Title.new
            t.content = [title]
            front.title = t
          end

          authors = extract_bibitem_authors(bibitem)
          # RFC XML requires at least one author per reference front; the
          # released path completes author-less references with a
          # placeholder in front_cleanup (campaign finding N3, the
          # schema-required fallback). Same completion at build time here.
          if authors.nil? || authors.empty?
            placeholder = Rfcxml::V3::Author.new
            placeholder.surname = "Unknown"
            authors = [placeholder]
          end
          front.author = authors

          date = extract_bibitem_date(bibitem)
          front.date = date if date

          keywords = extract_bibitem_keywords(bibitem)
          front.keyword = keywords unless keywords.empty?

          abstract = extract_bibitem_abstract(bibitem)
          front.abstract = abstract if abstract

          ref.front = front

          stream = extract_bibitem_stream(bibitem)
          ref.stream = stream if stream

          refcontent_text = extract_bibitem_refcontent(bibitem)
          if refcontent_text && !refcontent_text.empty?
            rc = Rfcxml::V3::Refcontent.new
            rc.content = [refcontent_text]
            safe_append(ref, :refcontent, rc)
          end

          series_infos = extract_bibitem_series_info(bibitem)
          series_infos.each { |si| safe_append(ref, :series_info, si) }

          annotation_text = extract_bibitem_annotation(bibitem)
          if annotation_text && !annotation_text.empty?
            ann = Rfcxml::V3::Annotation.new
            ann.content = annotation_text
            safe_append(ref, :annotation, ann)
          end

          ref
        end

        # relation type="includes" is the ONLY constituent carrier the
        # model has — the former :constituent probes were dead guards
        # (#301); re-add a branch only if a model vintage grows one
        def reference_group?(bibitem)
          return false unless bibitem

          included_bibitems(bibitem).any?
        end

        # <relation type="includes"> is how a referencegroup carries
        # its constituents (STD umbrella + member RFCs); the model
        # parses each as a full nested bibitem (WS3 ref_spec — the
        # constituent-accessor branch below never fires on this
        # vintage)
        def included_bibitems(bibitem)
          to_array(model_attr(bibitem, :relation))
            .select { |r| r && r.type == "includes" }
            .filter_map { |r| model_attr(r, :bibitem) }
        end

        def transform_referencegroup(bibitem)
          group = Rfcxml::V3::Referencegroup.new
          group.anchor = bibitem_anchor(bibitem)

          target = extract_bibitem_target(bibitem)
          group.target = target if target && !target.empty?

          # constituents are complete bibitems: render each through
          # the full reference pipeline (front, date, abstract,
          # keywords, seriesInfo, stream), as the released path does;
          # their anchors fall out of bibitem_anchor's IETF-docid
          # fallback ("RFC 5730" -> RFC5730)
          included_bibitems(bibitem).each do |constituent|
            ref = transform_bibitem(constituent)
            safe_append(group, :reference, ref) if ref
          end

          group
        end

        # a formattedref is the FULL rendered citation — the human- or
        # (almost always) relaton-render-formatted text that populates
        # the v3 reference; a bare title does not. It therefore wins
        # over a co-present title (#301 item 6, adjudicated 2026-08-11:
        # restores the released #279 precedence; the fetched-title-wins
        # flip discarded the authored/rendered citation). Bibitems with
        # NEITHER also route here, for the docid fallback.
        def formattedref_bibitem?(bibitem)
          return false unless bibitem

          fr = model_attr(bibitem, :formatted_ref)
          return true if fr && !mixed_text(fr).to_s.strip.empty?
          return true if recovered_formattedref_for(bibitem)

          title = extract_bibitem_title(bibitem)
          title.nil? || title.empty?
        end

        # the authored formattedref captured from the PRE-presentation
        # semantic XML (Transformer.recover_formattedrefs — the shared
        # bibrender replaces it in presentation whenever a title
        # coexists)
        def recovered_formattedref_for(bibitem)
          return nil unless bibitem &&
            doc.respond_to?(:recovered_formattedrefs)

          [model_attr(bibitem, :anchor), model_attr(bibitem, :id)]
            .each do |k|
            next if k.nil? || k.to_s.strip.empty?

            hit = doc.recovered_formattedrefs[to_ncname(k)]
            return hit if hit
          end
          nil
        end

        def transform_formattedref_bibitem(bibitem)
          ref = Rfcxml::V3::Reference.new
          ref.anchor = bibitem_anchor(bibitem)

          target = extract_bibitem_target(bibitem)
          ref.target = target if target && !target.empty?

          front = Rfcxml::V3::Front.new

          formatted = bibitem.formatted_ref
          title_text = formatted ? mixed_text(formatted) : nil
          title_text = nil if title_text&.strip&.empty?
          # the authored formattedref, when presentation clobbered it
          # (#301 item 6) — it renders as the reference title, the
          # released RfcConvert shape
          title_text ||= recovered_formattedref_for(bibitem)
          # No formattedref either: fall back to the authoritative
          # docidentifier. RFC XML requires front/title, and leaving
          # it unset serialises the model's DEFAULT empty element as
          # `<title> </title>` — rendered by xml2rfc as a bare `""`
          # (F9). The released leg renders the docid as the quoted
          # title; the refcontent emission below suppresses the echo.
          title_text ||= extract_bibitem_refcontent(bibitem)
          if title_text && !title_text.empty?
            t = Rfcxml::V3::Title.new
            t.content = [title_text]
            front.title = t
          end

          authors = extract_bibitem_authors(bibitem)
          if authors.nil? || authors.empty?
            author = Rfcxml::V3::Author.new
            author.surname = "Unknown"
            front.author = [author]
          else
            front.author = authors
          end

          ref.front = front

          series_infos = extract_bibitem_series_info(bibitem)
          series_infos.each { |si| safe_append(ref, :series_info, si) }

          refcontent_text = extract_bibitem_refcontent(bibitem)
          # suppressed when it merely echoes the docid-derived title
          # fallback above (F9)
          if refcontent_text && !refcontent_text.empty? &&
              refcontent_text != title_text
            rc = Rfcxml::V3::Refcontent.new
            rc.content = [refcontent_text]
            safe_append(ref, :refcontent, rc)
          end

          annotation_text = extract_bibitem_annotation(bibitem)
          if annotation_text && !annotation_text.empty?
            ann = Rfcxml::V3::Annotation.new
            ann.content = annotation_text
            safe_append(ref, :annotation, ann)
          end

          ref
        end

        def bibitem_anchor(bibitem)
          return nil unless bibitem

          return bibitem.anchor if bibitem.anchor && !bibitem.anchor.to_s.empty?

          # B-4: the presentation layer's id provision makes the bibitem
          # id the canonical anchor, while it rewrites docidentifier
          # CONTENT into display forms (a bare type name once the semx
          # wrapping is dropped) — so a non-GUID id outranks the
          # docidentifier fallbacks, which remain only for un-enriched
          # semantic input whose ids are GUIDs.
          id = bibitem.id
          return to_ncname(id) if id && !id.to_s.empty? &&
            !id.to_s.start_with?("_")

          ids = to_array(bibitem.docidentifier)
          ietf_id = ids.find { |d| d.type == "IETF" }
          if ietf_id
            text = id_content(ietf_id)
            return text.gsub(/\s/, "") if text && !text.empty?
          end

          rfc_anchor = ids.find { |d| d.type == "rfc-anchor" }
          return id_content(rfc_anchor) if rfc_anchor

          to_ncname(id) if id
        end

        # Only uri[@type="src"] becomes the reference target
        # (released-path parity, WS3 ref: untyped/RDF/xml URIs are
        # bibliographic metadata, not citation targets — the old path
        # emits no target for ISO712/ref11)
        def extract_bibitem_target(bibitem)
          uris = to_array(bibitem.link)

          # the released path accepted src OR HTML-typed uris (#301)
          src = uris.find { |u| u.type == "src" } ||
            uris.find { |u| u.type == "HTML" }
          return nil unless src

          text = u_content(src)
          text && !text.empty? ? text : nil
        end

        # Prefer the compound type="main" title (N10: taking the first
        # title truncated ISO-style multi-part titles to their intro
        # part); fall back to the first title present.
        def extract_bibitem_title(bibitem)
          titles = to_array(bibitem.title)
          main = titles.find do |t|
            t.respond_to?(:type) && t.type == "main"
          end
          title = main || titles.first
          text = title ? ls_text(title) : nil
          # a whitespace-only title (relaton fetch with no title data)
          # must count as absent: it defeated formattedref_only? and
          # rendered as an empty quoted title `""` (F9) — blanking it
          # routes the bibitem to the docid/formattedref fallback
          text = text&.strip
          text&.empty? ? nil : text
        end

        # the released renderer's allowed-role set beyond
        # author/editor (#301): a translator-only bibitem rendered its
        # translator, not <author surname="Unknown"/>
        FALLBACK_CONTRIBUTOR_ROLES =
          %w[performer adapter translator publisher distributor
             authorizer].freeze

        def extract_bibitem_authors(bibitem)
          authors = []
          fallbacks = []
          to_array(bibitem.contributor).each do |contrib|
            next unless contrib.role
            roles = to_array(contrib.role)
            role_type = roles.first&.type

            org = contrib.organization
            person = contrib.person

            author = build_bibitem_author(person, org)
            next unless author

            case role_type
            when "author", "editor"
              authors << author
            when *FALLBACK_CONTRIBUTOR_ROLES
              fallbacks << author
            end
          end

          authors.empty? ? fallbacks : authors
        end

        def build_bibitem_author(person, org)
          author = Rfcxml::V3::Author.new
          populate_author_name(author, person&.name)
          author.organization = build_organization(org) if org
          author
        end

        def extract_bibitem_date(bibitem)
          dates = to_array(bibitem.date)

          # released cascade (#301): published → issued → circulated →
          # first non-accessed; published-only lost issued-only dates
          pub = %w[published issued circulated]
            .filter_map { |t| dates.find { |d| d.type == t } }.first
          pub ||= dates.find { |d| d.type != "accessed" }
          return nil unless pub

          date = Rfcxml::V3::Date.new
          on = pub.on
          from = pub.respond_to?(:from) ? pub.from : nil
          if on
            on_str = date_value_to_str(on, bibitem)
            parse_date_into(date, on_str)
          elsif from
            # a from/to range renders its start year, as the released
            # path does (WS3 ref: <from>2013</from><to>2014</to> →
            # year="2013")
            parse_date_into(date, ls_text(from).to_s)
          elsif pub.text && !pub.text.empty?
            parse_date_into(date, pub.text)
          end
          # an unparseable value ("--", under-preparation dates) sets
          # no fields; suppress the empty <date/> rather than emit it
          return nil unless date.year || date.month || date.day

          date
        end

        def date_value_to_str(val, _bibitem = nil)
          return val if val.is_a?(String)
          if val.content
            val.content.to_s
          elsif val.text
            val.text.to_s
          elsif val.is_a?(Date) || val.is_a?(Time)
            val.strftime("%Y-%m-%d")
          else
            val.to_s
          end
        end

        def extract_bibitem_abstract(bibitem)
          abstracts = to_array(bibitem.abstract)
          return nil if abstracts.empty?

          abs = abstracts.first
          # a structured abstract carries p children
          # (FormattedString#p) — ls_text on the container sees only
          # inter-element whitespace (WS3 ref: RFC2119/RFC2397
          # abstracts rendered as empty t); bare-text abstracts fall
          # through to ls_text
          paras = abs.respond_to?(:p) ? to_array(abs.p) : []
          texts = paras.filter_map { |p| ls_text(p) }
            .reject { |t| t.strip.empty? }
          if texts.empty?
            text = ls_text(abs)
            texts = [text] unless text.nil? || text.strip.empty?
          end
          return nil if texts.empty?

          abstract = Rfcxml::V3::Abstract.new
          texts.each do |text|
            t = Rfcxml::V3::Text.new
            t.content = [text]
            safe_append(abstract, :t, t)
          end
          abstract
        end

        # Identifier types that never render as refcontent: the
        # IETF family rides seriesInfo and the anchor, DOI rides
        # seriesInfo, metanorma/metanorma-ordinal are display
        # artefacts (B-5). Released-path parity (WS3 ref): RFC
        # references carry no refcontent at all.
        # ISBN/ISSN/URN joined the exclusions (#301): the released
        # exclusion list suppressed them and the single-pick rewrite
        # had started emitting them
        NON_REFCONTENT_TYPES =
          %w[IETF Internet-Draft rfc-anchor DOI
             metanorma metanorma-ordinal ISBN ISSN URN].freeze

        def extract_bibitem_refcontent(bibitem)
          ids = to_array(bibitem.docidentifier)

          # ALL eligible identifiers joined (#301): the released path
          # rendered "ISO 2002, IEEE 802.2002", not a single pick
          eligible = ids.select do |d|
            d.type && !NON_REFCONTENT_TYPES.include?(d.type) &&
              (!d.respond_to?(:scope) || d.scope.to_s != "biblio-tag")
          end
          # WS2 A-3: a TYPELESS docidentifier is a citation label
          # ("Grail"), not a citation — the released path renders
          # refcontent only from authoritative identifiers. It
          # surfaces only in the 81f7bc1 orphan fallback, where the
          # reference has no other visible text.
          if eligible.empty? && !bibitem_has_visible_text?(bibitem)
            eligible = ids.select do |d|
              d.type != "metanorma-ordinal" &&
                (!d.respond_to?(:scope) || d.scope.to_s != "biblio-tag")
            end
          end

          texts = eligible.filter_map do |id|
            text = id_content(id)
            # a display-rewritten identifier whose content collapsed
            # to its own type name carries no information
            next if text.nil? || text.empty? || text == id.type
            # WS2 A-3: an identifier that merely echoes the reference
            # anchor ("…, ZELLER." / "…, Grail." for GRAIL) is noise,
            # not a citation — unless the reference has no other
            # visible text (the 81f7bc1 orphan fallback)
            next if text.casecmp?(bibitem_anchor(bibitem).to_s) &&
              bibitem_has_visible_text?(bibitem)

            text
          end.uniq

          texts.empty? ? nil : texts.join(", ")
        end

        def bibitem_has_visible_text?(bibitem)
          return true if to_array(bibitem.title).any? do |t|
            !ls_text(t).to_s.strip.empty?
          end

          fr = bibitem.formatted_ref
          fr && !ls_text(fr).to_s.strip.empty?
        end

        # A pure data mapping: DOI rides a docidentifier; the structural
        # series entries (RFC, BCP, STD, Internet-Draft, …) map series
        # title → name and series number → value. The previous
        # IETF-docidentifier inference emitted a junk "IETF" series and
        # dropped BCP entirely (campaign finding N9, structural half) —
        # and without seriesInfo name="RFC", xml2rfc cannot build hrefs
        # for sectioned xrefs and refuses output.
        def extract_bibitem_series_info(bibitem)
          infos = []

          to_array(bibitem.docidentifier).each do |d|
            next unless d.type == "DOI"
            si = Rfcxml::V3::SeriesInfo.new
            si.name = "DOI"
            si.value = id_content(d)
            infos << si if si.value && !si.value.empty?
          end

          to_array(bibitem.series).each do |s|
            type = s.respond_to?(:type) ? s.type.to_s : ""
            next if %w[stream intended].include?(type)

            number = s.respond_to?(:number) ? s.number : nil
            next if number.nil? || number.to_s.empty?

            name = series_title_text(s)
            next if name.empty?

            si = Rfcxml::V3::SeriesInfo.new
            si.name = name
            si.value = number.to_s
            infos << si
          end

          # an IETF-family identifier ("RFC 2119", "BCP 14", "STD 69")
          # is a series entry, not refcontent: the released path
          # derives seriesInfo from it when no explicit series carries
          # the same name (WS3 ref, ref11: docid-only "RFC 10" →
          # seriesInfo RFC 10) — and without name="RFC", xml2rfc
          # cannot build hrefs for sectioned xrefs (N9)
          to_array(bibitem.docidentifier).each do |d|
            next unless d.type == "IETF"

            m = id_content(d).to_s.match(/\A(RFC|BCP|STD|FYI)\s+(\S+)\z/i)
            next unless m
            name = m[1].upcase
            next if infos.any? { |si| si.name == name }

            si = Rfcxml::V3::SeriesInfo.new
            si.name = name
            si.value = m[2]
            infos << si
          end

          infos
        end

        # series type="stream" → <stream>, normalised to the xml2rfc
        # enumeration; unknown streams are omitted rather than emitted
        # verbatim, which was xml2rfc-fatal (#270)
        STREAMS = { "ietf" => "IETF", "iab" => "IAB", "irtf" => "IRTF",
                    "independent" => "independent" }.freeze

        def extract_bibitem_stream(bibitem)
          s = to_array(model_attr(bibitem, :series))
            .find { |x| x.respond_to?(:type) && x.type == "stream" }
          return nil unless s

          STREAMS[series_title_text(s).downcase]
        end

        def extract_bibitem_keywords(bibitem)
          to_array(model_attr(bibitem, :keyword)).filter_map do |k|
            text = ls_text(model_attr(k, :vocab))
            text = ls_text(k) if text.nil? || text.empty?
            next if text.nil? || text.empty?

            kw = Rfcxml::V3::Keyword.new
            kw.content = text
            kw
          end
        end

        def series_title_text(series)
          title = series.respond_to?(:title) ? series.title : nil
          return "" unless title

          content = title.respond_to?(:content) ? title.content : title
          content = content.join if content.is_a?(Array)
          content = ls_text(title) if content.nil? || content.to_s.empty?
          content.to_s.strip
        end

        def extract_bibitem_annotation(bibitem)
          return nil unless bibitem
          notes = bibitem.note
          return nil unless notes
          notes = [notes] unless notes.is_a?(Array)
          texts = notes.map { |n| ls_text(n) }.compact.reject(&:empty?)
          return nil if texts.empty?
          texts.join(" ")
        end

        def u_content(typed_uri)
          return nil unless typed_uri
          return typed_uri.content if typed_uri.content
          ls_text(typed_uri)
        end

        def id_content(doc_id)
          return nil unless doc_id
          return doc_id.id if doc_id.id
          ls_text(doc_id)
        end

      end
    end
  end
end
