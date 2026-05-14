# frozen_string_literal: true

require_relative "base"
require_relative "null_objects"
require_relative "order_tracker"
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
      # Forward transformer: Metanorma XML → RFC XML v3
      class IetfToRfcV3
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

        private

        def bibdata
          @bibdata ||= doc.bibdata || NullBibdata.new
        end

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
        rescue StandardError
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
