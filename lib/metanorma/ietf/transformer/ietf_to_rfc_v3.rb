# frozen_string_literal: true

module Metanorma
  module Ietf
    module Transformer
      # Forward transformer: Metanorma XML → RFC XML v3
      class IetfToRfcV3
        autoload :MetadataTransformer, "metanorma/ietf/transformer/metadata_transformer"
        autoload :FrontTransformer, "metanorma/ietf/transformer/front_transformer"
        autoload :SectionTransformer, "metanorma/ietf/transformer/section_transformer"
        autoload :BlockTransformer, "metanorma/ietf/transformer/block_transformer"
        autoload :InlineTransformer, "metanorma/ietf/transformer/inline_transformer"
        autoload :ListTransformer, "metanorma/ietf/transformer/list_transformer"
        autoload :TableTransformer, "metanorma/ietf/transformer/table_transformer"
        autoload :FigureTransformer, "metanorma/ietf/transformer/figure_transformer"
        autoload :TermTransformer, "metanorma/ietf/transformer/term_transformer"
        autoload :ReferenceTransformer, "metanorma/ietf/transformer/reference_transformer"
        autoload :AnnotationTransformer, "metanorma/ietf/transformer/annotation_transformer"
        autoload :CleanupTransformer, "metanorma/ietf/transformer/cleanup_transformer"
        autoload :ValidationTransformer, "metanorma/ietf/transformer/validation_transformer"

        include Base
        include MetadataTransformer
        include FrontTransformer
        include SectionTransformer
        include BlockTransformer
        include InlineTransformer
        include ListTransformer
        include TableTransformer
        include FigureTransformer
        include TermTransformer
        include ReferenceTransformer
        include AnnotationTransformer
        include CleanupTransformer
        include ValidationTransformer

        attr_reader :doc, :options, :xrefs

        def initialize(doc, options = {})
          @doc = doc
          @options = options
          @xrefs = {}
          @footnote_counter = 0
          @seen_footnotes = {}
          @collected_footnotes = {}
          @image_counter = 0
          @queued_images = []
        end

        def transform
          rfc = Rfcxml::V3::Rfc.new
          set_rfc_attributes(rfc)
          rfc.link = build_links
          rfc.front = build_front
          rfc.middle = build_middle
          rfc.back = build_back
          cleanup(rfc)
          rfc
        end


        def bibdata
          @bibdata ||= doc.bibdata || NullObjects::NullBibdata.new
        end

        def doctype
          @doctype ||= begin
            ext = bibdata.ext
            return "internet-draft" unless ext
            dt = ext.doctype
            dt&.to_s || "internet-draft"
          end
        end

        def rfc?
          doctype.to_s.casecmp?("rfc")
        end

        def internet_draft?
          doctype == "internet-draft"
        end

        def lang
          langs = bibdata.language
          return "en" unless langs.is_a?(Array) && !langs.empty?
          l = langs.first
          val = l.value
          return val.is_a?(Array) ? val.join : val.to_s if val
          l.to_s
        end

        def main_title
          titles = bibdata.title
          return "" unless titles
          titles = [titles] unless titles.is_a?(Array)
          titles = titles.compact
          main = titles.find { |t| t.type == "main" }
          main ||= titles.first
          return "" unless main
          ls_text(main)
        end

        def abbrev_title
          titles = bibdata.title
          return nil unless titles
          titles = [titles] unless titles.is_a?(Array)
          titles = titles.compact
          abbr = titles.find { |t| t.type == "abbrev" }
          return nil unless abbr
          ls_text(abbr)
        end

        # explicitly authored ascii title (title type="ascii"),
        # preferred over transliteration (WS3, metadata_spec)
        def ascii_title
          titles = to_array(bibdata.title).compact
          asc = titles.find { |t| t.type == "ascii" }
          asc && ls_text(asc)
        end

        def docnumber
          dn = bibdata.docnumber
          if dn && !dn.to_s.empty?
            # legacy/mmark docnumbers: rfc-8341 / rfc-2313.md (#298)
            return dn.to_s.strip.sub(/^rfc-/, "").sub(/\.[a-z0-9]+$/i, "")
          end

          ids = bibdata.docidentifier
          return nil unless ids
          ids = [ids] unless ids.is_a?(Array)
          ids = ids.compact
          id = ids.find { |d| d.type == "IETF" }
          id ||= ids.first
          return ls_text(id) if id && !ls_text(id).to_s.empty?
          nil
        end

        def escape_xml_text(str)
          str.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;")
        end

        # Delegate to OrderTracker for all order operations
        def append_ordered(target, attr, value)
          OrderTracker.append_ordered(target, attr, value)
        end

        def safe_append(obj, attr_name, item)
          unless obj.respond_to?(attr_name)
            warn "IETF: #{obj.class} has no #{attr_name} collection; " \
                 "dropping element"
            return
          end
          coll = obj.public_send(attr_name)
          unless coll.is_a?(Array)
            obj.public_send(:"#{attr_name}=", [])
            coll = obj.public_send(attr_name)
          end
          coll << item
        end

        def track_text_order(target, text)
          OrderTracker.track_text(target, text)
        end

        def track_element_order(target, attr, value)
          OrderTracker.track_element(target, attr)
        end

        def build_order_entry_for(target, tag)
          Lutaml::Xml::Element.new("Element", tag.to_s, node_type: :element)
        end

        SIMPLE_INLINE_TAGS = %w[em strong tt sub sup].freeze

        def build_simple_inline(node, tag, idx)
          return nil unless SIMPLE_INLINE_TAGS.include?(tag)

          coll = node.public_send(tag)
          return nil unless coll.is_a?(Array) && coll[idx]

          build_simple_inline_model(coll[idx], tag)
        end

        SIMPLE_INLINE_CLASSES = {
          "em" => "Em", "strong" => "Strong", "tt" => "Tt",
          "sub" => "Sub", "sup" => "Sup"
        }.freeze

        def build_simple_inline_model(model, tag)
          elem = Rfcxml::V3.const_get(SIMPLE_INLINE_CLASSES[tag]).new
          val = ls_text(model)
          if val && !val.empty?
            elem.content = [val]
          elsif !build_nested_inline(elem, model)
            # nested inline (em > strong, tt > link): the own-text is
            # empty and the content lives in child elements. What the
            # nested walk cannot recover is parse-ghosted on this
            # vintage's inline element models (EmRawElement drops a
            # nested <strong> outright — 0.2.9 ledger); an empty
            # element is noise, so it is suppressed (WS3, cleanup_spec)
            return nil
          end
          elem
        end

        # returns true if any nested content was recovered
        def build_nested_inline(elem, model)
          added = false
          SIMPLE_INLINE_TAGS.each do |t|
            next unless model.respond_to?(t)

            to_array(model.public_send(t)).each do |child|
              built = build_simple_inline_model(child, t)
              next unless built

              safe_append(elem, t.to_sym, built)
              added = true
            end
          end
          added |= append_nested_link_text(elem, model)
          added
        end

        def append_nested_link_text(elem, model)
          added = false
          links = model.respond_to?(:link) ? to_array(model.link) : []
          # the rendering of a nested link survives on the semx
          # accessor of this vintage's inline models (fmt-link) —
          # consume it where the semantic link itself is ghosted
          # (WS3, cleanup_spec: <tt><link target="B"/></tt>). This
          # is NOT the xref-smoothing fmt exception but the other
          # sanctioned class (qa-plan policy 2026-07-31): content
          # recovery for a parse ghost, self-retiring — the
          # semantic links branch above takes over the moment the
          # model maps them
          if links.empty? && model.respond_to?(:semx)
            to_array(model.semx).each do |s|
              links += to_array(model_attr(s, :fmt_link))
            end
          end
          links.each do |l|
            # a bare link renders as its target text (N4)
            text = ls_text(l)
            if (text.nil? || text.empty?) && l.respond_to?(:target)
              text = l.target.to_s
            end
            next if text.nil? || text.empty?

            elem.content = to_array(elem.content) + [text]
            added = true
          end
          added
        end

        def populate_author_name(author, person_name)
          return unless person_name

          surname = ls_text(person_name.surname)
          complete = ls_text(person_name.complete_name)

          if surname
            author.surname = surname
            ascii_surname = Sterile.transliterate(surname)
            author.ascii_surname = ascii_surname unless ascii_surname == surname

            forenames = person_name.forename
            if forenames.is_a?(Array) && !forenames.empty?
              parts = forenames.map { |f| ls_text(f).to_s.strip }.reject(&:empty?)
              if parts.any?
                # authored initials win over forename-derived ("B. X."
                # must not collapse to "B.", #298)
                authored = to_array(person_name.initials)
                  .map { |i| ls_text(i).to_s.strip }.reject(&:empty?)
                author.initials = if authored.any?
                                    authored.join(" ")
                                  else
                                    parts.map { |p| "#{p.chars.first}." }.join(" ")
                                  end
                ascii_init = Sterile.transliterate(author.initials)
                author.ascii_initials = ascii_init unless ascii_init == author.initials
                first_name = parts.first
                author.fullname = complete || "#{first_name} #{surname}"
                ascii_full = "#{Sterile.transliterate(first_name)} #{ascii_surname}"
                author.ascii_fullname = ascii_full unless ascii_full == author.fullname
              end
            else
              initials_raw = to_array(person_name.initials).map { |i| ls_text(i).to_s.strip }.reject(&:empty?)
              # <formatted-initials> is a parse ghost on the pinned
              # model (fixed upstream in metanorma-document 0.5.1);
              # derive initials from the completename meanwhile —
              # without an initials attribute xml2rfc re-parses the
              # fullname and breaks particle surnames:
              # "D. van Gulik" -> "Gulik, D. V." (F10)
              if initials_raw.empty? && complete && !complete.empty?
                given = complete.sub(/\s*#{Regexp.escape(surname)}\s*\z/, "").strip
                unless given.empty? || given == complete
                  initials_raw = given.split(/\s+/)
                    .map { |w| w.end_with?(".") ? w : "#{w.chars.first}." }
                end
              end
              if initials_raw.any?
                author.initials = initials_raw.join(" ")
                ascii_init = Sterile.transliterate(author.initials)
                author.ascii_initials = ascii_init unless ascii_init == author.initials
              end
              if complete && !complete.empty?
                author.fullname = complete
                ascii_full = Sterile.transliterate(complete)
                author.ascii_fullname = ascii_full unless ascii_full == complete
              end
            end
          elsif complete
            author.fullname = complete
            ascii = Sterile.transliterate(complete)
            author.ascii_fullname = ascii unless ascii == complete
          end
        end

        def build_organization(org_node)
          build_rfc_organization(org_node)
        end

        def get_paragraphs(node)
          if node.is_a?(Metanorma::Document::Components::Blocks::NoteBlock)
            c = node.content
            return c.is_a?(Array) ? c : []
          end

          if node.is_a?(Metanorma::Document::Components::Lists::DdElement) ||
             node.is_a?(Metanorma::Document::Components::Tables::TableCell)
            ps = node.p
            return ps.is_a?(Array) ? ps : []
          end

          # respond_to? guards (WS3): carrier names vary by model vintage
          paras = node.respond_to?(:paragraphs) ? node.paragraphs : nil
          return paras if paras.is_a?(Array)

          ps = node.respond_to?(:p) ? node.p : nil
          return ps if ps.is_a?(Array) && !ps.empty?

          c = node.respond_to?(:content) ? node.content : nil
          return c.select { |item| item.is_a?(Metanorma::Document::Components::Paragraphs::ParagraphBlock) } if c.is_a?(Array)

          []
        end
      end
    end
  end
end
