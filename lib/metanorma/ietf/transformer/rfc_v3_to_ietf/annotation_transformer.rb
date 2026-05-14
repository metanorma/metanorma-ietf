# frozen_string_literal: true

module Metanorma
  module Ietf
    module Transformer
      module RfcV3ToIetf
        # Transforms RFC XML v3 <cref> elements into Metanorma
        # annotation model objects (NoteBlock within an annotation
        # container).
        module AnnotationTransformer
          private

          def extract_crefs(section_node)
            crefs = []
            return crefs unless section_node

            # Direct crefs on section
            to_array(section_node.cref).each do |cref|
              crefs << cref if cref
            end

            # Walk t elements for inline crefs
            to_array(section_node.t).each do |t_node|
              crefs.concat(extract_crefs_from_node(t_node))
            end

            # Walk blockquote
            to_array(section_node.blockquote).each do |bq|
              to_array(bq.t).each do |t_node|
                crefs.concat(extract_crefs_from_node(t_node))
              end
            end

            # Walk list items
            %i[ul ol].each do |list_attr|
              to_array(section_node.public_send(list_attr)).each do |list|
                crefs.concat(extract_crefs_from_list(list))
              end
            end

            crefs
          end

          def extract_crefs_from_node(node)
            crefs = []
            return crefs unless node

            to_array(node.cref).each do |cref|
              crefs << cref if cref
            end

            crefs
          end

          def extract_crefs_from_list(list)
            crefs = []
            return crefs unless list

            to_array(list.li).each do |li|
              next unless li
              to_array(li.t).each do |t_node|
                crefs.concat(extract_crefs_from_node(t_node))
              end
            end

            crefs
          end

          def transform_cref(cref_node)
            return nil unless cref_node

            id = cref_node.anchor || generate_id
            text = extract_cref_text(cref_node)

            return nil if text.empty?

            note = Metanorma::Document::Components::Blocks::NoteBlock.new(id: id)

            if cref_node.source && !cref_node.source.to_s.empty?
              source_name = build_name_element("(#{cref_node.source})")
              note.name = source_name
            end

            p = Metanorma::Document::Components::Paragraphs::ParagraphBlock.new(
              text: [text],
            )
            note.content = [p]

            note
          end

          def extract_cref_text(cref_node)
            content = cref_node.content
            if content
              text = content.is_a?(Array) ? content.join : content.to_s
              return text.strip unless text.strip.empty?
            end

            extract_rfc_mixed_text(cref_node)
          end
        end
      end
    end
  end
end
