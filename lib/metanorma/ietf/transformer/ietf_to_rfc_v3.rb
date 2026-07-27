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
          doctype == "rfc"
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

        def docnumber
          dn = bibdata.docnumber
          return dn if dn && !dn.to_s.empty?

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

          klass = case tag
                  when "em" then Rfcxml::V3::Em
                  when "strong" then Rfcxml::V3::Strong
                  when "tt" then Rfcxml::V3::Tt
                  when "sub" then Rfcxml::V3::Sub
                  when "sup" then Rfcxml::V3::Sup
                  end
          elem = klass.new
          val = ls_text(coll[idx])
          elem.content = [val] if val && !val.empty?
          elem
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
                author.initials = parts.map { |p| "#{p.chars.first}." }.join(" ")
                first_name = parts.first
                author.fullname = complete || "#{first_name} #{surname}"
                ascii_full = "#{Sterile.transliterate(first_name)} #{ascii_surname}"
                author.ascii_fullname = ascii_full unless ascii_full == author.fullname
              end
            else
              initials_raw = to_array(person_name.initials).map { |i| ls_text(i).to_s.strip }.reject(&:empty?)
              author.initials = initials_raw.join(" ") if initials_raw.any?
              author.fullname = complete if complete && !complete.empty?
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
