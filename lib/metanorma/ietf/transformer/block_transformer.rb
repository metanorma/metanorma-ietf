# frozen_string_literal: true

module Metanorma
  module Ietf
    module Transformer
      module BlockTransformer

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
          t.anchor = to_ncname(anchor_for(p_node)) if anchor_for(p_node)

          # keep_with_next arrives as boolean true on some vintages
          # (WS3, blocks_spec); indent is the numeric indent attribute —
          # alignment has no v3 <t> counterpart and is dropped
          kwn = p_node.keep_with_next
          t.keep_with_next = "true" if kwn == "true" || kwn == true

          indent = model_attr(p_node, :indent)
          t.indent = indent.to_s if indent && !indent.to_s.empty?

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

          counters = Hash.new(0)
          prev_was_inline = false

          src_order.each_with_index do |e, _i|
            if e.text?
              content_fragments << e.text_content
              track_text_order(text_elem, e.text_content)
              prev_was_inline = false
            else
              tag = e.element_tag
              rfc_tag = INLINE_TAG_MAP[tag] || tag
              idx = counters[tag]

              inline_obj = build_inline_element(p_node, tag, idx)

              if inline_obj
                if inline_obj.is_a?(Array)
                  inline_obj.each do |part|
                    if part.is_a?(String)
                      content_fragments << part
                      track_text_order(text_elem, part)
                    else
                      part_tag = part.class.name.split("::").last
                        .downcase.to_sym
                      safe_append(text_elem, part_tag, part)
                      track_element_order(text_elem, part_tag, part)
                    end
                  end
                elsif inline_obj.is_a?(String)
                  content_fragments << inline_obj
                  track_text_order(text_elem, inline_obj)
                else
                  actual_tag = if inline_obj.is_a?(Rfcxml::V3::Xref) && rfc_tag == "relref"
                                 "xref"
                               else
                                 rfc_tag
                               end
                  collection_name = actual_tag.to_sym
                  if prev_was_inline
                    content_fragments << " "
                    track_text_order(text_elem, " ")
                  end
                  safe_append(text_elem, collection_name, inline_obj)
                  track_element_order(text_elem, collection_name, inline_obj)
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
        end

        def build_inline_element(p_node, tag, idx)
          simple = build_simple_inline(p_node, tag, idx)
          return simple if simple

          case tag
          when "eref"
            coll = p_node.eref
            return nil unless coll.is_a?(Array) && coll[idx]
            if @abstract_flatten
              flat = abstract_semx_rendering(p_node, coll[idx])
              return flat if flat
            end
            build_eref_xref(coll[idx])
          when "xref"
            coll = p_node.xref
            return nil unless coll.is_a?(Array) && coll[idx]
            if @abstract_flatten
              flat = abstract_semx_rendering(p_node, coll[idx])
              return flat if flat
            end
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

        # Notes render UNNUMBERED in RFC output (maintainer concession,
        # #233, 2026-07-23: RFC XML has no accommodation for numbered
        # notes). The shared presentation layer still stamps autonum for
        # all flavours; this flavour simply does not render it for notes.
        def transform_note(note_node, container)
          aside = Rfcxml::V3::Aside.new
          aside.anchor = to_ncname(anchor_for(note_node)) if anchor_for(note_node)

          first = true
          get_paragraphs(note_node).each do |p|
            t = transform_paragraph(p)
            next unless t

            if first
              prefix_first_text(t, "NOTE: ")
              first = false
            end

            safe_append(aside, :t, t)
          end

          # non-paragraph note bodies (WS3, blocks_spec: an aside came
          # out empty): carry dl/ul/ol, with a bare label paragraph
          # when no paragraph carried the NOTE: prefix
          blocks = {
            dl: to_array(model_attr(note_node, :dl)),
            ul: to_array(model_attr(note_node, :ul)),
            ol: to_array(model_attr(note_node, :ol)),
          }
          if blocks.values.any? { |a| !a.empty? } && first
            label = Rfcxml::V3::Text.new
            label.content = ["NOTE: "]
            safe_append(aside, :t, label)
          end
          blocks[:dl].each do |dl|
            list = transform_definition_list(dl)
            safe_append(aside, :dl, list) if list
          end
          blocks[:ul].each do |ul|
            list = transform_unordered_list(ul)
            safe_append(aside, :ul, list) if list
          end
          blocks[:ol].each do |ol|
            list = transform_ordered_list(ol)
            safe_append(aside, :ol, list) if list
          end

          aside
        end

        # B-1: content fragments are synced to ordered-serialization
        # entries (the set_text_ordered contract), so REPLACING the
        # content array desyncs it and the new value never serializes.
        # Prefix the first text fragment IN PLACE instead, preserving
        # array identity and order. A paragraph that starts with an
        # inline element (no leading text fragment) is left unprefixed
        # rather than desynced.
        def prefix_first_text(text_elem, prefix)
          content = text_elem.content
          if content.is_a?(Array)
            idx = content.index { |part| part.is_a?(String) }
            return if idx.nil? || idx > 0
            return if content[idx].start_with?("NOTE: ", "NOTE ")

            content[idx] = "#{prefix}#{content[idx]}"
          elsif content.is_a?(String)
            content.start_with?("NOTE: ", "NOTE ") and return
            text_elem.content = "#{prefix}#{content}"
          end
        end

        def block_autonum(node)
          node.respond_to?(:autonum) or return nil
          num = node.autonum.to_s.strip
          num.empty? ? nil : num
        end

        # The released shape (WS3, blocks_spec): a standalone label
        # paragraph — carrying the example's anchor, keepWithNext, the
        # autonumber, and an authored <name> — followed by the body
        # paragraphs. (The previous form folded the label into the
        # first body paragraph, losing anchor, name and keepWithNext.)
        def transform_example(example_node, example_counter: nil)
          counter = block_autonum(example_node) || example_counter
          results = []

          label = Rfcxml::V3::Text.new
          label.anchor = to_ncname(anchor_for(example_node)) if anchor_for(example_node)
          label.keep_with_next = "true"
          label_text = counter ? "EXAMPLE #{counter}" : "EXAMPLE"
          name_node = model_attr(example_node, :name)
          name_text = name_node && ls_text(name_node)
          label_text += ": #{name_text.strip}" if name_text && !name_text.strip.empty?
          label.content = [label_text]
          results << label

          # An example is not only paragraphs: sourcecode, figures,
          # lists and tables nest inside it too, and the
          # paragraphs-only walk silently dropped them all (F7 — seven
          # sourcecode blocks lost in one WS5 document). Walk the
          # source order; fall back to typed collections without it.
          src_order = example_node.respond_to?(:element_order) &&
            example_node.element_order
          if src_order.is_a?(Array) && src_order.any?
            counters = Hash.new(0)
            src_order.each do |e|
              next if e.text?
              tag = e.element_tag
              idx = counters[tag]
              counters[tag] += 1
              child = example_child_result(example_node, tag, idx)
              results << child if child
            end
          else
            get_paragraphs(example_node).each do |p|
              t = transform_paragraph(p)
              results << t if t
            end
            EXAMPLE_CHILD_ATTRS.each_value do |attr|
              next if attr == :paragraphs
              to_array(model_attr(example_node, attr)).each do |c|
                child = example_child_transform(attr, c)
                results << child if child
              end
            end
          end
          results
        end

        EXAMPLE_CHILD_ATTRS = {
          "p" => :paragraphs,
          "sourcecode" => :sourcecode,
          "figure" => :figure,
          "ul" => :ul,
          "ol" => :ol,
          "dl" => :dl,
          "table" => :table,
        }.freeze

        def example_child_result(example_node, tag, idx)
          attr = EXAMPLE_CHILD_ATTRS[tag] or return nil
          child = to_array(model_attr(example_node, attr))[idx] or return nil
          example_child_transform(attr, child)
        end

        def example_child_transform(attr, child)
          case attr
          when :paragraphs then transform_paragraph(child)
          when :sourcecode then transform_sourcecode(child)
          when :figure then transform_figure(child)
          when :ul then transform_unordered_list(child)
          when :ol then transform_ordered_list(child)
          when :dl then transform_definition_list(child)
          when :table then transform_table(child)
          end
        end

        # RFC XML collection slot for a transform_example result — the
        # example container is flattened, so each child must land in
        # its own typed collection on the enclosing section (F7)
        def example_result_tag(node)
          case node
          when Rfcxml::V3::Sourcecode then :sourcecode
          when Rfcxml::V3::Figure then :figure
          when Rfcxml::V3::Ul then :ul
          when Rfcxml::V3::Ol then :ol
          when Rfcxml::V3::Dl then :dl
          when Rfcxml::V3::Table then :table
          else :t
          end
        end

        def transform_sourcecode(sc_node)
          sourcecode = Rfcxml::V3::Sourcecode.new
          sourcecode.anchor = to_ncname(anchor_for(sc_node)) if anchor_for(sc_node)

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
          end
          # current Semantic XML nests the code text in sourcecode/body;
          # content then parses as an empty (but truthy) collection
          if content.strip.empty? && sc_node.respond_to?(:body) && sc_node.body
            bc = sc_node.body.content
            content = bc.is_a?(Array) ? bc.join : bc.to_s
          end

          # WS2 A-1: the code text arrives from raw-mapped attributes —
          # escaped markup on the current-schema body path (&amp;,
          # &lt;, embedded <br/>), once-decoded text on the old-vintage
          # content path (literal &) — and serialising escaped text
          # re-escapes it (&amp;amp;). Normalise conservatively:
          # <br/> becomes a newline, recognisable tags drop, and only
          # well-formed entities decode (CGI.unescapeHTML leaves a
          # bare "&caerbannog" alone, where a fragment parse ate it).
          # The former post-hoc sourcecode_cleanup pass is retired —
          # its character-level tag stripper ate genuine "<".
          # WS3 (cleanup_spec): the presentation layer leaves each
          # inline element in code text TWICE — the semantic original
          # immediately followed by its semx-wrapped rendering. Drop
          # originals that have a rendering, and render a bare
          # fmt-link as its target text (N4), before the generic
          # tag strip keeps the rendered text.
          content = content
            .gsub(%r{<(eref|xref|link)\b[^>]*/>\s*(?=<semx )}, "")
            .gsub(%r{<(eref|xref|link)\b[^>]*>.*?</\1>\s*(?=<semx )}m, "")
            .gsub(%r{<fmt-link\b[^>]*\btarget="([^"]+)"[^>]*/>}, '\1')
          content = content.gsub(%r{<br\s*/?>}, "\n")
            .gsub(%r{</?[a-zA-Z][a-zA-Z0-9:-]*(?:\s[^>]*)?/?>}, "")
          content = CGI.unescapeHTML(content)

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

          # v3 blockquote carries cite (URI) and quotedFrom only; the
          # citeas display goes to quotedFrom when no author claimed it
          # (WS3, blocks_spec latent crash: no citation= on the model)
          source = quote_node.source
          if source && !source.to_s.strip.empty?
            citation = model_attr(source, :citeas)
            if citation && !citation.to_s.strip.empty? && blockquote.quoted_from.nil?
              blockquote.quoted_from = citation.to_s
            end
            cite_uri = model_attr(source, :uri)
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
          aside.anchor = to_ncname(anchor_for(admon_node)) if anchor_for(admon_node)

          # an authored <name> takes precedence over the type label,
          # as the released path renders it (WS3, blocks_spec)
          type_text = nil
          name_node = model_attr(admon_node, :name)
          name_text = name_node && ls_text(name_node)
          if name_text && !name_text.strip.empty?
            type_text = name_text.strip
          else
            admon_type = admon_node.type
            if admon_type && !admon_type.to_s.empty?
              type_text = ADMONITION_TYPES[admon_type.to_s.downcase] || admon_type.to_s.upcase
            end
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
          t.anchor = to_ncname(anchor_for(formula_node)) if anchor_for(formula_node)

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

          content = nil
          if stem_text
            content = if label
                        "#{stem_text}    #{label}"
                      else
                        stem_text
                      end
          end

          src_order = formula_node.element_order
          if src_order
            text_parts = src_order.select(&:text?).map(&:text_content).map(&:strip).reject(&:empty?)
            if text_parts.any? && label.nil?
              content = "#{content}    #{text_parts.first}"
            end
          end

          # ordered serialization emits only element_order-registered
          # content; a bare content= assignment serializes as an empty <t/>
          if content && !content.strip.empty?
            OrderTracker.set_text_ordered(t, content)
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

          formula_node.dl if formula_node.class.method_defined?(:dl)
        end

        # Sourcecode callout annotations → aside
        def build_sourcecode_callouts(sc_node)
          return [] unless sc_node.class.method_defined?(:callout_annotations)

          annotations = sc_node.callout_annotations
          return [] unless annotations.is_a?(Array) && !annotations.empty?

          callouts = to_array(sc_node.callouts)
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
        end

        def build_inline_note_aside(note_node)
          aside = Rfcxml::V3::Aside.new
          aside.anchor = to_ncname(anchor_for(note_node)) if anchor_for(note_node)

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
          notes = to_array(paragraph.note)
          notes.map { |n| build_inline_note_aside(n) }
        end

        def build_iref_from_model(p_node, idx)
          coll = to_array(p_node.index)
          return nil unless coll[idx]

          elem = coll[idx]
          iref = Rfcxml::V3::Iref.new
          iref.item = elem.primary if elem.primary && !elem.primary.to_s.empty?
          iref.subitem = elem.secondary if elem.secondary && !elem.secondary.to_s.empty?
          iref
        end

        # ── Concept handling ────────────────────────────────────

        # Returns a String, a single inline object, or a mixed Array of
        # both (consumed part-by-part in build_interleaved_content) —
        # the term reference is a real Xref, never spliced markup text
        def build_concept(concept_elem)
          return nil unless concept_elem

          parts = []

          renderterms = concept_elem.renderterm
          refterms = concept_elem.refterm
          term = if renderterms.is_a?(Array) && !renderterms.empty?
                   renderterms.join
                 elsif refterms.is_a?(Array) && !refterms.empty?
                   refterms.join
                 end
          if term && !term.to_s.empty?
            em = Rfcxml::V3::Em.new
            em.content = [term.to_s]
            parts << em
          end

          xrefs = concept_elem.xref
          if xrefs.is_a?(Array) && !xrefs.empty? && xrefs.first.target
            xref = Rfcxml::V3::Xref.new
            xref.target = to_ncname(xrefs.first.target.to_s)
            parts << " " unless parts.empty?
            parts << "[term defined in "
            parts << xref
            parts << "]"
          end

          return nil if parts.empty?

          parts.length == 1 ? parts.first : parts
        end

        # ── Footnote handling ───────────────────────────────────

        def build_footnote_reference(fn_elem)
          return nil unless fn_elem
          reference = fn_elem.reference
          if reference && !reference.empty?
            # WS3 (footnotes_spec): increment only on first sight — the
            # unconditional bump consumed a number on every reuse,
            # producing [1],[1],[3]
            num = @seen_footnotes[reference] ||= (@footnote_counter += 1)
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
