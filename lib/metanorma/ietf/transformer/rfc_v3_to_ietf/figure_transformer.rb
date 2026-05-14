# frozen_string_literal: true

module Metanorma
  module Ietf
    module Transformer
      module RfcV3ToIetf
        # Transforms RFC XML v3 <figure> and <artwork> elements into
        # Metanorma figure model objects.
        module FigureTransformer
          private

          def transform_figure(fig_node)
            return nil unless fig_node

            figure = Metanorma::Document::Components::AncillaryBlocks::FigureBlock.new(
              id: resolve_id(fig_node),
            )

            # Title
            title = fig_node.title || (fig_node.name ? extract_rfc_text(fig_node.name) : nil)
            figure.name = build_name_element(title) if title && !title.empty?

            # Artwork → image or pre
            to_array(fig_node.artwork).each do |art_node|
              if art_node.src && !art_node.src.to_s.empty?
                image = transform_artwork_to_image(art_node)
                figure.image = image if image
              elsif art_node.content && !art_node.content.to_s.strip.empty?
                pre = transform_artwork_to_pre(art_node)
                figure.pre = pre if pre
              end
            end

            # Sourcecode within figure
            to_array(fig_node.sourcecode).each do |sc_node|
              sc = transform_sourcecode(sc_node)
              # Sourcecode in figure context — not standard but handle gracefully
            end

            figure
          end

          def transform_artwork_to_image(art_node)
            src = art_node.src
            return nil unless src

            image = Metanorma::Document::Components::IdElements::Image.new(
              source: src.to_s,
            )

            if art_node.type
              mime = art_type_to_mime(art_node.type)
              image.type = mime if mime
            end

            image.alt = art_node.alt if art_node.alt && !art_node.alt.to_s.empty?
            image.height = art_node.height if art_node.height && !art_node.height.to_s.empty?
            image.width = art_node.width if art_node.width && !art_node.width.to_s.empty?

            image
          end

          def transform_artwork_to_pre(art_node)
            return nil unless art_node.content

            text = art_node.content.to_s
            return nil if text.strip.empty?

            Metanorma::Document::Components::AncillaryBlocks::LiteralBlock.new(
              id: resolve_id(art_node),
              content: text,
            )
          end

          def art_type_to_mime(type)
            case type.to_s.downcase
            when "svg" then "image/svg+xml"
            when "png" then "image/png"
            when "jpg", "jpeg" then "image/jpeg"
            when "gif" then "image/gif"
            else "application/octet-stream"
            end
          end
        end
      end
    end
  end
end
