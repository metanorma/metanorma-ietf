# frozen_string_literal: true

require_relative "metadata_transformer"
require_relative "front_transformer"
require_relative "section_transformer"
require_relative "block_transformer"
require_relative "inline_transformer"
require_relative "list_transformer"
require_relative "table_transformer"
require_relative "figure_transformer"
require_relative "term_transformer"
require_relative "reference_transformer"
require_relative "annotation_transformer"
require_relative "cleanup_transformer"
require_relative "validation_transformer"

module Metanorma
  module Ietf
    module Transformer
      class IetfToRfcV3
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

        private

        # Extract text from various metanorma-document string types
        # LocalizedString has .value (Array of String)
        # TypedTitleString has .content (String)
        # Some models use .text or plain String
        # Types that use .text for their primary content
        TEXT_BASED_TYPES = [
          Metanorma::Document::Components::Inline::TitleWithAnnotationElement,
          Metanorma::Document::Components::Inline::EmRawElement,
          Metanorma::Document::Components::Inline::StrongRawElement,
          Metanorma::Document::Components::Inline::SupElement,
          Metanorma::Document::Components::Inline::TtElement,
          Metanorma::Document::Components::Inline::Bcp14Element,
          Metanorma::Document::Components::Inline::SpanElement,
          Metanorma::Document::Components::Inline::SmallCapElement,
          Metanorma::Document::Components::Inline::NameWithIdElement,
          Metanorma::Document::Components::Inline::ErefElement,
          Metanorma::Document::Components::Inline::XrefElement,
          Metanorma::Document::Components::Inline::FmtTitleElement,
          Metanorma::Document::Components::Inline::FmtXrefLabelElement,
          Metanorma::Document::Components::Inline::FmtNameElement,
          Metanorma::Document::Components::Inline::FmtFnLabelElement,
          Metanorma::Document::Components::Inline::FmtSourcecodeElement,
          Metanorma::Document::Components::Inline::FmtConceptElement,
          Metanorma::Document::Components::Inline::FmtXrefElement,
          Metanorma::Document::Components::Inline::SemxElement,
          Metanorma::Document::Components::Inline::BiblioTagElement,
          Metanorma::Document::Components::Inline::DisplayTextElement,
          Metanorma::Document::Components::Inline::VariantTitleElement,
        ].freeze

        def ls_text(obj)
          return nil unless obj
          return obj if obj.is_a?(String)
          return obj.map { |o| ls_text(o) }.compact.join if obj.is_a?(Array)

          # LocalizedString and FormattedString have .value
          if obj.is_a?(Metanorma::Document::Components::DataTypes::LocalizedString) ||
             obj.is_a?(Metanorma::Document::Components::DataTypes::FormattedString)
            val = obj.value
            return val.is_a?(Array) ? val.join : val.to_s
          end

          # DocumentIdentifier has .id
          if obj.is_a?(Metanorma::Document::Relaton::DocumentIdentifier)
            return obj.id.to_s
          end

          # Many inline element types use .text
          if TEXT_BASED_TYPES.any? { |t| obj.is_a?(t) }
            t = obj.text
            return t.is_a?(Array) ? t.join : t.to_s
          end

          # Most other types have .content (TypedTitleString, Name, LinkElement, etc.)
          c = obj.content
          if c
            return c.is_a?(Array) ? c.join : c.to_s
          end

          t = obj.text
          if t
            return t.is_a?(Array) ? t.join : t.to_s
          end
          obj.to_s
        end

        def escape_xml_text(str)
          str.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;")
        end

        # Extract text from title/name elements that may be LocalizedString or raw
        def extract_text(node)
          return "" unless node
          result = ls_text(node)
          result.is_a?(String) ? result.strip : ""
        end

        # Get the anchor/id for a node
        def anchor_for(node)
          node.anchor || node.id || node.semx_id
        end

        # Sanitize an id to be a valid NCName (for XML anchors)
        def to_ncname(id)
          return nil unless id
          id = id.to_s.strip
          return nil if id.empty?
          id = "_" + id unless id.match?(/\A[a-zA-Z_]/)
          id.gsub(/[^a-zA-Z0-9._\-]/, "_")
        end

        # Access bibdata
        def bibdata
          @bibdata ||= doc.bibdata
        end

        # Get doctype from bibdata ext
        def doctype
          @doctype ||= begin
            dt = bibdata.ext.doctype
            dt.to_s
          end
        rescue StandardError
          "internet-draft"
        end

        def rfc?
          doctype == "rfc"
        end

        def internet_draft?
          doctype == "internet-draft"
        end

        # Resolve the document language
        def lang
          langs = bibdata.language
          if langs.is_a?(Array) && !langs.empty?
            l = langs.first
            l.value ? ls_text(l) : l.to_s
          else
            "en"
          end
        rescue StandardError
          "en"
        end

        # Get the title from bibdata
        def main_title
          titles = bibdata.title
          titles = [titles] unless titles.is_a?(Array)
          main = titles.find { |t| t.type == "main" }
          main ||= titles.first
          return "" unless main
          ls_text(main)
        end

        def abbrev_title
          titles = bibdata.title
          titles = [titles] unless titles.is_a?(Array)
          abbr = titles.find { |t| t.type == "abbrev" }
          return nil unless abbr
          ls_text(abbr)
        end

        # Get docnumber
        def docnumber
          dn = bibdata.docnumber
          return dn if dn && !dn.to_s.empty?

          # Fallback: extract from doc_identifier
          ids = bibdata.docidentifier
          ids = [ids] unless ids.is_a?(Array)
          id = ids.find { |d| d.type == "IETF" }
          id ||= ids.first
          return ls_text(id) if id && !ls_text(id).to_s.empty?
          nil
        rescue StandardError
          nil
        end

        # Safely append to an rfcxml model collection that may default to nil.
        # Initializes the collection to [] if needed, then appends the item.
        def safe_append(obj, attr_name, item)
          coll = obj.send(attr_name)
          unless coll.is_a?(Array)
            obj.send(:"#{attr_name}=", [])
            coll = obj.send(attr_name)
          end
          coll << item
        end

        # Get paragraphs from any node type.
        # Different metanorma-document node types use different attribute names:
        # - ClauseSection: .paragraphs
        # - NoteBlock: .content (array of ParagraphBlock)
        # - DdElement: .p
        # - ListItem: .text or .paragraphs
        def get_paragraphs(node)
          # NoteBlock uses .content for its paragraphs
          if node.is_a?(Metanorma::Document::Components::Blocks::NoteBlock)
            c = node.content
            return c.is_a?(Array) ? c : []
          end

          # DdElement and TableCell use .p for paragraphs
          if node.is_a?(Metanorma::Document::Components::Lists::DdElement) ||
             node.is_a?(Metanorma::Document::Components::Tables::TableCell)
            ps = node.p
            return ps.is_a?(Array) ? ps : []
          end

          paras = node.paragraphs
          return paras if paras.is_a?(Array)

          ps = node.p
          return ps if ps.is_a?(Array) && !ps.empty?

          c = node.content
          return c.select { |item| item.class.name.end_with?("ParagraphBlock") } if c.is_a?(Array)

          []
        end
      end
    end
  end
end
