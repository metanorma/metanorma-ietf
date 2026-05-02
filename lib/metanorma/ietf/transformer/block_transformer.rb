# frozen_string_literal: true

require "lutaml/xml"

module Metanorma
  module Ietf
    module Transformer
      module BlockTransformer
        private

        INLINE_TAG_MAP = {
          "em" => "em",
          "strong" => "strong",
          "tt" => "tt",
          "sub" => "sub",
          "sup" => "sup",
          "eref" => "relref",
          "xref" => "xref",
          "link" => "eref",
          "stem" => "content",
          "br" => "br",
          "bcp14" => "bcp14",
          "span" => "bcp14",
          "index" => "iref",
          "concept" => "concept",
          "fn" => "fn",
          "bookmark" => "bookmark",
          "image" => "artwork",
        }.freeze

        ADMONITION_TYPES = {
          "danger" => "DANGER",
          "warning" => "WARNING",
          "caution" => "CAUTION",
          "important" => "IMPORTANT",
          "safety precautions" => "SAFETY PRECAUTIONS",
          "editorial note" => "EDITORIAL NOTE",
        }.freeze

        def transform_paragraph(p_node)
          t = Rfcxml::V3::Text.new
          t.anchor = to_ncname(p_node.id) if p_node.id

          if p_node.keep_with_next == "true"
            t.keep_with_next = "true"
          end

          if p_node.alignment
            t.indent = p_node.alignment
          end

          src_order = p_node.element_order

          if src_order && src_order.any?
            build_interleaved_content(t, p_node, src_order)
          else
            text = extract_paragraph_text(p_node)
            t.content = [text] unless text.nil? || text.empty?
          end

          t
        end

        def build_interleaved_content(text_elem, p_node, src_order)
          content_fragments = []
          rfc_order = []

          counters = Hash.new(0)
          prev_was_inline = false

          src_order.each_with_index do |e, _i|
            if e.text?
              content_fragments << e.text_content
              rfc_order << e
              prev_was_inline = false
            else
              tag = e.element_tag
              rfc_tag = INLINE_TAG_MAP[tag] || tag
              idx = counters[tag]

              inline_obj = build_inline_element(p_node, tag, idx)

              if inline_obj
                collection_name = rfc_tag.to_sym
                if inline_obj.is_a?(String)
                  content_fragments << inline_obj
                else
                  if prev_was_inline
                    content_fragments << " "
                    rfc_order << Lutaml::Xml::Element.new("Text", "")
                  end
                  safe_append(text_elem, collection_name, inline_obj)
                  rfc_order << Lutaml::Xml::Element.new("Element", rfc_tag)
                end
                counters[tag] += 1
                prev_was_inline = true
              else
                counters[tag] += 1
                prev_was_inline = false
              end
            end
          end

          text_elem.content = content_fragments
          text_elem.element_order = rfc_order if rfc_order.any?
        end

        def build_inline_element(p_node, tag, idx)
          case tag
          when "em"
            coll = p_node.em
            return nil unless coll.is_a?(Array) && coll[idx]
            em = Rfcxml::V3::Em.new
            val = ls_text(coll[idx])
            em.content = [val] if val && !val.empty?
            em
          when "strong"
            coll = p_node.strong
            return nil unless coll.is_a?(Array) && coll[idx]
            strong = Rfcxml::V3::Strong.new
            val = ls_text(coll[idx])
            strong.content = [val] if val && !val.empty?
            strong
          when "tt"
            coll = p_node.tt
            return nil unless coll.is_a?(Array) && coll[idx]
            tt = Rfcxml::V3::Tt.new
            val = ls_text(coll[idx])
            tt.content = [val] if val && !val.empty?
            tt
          when "sub"
            coll = p_node.sub
            return nil unless coll.is_a?(Array) && coll[idx]
            sub = Rfcxml::V3::Sub.new
            val = ls_text(coll[idx])
            sub.content = [val] if val && !val.empty?
            sub
          when "sup"
            coll = p_node.sup
            return nil unless coll.is_a?(Array) && coll[idx]
            sup = Rfcxml::V3::Sup.new
            val = ls_text(coll[idx])
            sup.content = [val] if val && !val.empty?
            sup
          when "eref"
            coll = p_node.eref
            return nil unless coll.is_a?(Array) && coll[idx]
            build_eref_xref(coll[idx])
          when "xref"
            coll = p_node.xref
            return nil unless coll.is_a?(Array) && coll[idx]
            build_xref(coll[idx])
          when "link"
            coll = p_node.link
            return nil unless coll.is_a?(Array) && coll[idx]
            build_link(coll[idx])
          when "span"
            coll = p_node.span
            return nil unless coll.is_a?(Array) && coll[idx]
            elem = coll[idx]
            return nil unless elem.class_attr == "bcp14"
            bcp = Rfcxml::V3::Bcp14.new
            val = ls_text(elem)
            bcp.content = val if val && !val.empty?
            bcp
          when "bcp14"
            coll = p_node.bcp14
            return nil unless coll.is_a?(Array) && coll[idx]
            bcp = Rfcxml::V3::Bcp14.new
            val = ls_text(coll[idx])
            bcp.content = val if val && !val.empty?
            bcp
          when "br"
            "\n"
          when "stem"
            coll = p_node.stem
            return nil unless coll.is_a?(Array) && coll[idx]
            build_stem_text(coll[idx])
          when "note"
            nil
          when "index"
            build_iref_from_model(p_node, idx)
          when "concept"
            coll = p_node.concept
            return nil unless coll.is_a?(Array) && coll[idx]
            build_concept(coll[idx])
          when "fn"
            coll = p_node.fn
            return nil unless coll.is_a?(Array) && coll[idx]
            build_footnote_reference(coll[idx])
          when "bookmark"
            nil # Bookmarks are not in RFC XML v3 schema
          when "image"
            build_inline_image(p_node, idx)
          when "smallcap", "strike", "underline", "keyword",
               "add", "del", "tab", "semx",
               "fmt-stem", "fmt-fn-label", "fmt-concept",
               "fmt-annotation-start", "fmt-annotation-end"
            build_dropped_inline(p_node, tag, idx)
          else
            nil
          end
        end

        def transform_note(note_node, container, note_counter: nil)
          aside = Rfcxml::V3::Aside.new
          aside.anchor = to_ncname(note_node.id) if note_node.id

          first = true
          get_paragraphs(note_node).each do |p|
            t = transform_paragraph(p)
            next unless t

            if first
              prefix = note_counter ? "NOTE #{note_counter}: " : "NOTE: "
              existing = t.content.is_a?(Array) ? t.content.join : t.content.to_s
              t.content = ["#{prefix}#{existing}"]
              first = false
            end

            safe_append(aside, :t, t)
          end

          aside
        end

        def transform_example(example_node, example_counter: nil)
          results = []
          first = true
          get_paragraphs(example_node).each do |p|
            t = transform_paragraph(p)
            next unless t

            if first
              prefix = example_counter ? "EXAMPLE #{example_counter}: " : "EXAMPLE: "
              existing = t.content.is_a?(Array) ? t.content.join : t.content.to_s
              t.content = ["#{prefix}#{existing}"]
              first = false
            end

            results << t
          end
          results
        end

        def transform_sourcecode(sc_node)
          sourcecode = Rfcxml::V3::Sourcecode.new
          sourcecode.anchor = to_ncname(sc_node.id) if sc_node.id

          lang = sc_node.lang
          sourcecode.type = lang if lang && !lang.to_s.empty?

          markers = sc_node.markers
          sourcecode.markers = markers if markers && !markers.to_s.empty?

          name = sc_node.filename
          sourcecode.name = name if name && !name.to_s.empty?

          content = ""
          c = sc_node.content
          if c
            content = c.is_a?(Array) ? c.join : c.to_s
          else
            body = sc_node.body
            if body
              bc = body.content
              content = bc.is_a?(Array) ? bc.join : bc.to_s
            end
          end

          sourcecode.content = [content] unless content.empty?

          sourcecode
        end

        def transform_quote(quote_node)
          blockquote = Rfcxml::V3::Blockquote.new

          author = quote_node.author
          if author
            author_text = author.text
            blockquote.quoted_from = author_text.to_s if author_text && !author_text.to_s.strip.empty?
          end

          source = quote_node.source
          if source && !source.to_s.strip.empty?
            citation = source.citeas
            blockquote.citation = citation.to_s if citation
            cite_uri = source.uri
            blockquote.cite = cite_uri.to_s if cite_uri && !cite_uri.to_s.empty?
          end

          get_paragraphs(quote_node).each do |p|
            t = transform_paragraph(p)
            safe_append(blockquote, :t, t) if t
          end

          blockquote
        end

        def transform_admonition(admon_node)
          aside = Rfcxml::V3::Aside.new
          aside.anchor = to_ncname(admon_node.id) if admon_node.id

          type_text = nil
          admon_type = admon_node.type
          if admon_type && !admon_type.to_s.empty?
            type_text = ADMONITION_TYPES[admon_type.to_s.downcase] || admon_type.to_s.upcase
          end

          if type_text
            heading = Rfcxml::V3::Text.new
            heading.keep_with_next = "true"
            heading.content = [type_text]
            safe_append(aside, :t, heading)
          end

          get_paragraphs(admon_node).each do |p|
            t = transform_paragraph(p)
            safe_append(aside, :t, t) if t
          end

          aside
        end

        def transform_formula(formula_node)
          results = []

          t = Rfcxml::V3::Text.new
          t.anchor = to_ncname(formula_node.id) if formula_node.id

          stem = formula_node.stem
          stem_text = nil
          if stem
            stem_text = build_stem_text(stem)
          end

          # Formula number from autonum
          autonum = formula_node.autonum
          label = nil
          if autonum && !autonum.to_s.strip.empty?
            num_str = autonum.to_s.strip
            label = num_str.match?(/\A\(.*\)\z/) ? num_str : "(#{num_str})"
          end

          if stem_text
            content = if label
                        "#{stem_text}    #{label}"
                      else
                        stem_text
                      end
            t.content = [content]
          end

          src_order = formula_node.element_order
          if src_order
            text_parts = src_order.select(&:text?).map(&:text_content).map(&:strip).reject(&:empty?)
            if text_parts.any? && label.nil?
              existing = t.content.is_a?(Array) ? t.content.join : t.content.to_s
              t.content = ["#{existing}    #{text_parts.first}"]
            end
          end

          results << t

          # Where clause from key/dl
          key_dl = formula_key_dl(formula_node)
          if key_dl
            where_t = Rfcxml::V3::Text.new
            where_t.keep_with_next = "true"
            where_t.content = ["where:"]
            results << where_t
            dl = transform_definition_list(key_dl)
            results << dl if dl
          end

          results
        end

        def formula_key_dl(formula_node)
          key = formula_node.key
          if key
            return key.dl if key.dl
          end

          formula_node.dl
        rescue NoMethodError
          nil
        end

        # Sourcecode callout annotations → aside
        def build_sourcecode_callouts(sc_node)
          annotations = sc_node.callout_annotations
          return [] unless annotations.is_a?(Array) && !annotations.empty?

          callouts = sc_node.callouts
          callouts = [callouts] unless callouts.is_a?(Array)
          callout_map = {}
          callouts.each { |c| callout_map[c.target.to_s] = c if c && c.target }

          aside = Rfcxml::V3::Aside.new
          key_heading = Rfcxml::V3::Text.new
          key_heading.keep_with_next = "true"
          key_heading.content = ["Key:"]
          safe_append(aside, :t, key_heading)

          dl = Rfcxml::V3::Dl.new
          annotations.each do |ann|
            dt = Rfcxml::V3::Dt.new
            callout = callout_map[ann.id.to_s] if ann.id
            dt_text = callout ? extract_text(callout) : ann.id.to_s
            dt.content = dt_text if dt_text && !dt_text.empty?
            safe_append(dl, :dt, dt)

            dd = Rfcxml::V3::Dd.new
            ps = ann.p
            if ps
              ps = [ps] unless ps.is_a?(Array)
              ps.each do |p|
                para = transform_paragraph(p)
                safe_append(dd, :t, para) if para
              end
            end
            safe_append(dl, :dd, dd)
          end

          safe_append(aside, :dl, dl)
          [aside]
        rescue NoMethodError
          []
        end

        def build_inline_note_aside(note_node)
          aside = Rfcxml::V3::Aside.new
          aside.anchor = to_ncname(note_node.id) if note_node.id

          get_paragraphs(note_node).each do |p|
            t = transform_paragraph(p)
            next unless t
            t.anchor = nil
            if aside.t.nil? || !aside.t.is_a?(Array) || aside.t.empty?
              existing_content = t.content.is_a?(Array) ? t.content.join : t.content.to_s
              t.content = ["NOTE: #{existing_content}"]
            end
            safe_append(aside, :t, t)
          end

          aside
        end

        def extract_inline_notes(paragraph)
          notes = paragraph.note
          notes = [notes] unless notes.is_a?(Array)
          notes.map { |n| build_inline_note_aside(n) }
        end

        def build_iref_from_model(p_node, idx)
          coll = p_node.index
          coll = [coll] unless coll.is_a?(Array)
          return nil unless coll[idx]

          elem = coll[idx]
          iref = Rfcxml::V3::Iref.new
          iref.item = elem.primary if elem.primary && !elem.primary.to_s.empty?
          iref.subitem = elem.secondary if elem.secondary && !elem.secondary.to_s.empty?
          iref
        end

        # ── Concept handling ────────────────────────────────────

        def build_concept(concept_elem)
          return nil unless concept_elem

          parts = []

          renderterms = concept_elem.renderterm
          if renderterms.is_a?(Array) && !renderterms.empty?
            em = Rfcxml::V3::Em.new
            em.content = [renderterms.join]
            parts << em
          elsif concept_elem.refterm.is_a?(Array) && !concept_elem.refterm.empty?
            em = Rfcxml::V3::Em.new
            em.content = [concept_elem.refterm.join]
            parts << em
          end

          ref_text = nil
          xrefs = concept_elem.xref
          if xrefs.is_a?(Array) && !xrefs.empty?
            target = xrefs.first.target
            ref_text = "[term defined in <xref target='#{target}'/>]"
          end

          if ref_text
            return parts.any? ? nil : ref_text
          end

          parts.first if parts.any?
        end

        # ── Footnote handling ───────────────────────────────────

        def build_footnote_reference(fn_elem)
          return nil unless fn_elem
          reference = fn_elem.reference
          if reference && !reference.empty?
            @footnote_counter += 1
            @seen_footnotes[reference] ||= @footnote_counter
            num = @seen_footnotes[reference]
            collect_footnote_content(num, fn_elem)
            "[#{num}]"
          else
            @footnote_counter += 1
            num = @footnote_counter
            collect_footnote_content(num, fn_elem)
            "[#{num}]"
          end
        end

        def collect_footnote_content(num, fn_elem)
          ps = fn_elem.p
          return unless ps
          ps = [ps] unless ps.is_a?(Array)
          return if ps.empty?
          return if @collected_footnotes.key?(num)

          paragraphs = ps.map do |p|
            text = extract_paragraph_text(p)
            text.strip unless text.nil? || text.strip.empty?
          end.compact

          @collected_footnotes[num] = paragraphs if paragraphs.any?
        end

        # ── Inline image handling ───────────────────────────────

        def build_inline_image(p_node, idx)
          coll = p_node.image
          return nil unless coll.is_a?(Array) && coll[idx]

          img = coll[idx]
          return nil unless img

          @image_counter += 1
          num = @image_counter

          artwork = transform_image_to_artwork(img)
          @queued_images << { artwork: artwork, number: num } if artwork

          "[IMAGE #{num}]"
        end

        # ── Dropped inline elements ─────────────────────────────

        def build_dropped_inline(p_node, tag, idx)
          case tag
          when "smallcap"
            coll = p_node.smallcap
            return nil unless coll.is_a?(Array) && coll[idx]
            ls_text(coll[idx]).to_s
          when "strike"
            coll = p_node.strike
            return nil unless coll.is_a?(Array) && coll[idx]
            ls_text(coll[idx]).to_s
          when "underline"
            coll = p_node.underline
            return nil unless coll.is_a?(Array) && coll[idx]
            ls_text(coll[idx]).to_s
          when "keyword"
            coll = p_node.keyword
            return nil unless coll.is_a?(Array) && coll[idx]
            coll[idx].to_s
          else
            nil
          end
        end
      end
    end
  end
end
