# frozen_string_literal: true

require "base64"

module Metanorma
  module Ietf
    module Transformer
      module FigureTransformer

        def transform_figure(figure_node)
          if pseudocode_figure?(figure_node)
            pseudo = transform_pseudocode(figure_node)
            return pseudo if pseudo
          end

          figure = Rfcxml::V3::Figure.new
          figure.anchor = to_ncname(anchor_for(figure_node)) if anchor_for(figure_node)

          # inline markup in captions is carried, not flattened (#292)
          name = build_inline_name(figure_node.name)
          figure.name = name if name

          # Use element_order to process figure children in order
          src_order = figure_node.element_order
          if src_order && src_order.any?
            counters = Hash.new(0)
            src_order.each do |e|
              next if e.text?
              tag = e.element_tag
              idx = counters[tag]
              counters[tag] += 1
              case tag
              when "image"
                img = to_array(figure_node.image || [])[idx]
                if img
                  artwork = transform_image_to_artwork(img)
                  safe_append(figure, :artwork, artwork) if artwork
                end
              when "pre"
                pre_node = to_array(figure_node.pre || [])[idx]
                if pre_node
                  artwork = transform_pre_to_artwork(pre_node)
                  safe_append(figure, :artwork, artwork) if artwork
                end
              when "sourcecode"
                sourcecodes = to_array(model_attr(figure_node,
                                                  :sourcecode_blocks) || [])
                if sourcecodes[idx]
                  src = transform_sourcecode(sourcecodes[idx])
                  safe_append(figure, :sourcecode, src) if src
                end
              # subfigures were dropped outright (#296): the walk had
              # no figure branch though the model maps it
              when "figure"
                sub = to_array(model_attr(figure_node, :figure) || [])[idx]
                append_subfigure_content(figure, sub) if sub
              # the figure key <dl> was dropped outright (#296)
              when "dl"
                dl_node = to_array(model_attr(figure_node, :dl) || [])[idx]
                append_figure_key(figure, dl_node) if dl_node
              when "key"
                k = to_array(model_attr(figure_node, :key) || [])[idx]
                k && to_array(model_attr(k, :dl)).each do |d|
                  append_figure_key(figure, d)
                end
              end
            end
          else
            # Fallback without element_order
            to_array(figure_node.image || []).each do |img|
              artwork = transform_image_to_artwork(img)
              safe_append(figure, :artwork, artwork) if artwork
            end

            to_array(figure_node.pre || []).each do |pre_node|
              artwork = transform_pre_to_artwork(pre_node)
              safe_append(figure, :artwork, artwork) if artwork
            end
          end

          # Figure source/citation (model_attr: a Subfigure model has
          # no source accessor — #296 crash)
          sources = model_attr(figure_node, :source)
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

        # v3 figure admits no nested figure: fold a subfigure's
        # artworks/sourcecode into the parent (the released path
        # promoted subfigures to sibling figures); each subfigure's
        # caption rides its first artwork as @name and its id as
        # @anchor, so no content is lost (#296)
        def append_subfigure_content(figure, sub_node)
          sub = transform_figure(sub_node)
          return unless sub

          if sub.is_a?(Rfcxml::V3::Sourcecode)
            safe_append(figure, :sourcecode, sub)
            return
          end

          arts = to_array(sub.artwork)
          if (first = arts.first)
            cap = sub.name && to_array(sub.name.content).join
            if cap && !cap.strip.empty? && first.name.to_s.empty?
              first.name = cap.strip
            end
            first.anchor ||= sub.anchor
          end
          arts.each { |a| safe_append(figure, :artwork, a) }
          to_array(sub.sourcecode).each do |s|
            safe_append(figure, :sourcecode, s)
          end
        end

        # v3 figure admits no dl: the key flattens into the postamble
        # as "term: definition" lines — text-at-minimum (#296)
        def append_figure_key(figure, dl_node)
          dts = to_array(model_attr(dl_node, :dt))
          dds = to_array(model_attr(dl_node, :dd))
          lines = dts.each_with_index.map do |dt, i|
            dd = dds[i]
            term = flatten_inline_text(dt).to_s.strip
            defn = dd ? flatten_inline_text(dd).to_s.strip : ""
            next if term.empty? && defn.empty?

            defn.empty? ? term : "#{term}: #{defn}"
          end.compact
          return if lines.empty?

          postamble = figure.postamble || Rfcxml::V3::Postamble.new
          postamble.content = to_array(postamble.content) + lines
          figure.postamble = postamble
        end

        def transform_pseudocode(figure_node)
          sc = pseudocode_sourcecodes(figure_node).first
          return transform_sourcecode(sc) if sc

          lines = pseudocode_lines(figure_node)
          # MODEL GAP (metanorma-document 0.2.9): FigureBlock maps
          # neither p nor sourcecode, so pseudocode content is
          # unreachable; nil falls back to the generic figure path,
          # which at least preserves the caption (metanorma-ietf#303)
          return nil if lines.empty?

          sourcecode = Rfcxml::V3::Sourcecode.new
          anchor_for(figure_node) and
            sourcecode.anchor = to_ncname(anchor_for(figure_node))
          sourcecode.content = [lines.join("\n")]
          sourcecode
        end

        def pseudocode_sourcecodes(figure_node)
          figure_node.respond_to?(:sourcecode) or return []
          to_array(figure_node.sourcecode || [])
        end

        def pseudocode_lines(figure_node)
          get_paragraphs(figure_node).each_with_object([]) do |p, lines|
            text = extract_paragraph_text(p)
            lines << "  #{text}" if text && !text.strip.empty?
          end
        end

        # NB the model maps the class XML attribute to :figure_class
        # (metanorma-ietf#303: probing :class_attr made this dead code)
        def pseudocode_figure?(figure_node)
          figure_node.respond_to?(:figure_class) &&
            figure_node.figure_class == "pseudocode"
        end

        def transform_image_to_artwork(img_node)
          artwork = Rfcxml::V3::Artwork.new

          # anchor (xrefs to the image dangled without it), align, and
          # width/height sizing are carried (#296, #305) — wired before
          # the SVG branches' early returns so every path keeps them
          if anchor_for(img_node)
            artwork.anchor = to_ncname(anchor_for(img_node))
          end
          align = model_attr(img_node, :align)
          artwork.align = align.to_s if align && !align.to_s.empty?
          # "auto" is the converter's no-sizing marker, not a size
          width = model_attr(img_node, :width)
          if width && !width.to_s.empty? && width.to_s != "auto"
            artwork.width = width.to_s
          end
          height = model_attr(img_node, :height)
          if height && !height.to_s.empty? && height.to_s != "auto"
            artwork.height = height.to_s
          end

          # the model maps the src XML attribute to :source (Media superclass)
          src = img_node.respond_to?(:source) ? img_node.source : nil
          src ||= img_node.target if img_node.respond_to?(:target)

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

          # v3 artwork has no title attribute — @name is its labelled
          # counterpart, and the respond_to?(:title=) branch was dead
          # code (#296)
          title = img_node.title
          if title && !title.to_s.empty? && artwork.name.to_s.empty?
            artwork.name = title.to_s
          end

          # a contentless, sourceless artwork is noise (WS3,
          # blocks_spec: raw inline <svg> parses to an empty image
          # entry — 0.2.9 model gap — and emitted a bare <artwork/>)
          if artwork.src.nil? &&
              (artwork.content.nil? || artwork.content.to_s.strip.empty?)
            return nil
          end

          artwork
        end

        def transform_pre_to_artwork(pre_node)
          artwork = Rfcxml::V3::Artwork.new
          artwork.type = "ascii-art"

          artwork.anchor = to_ncname(anchor_for(pre_node)) if anchor_for(pre_node)
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
          to_array(figure_node.note || []).each do |note_node|
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
