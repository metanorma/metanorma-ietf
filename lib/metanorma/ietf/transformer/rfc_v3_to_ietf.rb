# frozen_string_literal: true

module Metanorma
  module Ietf
    module Transformer
      module RfcV3ToIetf
        autoload :MetadataTransformer, "metanorma/ietf/transformer/rfc_v3_to_ietf/metadata_transformer"
        autoload :FrontTransformer, "metanorma/ietf/transformer/rfc_v3_to_ietf/front_transformer"
        autoload :SectionTransformer, "metanorma/ietf/transformer/rfc_v3_to_ietf/section_transformer"
        autoload :BlockTransformer, "metanorma/ietf/transformer/rfc_v3_to_ietf/block_transformer"
        autoload :InlineTransformer, "metanorma/ietf/transformer/rfc_v3_to_ietf/inline_transformer"
        autoload :TableTransformer, "metanorma/ietf/transformer/rfc_v3_to_ietf/table_transformer"
        autoload :ListTransformer, "metanorma/ietf/transformer/rfc_v3_to_ietf/list_transformer"
        autoload :FigureTransformer, "metanorma/ietf/transformer/rfc_v3_to_ietf/figure_transformer"
        autoload :TermTransformer, "metanorma/ietf/transformer/rfc_v3_to_ietf/term_transformer"
        autoload :ReferenceTransformer, "metanorma/ietf/transformer/rfc_v3_to_ietf/reference_transformer"
        autoload :AnnotationTransformer, "metanorma/ietf/transformer/rfc_v3_to_ietf/annotation_transformer"
        autoload :CleanupTransformer, "metanorma/ietf/transformer/rfc_v3_to_ietf/cleanup_transformer"

        # Reverse transformer: RFC XML v3 → Metanorma XML
        #
        # Parses an Rfcxml::V3::Rfc model tree and builds a
        # Metanorma::IetfDocument::Root model tree.
        class Transformer
          include Base
          include RfcV3ToIetf::MetadataTransformer
          include RfcV3ToIetf::FrontTransformer
          include RfcV3ToIetf::SectionTransformer
          include RfcV3ToIetf::BlockTransformer
          include RfcV3ToIetf::InlineTransformer
          include RfcV3ToIetf::TableTransformer
          include RfcV3ToIetf::ListTransformer
          include RfcV3ToIetf::FigureTransformer
          include RfcV3ToIetf::TermTransformer
          include RfcV3ToIetf::ReferenceTransformer
          include RfcV3ToIetf::AnnotationTransformer
          include RfcV3ToIetf::CleanupTransformer

          attr_reader :rfc, :options, :xrefs

          def initialize(rfc, options = {})
            @rfc = rfc
            @options = options
            @xrefs = {}
            @id_counter = 0
          end

          def transform
            root = Metanorma::IetfDocument::Root.new
            root.bibdata = build_bibdata
            root.sections = build_sections
            build_bibliography(root)
            build_annexes(root)
            build_preface(root)
            cleanup_reverse(root)
            root
          end

          # Generate a unique ID for cases where none exists
          def generate_id
            @id_counter += 1
            "_#{@id_counter}"
          end

          def resolve_id(node, _prefix = "")
            return nil unless node
            return nil unless node.class.method_defined?(:anchor)

            anchor = node.anchor
            return anchor if anchor && !anchor.to_s.empty?
          end

          # Build sections from RFC middle
          def build_sections
            sections = Metanorma::IetfDocument::Sections::IetfSections.new
            middle = rfc.middle
            return sections unless middle

            to_array(middle.section).each do |section_node|
              clause = transform_section(section_node)
              next unless clause

              OrderTracker.append_ordered(sections, :clause, clause)
            end

            sections
          end

          # Build bibliography from RFC back references
          def build_bibliography(root)
            back = rfc.back
            return unless back

            refs_sections = to_array(back.references)
            return if refs_sections.empty?

            bib = Metanorma::StandardDocument::Sections::BibliographySection.new
            refs_sections.each do |refs_node|
              ref_section = transform_references_section(refs_node)
              next unless ref_section

              OrderTracker.append_ordered(bib, :references, ref_section)
            end

            root.bibliography = bib
          end

          # Build annexes from RFC back sections
          def build_annexes(root)
            back = rfc.back
            return unless back

            to_array(back.section).each do |section_node|
              annex = transform_annex(section_node)
              next unless annex

              OrderTracker.append_ordered(root, :annex, annex)
            end
          end

          # Build preface from RFC front abstract/notes
          def build_preface(root)
            front = rfc.front
            return unless front

            preface = Metanorma::StandardDocument::Sections::Preface.new

            if front.abstract
              abstract = transform_abstract(front.abstract)
              preface.abstract = abstract if abstract
            end

            to_array(front.note).each do |note_node|
              note_clause = transform_front_note(note_node)
              next unless note_clause

              OrderTracker.append_ordered(preface, :content, note_clause)
            end

            if preface.abstract || (preface.content.is_a?(Array) && !preface.content.empty?)
              root.preface = preface
            end
          end

          def build_localized_string(text, language: "en")
            return nil unless text
            Metanorma::Document::Components::DataTypes::LocalizedString.new(
              value: [text],
              language: language,
            )
          end

          def extract_node_title(node)
            title = node.title if node.class.method_defined?(:title)
            title || (node.name ? extract_rfc_text(node.name) : nil)
          end

          def build_title_element(text)
            return nil unless text && !text.empty?
            Metanorma::Document::Components::Inline::TitleWithAnnotationElement.new(
              text: [text],
            )
          end

          def build_name_element(text)
            return nil unless text && !text.empty?
            Metanorma::Document::Components::Inline::NameWithIdElement.new(
              text: [text],
            )
          end
        end
      end
    end
  end
end
