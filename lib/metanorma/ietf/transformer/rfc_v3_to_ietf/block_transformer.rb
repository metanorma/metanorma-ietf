# frozen_string_literal: true

module Metanorma
  module Ietf
    module Transformer
      module RfcV3ToIetf
        # Transforms RFC XML v3 block elements (t, sourcecode, blockquote,
        # aside, note) into Metanorma block model objects.
        module BlockTransformer

          def transform_t(t_node)
            return nil unless t_node

            p = Metanorma::Document::Components::Paragraphs::ParagraphBlock.new
            p.id = resolve_id(t_node) if t_node.anchor && !t_node.anchor.to_s.empty?

            # Build inline content from the t node's mixed content
            transform_inline_children(t_node, p)

            p
          end

          def transform_sourcecode(sc_node)
            return nil unless sc_node

            sc = Metanorma::Document::Components::AncillaryBlocks::SourcecodeBlock.new(
              id: resolve_id(sc_node),
            )

            sc.lang = sc_node.type if sc_node.type && !sc_node.type.to_s.empty?
            sc.filename = sc_node.name if sc_node.name && !sc_node.name.to_s.empty?
            sc.markers = sc_node.markers if sc_node.markers && !sc_node.markers.to_s.empty?

            code_text = extract_rfc_text(sc_node)
            sc.content = code_text if code_text && !code_text.empty?

            sc
          end

          def transform_blockquote(bq_node)
            return nil unless bq_node

            quote = Metanorma::Document::Components::MultiParagraph::QuoteBlock.new(
              id: resolve_id(bq_node),
            )

            if bq_node.quoted_from && !bq_node.quoted_from.to_s.empty?
              attr = Metanorma::Document::Components::Inline::AttributionElement.new(
                text: [bq_node.quoted_from.to_s],
              )
              quote.attribution = attr
            end

            to_array(bq_node.t).each do |t_node|
              p = transform_t(t_node)
              next unless p

              quote.paragraphs = to_array(quote.paragraphs)
              quote.paragraphs << p
            end

            quote
          end

          def transform_aside_to_note(aside_node)
            return nil unless aside_node

            note = Metanorma::Document::Components::Blocks::NoteBlock.new(
              id: resolve_id(aside_node),
            )

            to_array(aside_node.t).each do |t_node|
              p = transform_t(t_node)
              next unless p

              note.content = to_array(note.content)
              note.content << p
            end

            note
          end
        end
      end
    end
  end
end
