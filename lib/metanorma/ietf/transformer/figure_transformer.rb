# frozen_string_literal: true

require "base64"

module Metanorma
  module Ietf
    module Transformer
      module FigureTransformer
        private

        def transform_figure(figure_node)
          if pseudocode_figure?(figure_node)
            return transform_pseudocode(figure_node)
          end

          figure = Rfcxml::V3::Figure.new
          figure.anchor = to_ncname(figure_node.id) if figure_node.id

          name_node = figure_node.name
          if name_node
            name = Rfcxml::V3::Name.new
            name_text = ls_text(name_node)
            name.content = [name_text] if name_text && !name_text.empty?
            figure.name = name unless name.content.nil? || name.content.empty?
          end

          # Use element_order to process figure children in order
          src_order = figure_node.element_order
          if src_order && src_order.any?
            pre_idx = 0
            img_idx = 0
            sc_idx = 0
            src_order.each do |e|
              next if e.text?
              tag = e.element_tag
              case tag
              when "image"
                images = figure_node.image || []
                images = [images] unless images.is_a?(Array)
                img = images[img_idx]
                img_idx += 1
                if img
                  artwork = transform_image_to_artwork(img)
                  safe_append(figure, :artwork, artwork) if artwork
                end
              when "pre"
                pres = figure_node.pre || []
                pres = [pres] unless pres.is_a?(Array)
                pre_node = pres[pre_idx]
                pre_idx += 1
                if pre_node
                  artwork = transform_pre_to_artwork(pre_node)
                  safe_append(figure, :artwork, artwork) if artwork
                end
              when "sourcecode"
                sourcecodes = figure_node.sourcecode_blocks || []
                sourcecodes = [sourcecodes] unless sourcecodes.is_a?(Array)
                if sourcecodes[sc_idx]
                  src = transform_sourcecode(sourcecodes[sc_idx])
                  safe_append(figure, :sourcecode, src) if src
                end
                sc_idx += 1
              end
            end
          else
            # Fallback without element_order
            images = figure_node.image || []
            images = [images] unless images.is_a?(Array)
            images.each do |img|
              artwork = transform_image_to_artwork(img)
              safe_append(figure, :artwork, artwork) if artwork
            end

            pres = figure_node.pre || []
            pres = [pres] unless pres.is_a?(Array)
            pres.each do |pre_node|
              artwork = transform_pre_to_artwork(pre_node)
              safe_append(figure, :artwork, artwork) if artwork
            end
          end

          # Figure source/citation
          sources = figure_node.source
          if sources
            sources = [sources] unless sources.is_a?(Array)
            sources.each do |src|
              src_text = format_figure_source(src)
              if src_text && !src_text.empty?
                postamble = figure.postamble || Rfcxml::V3::Postamble.new
                t = Rfcxml::V3::Text.new
                t.content = ["[SOURCE: #{src_text}]"]
                safe_append(postamble, :t, t)
                figure.postamble = postamble
              end
            end
          end

          figure
        end

        def transform_pseudocode(figure_node)
          sourcecodes = figure_node.sourcecode_blocks || []
          sourcecodes = [sourcecodes] unless sourcecodes.is_a?(Array)
          sc = sourcecodes.first
          if sc
            return transform_sourcecode(sc)
          end

          # Collect text content from paragraphs
          lines = []
          get_paragraphs(figure_node).each do |p|
            text = extract_paragraph_text(p)
            lines << "  #{text}" if text && !text.strip.empty?
          end

          sourcecode = Rfcxml::V3::Sourcecode.new
          sourcecode.anchor = to_ncname(figure_node.id) if figure_node.id
          sourcecode.content = [lines.join("\n")] unless lines.empty?
          sourcecode
        end

        def pseudocode_figure?(figure_node)
          figure_node.class_attr == "pseudocode"
        rescue NoMethodError
          false
        end

        def transform_image_to_artwork(img_node)
          artwork = Rfcxml::V3::Artwork.new

          src = img_node.src
          src = img_node.target unless src

          if src
            # Handle SVG data URIs - decode base64 to inline SVG
            if src.start_with?("data:image/svg+xml;base64,")
              begin
                encoded = src.sub(%r{\Adata:image/svg\+xml;base64,}, "")
                decoded = Base64.decode64(encoded)
                artwork.type = "svg"
                artwork.content = decoded
                return artwork
              rescue StandardError
                # Fall through to use src as-is
              end
            elsif src.start_with?("data:image/svg+xml")
              begin
                encoded = src.sub(%r{\Adata:image/svg\+xml[;,]}, "")
                require "cgi"
                decoded = CGI.unescape(encoded)
                artwork.type = "svg"
                artwork.content = decoded
                return artwork
              rescue StandardError
                # Fall through
              end
            elsif src.end_with?(".svg")
              artwork.type = "svg"
              artwork.src = src
            else
              artwork.src = src
            end
          end

          # Alt text
          alt = img_node.alt
          artwork.alt = alt.to_s if alt && !alt.to_s.empty?

          # Title
          title = img_node.title
          artwork.title = title.to_s if title && !title.to_s.empty?

          artwork
        end

        def transform_pre_to_artwork(pre_node)
          artwork = Rfcxml::V3::Artwork.new
          artwork.type = "ascii-art"

          artwork.anchor = to_ncname(pre_node.id) if pre_node.id
          artwork.alt = pre_node.alt if pre_node.alt && !pre_node.alt.to_s.empty?

          align = pre_node.align
          artwork.align = align if align && !align.to_s.empty?

          text = ""
          if pre_node.content
            c = pre_node.content
            text = c.is_a?(Array) ? c.join : c.to_s
          elsif pre_node.text
            text = pre_node.text.is_a?(Array) ? pre_node.text.join : pre_node.text.to_s
          end

          text = text.gsub("\t", "    ")

          # Wrap in CDATA to handle special XML characters in ASCII art
          artwork.content = text.empty? ? nil : "<![CDATA[#{text}]]>"

          artwork
        end

        def extract_figure_asides(figure_node)
          asides = []
          notes = figure_node.note || []
          notes = [notes] unless notes.is_a?(Array)
          notes.each do |note_node|
            asides << build_inline_note_aside(note_node)
          end
          asides
        end

        def format_figure_source(source)
          return nil unless source
          if source.is_a?(String)
            source
          else
            ls_text(source)
          end
        end
      end
    end
  end
end
