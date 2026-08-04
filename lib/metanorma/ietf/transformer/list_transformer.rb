# frozen_string_literal: true

module Metanorma
  module Ietf
    module Transformer
      module ListTransformer

        def transform_unordered_list(ul_node)
          ul = Rfcxml::V3::Ul.new
          ul.anchor = to_ncname(anchor_for(ul_node)) if anchor_for(ul_node)

          apply_list_attributes(ul, ul_node, %i[empty bare spacing indent])
          # the semantic carries bullet suppression as nobullet; the
          # released path renders it as empty (WS3, lists_spec)
          if ul.empty.nil? && ul_node.respond_to?(:nobullet) &&
              ul_node.nobullet.to_s == "true"
            ul.empty = "true"
          end

          to_array(ul_node.listitem || []).each do |item|
            li = transform_list_item(item)
            safe_append(ul, :li, li) if li
          end

          ul
        end

        def transform_ordered_list(ol_node)
          ol = Rfcxml::V3::Ol.new
          ol.anchor = to_ncname(anchor_for(ol_node)) if anchor_for(ol_node)

          ol_type = ol_node.type
          ol.type = map_ol_type(ol_type) if ol_type

          start_val = ol_node.start
          ol.start = start_val.to_s if start_val

          apply_list_attributes(ol, ol_node, %i[spacing indent group])

          to_array(ol_node.listitem || []).each do |item|
            li = transform_list_item(item)
            safe_append(ol, :li, li) if li
          end

          ol
        end

        def apply_list_attributes(target, source, attrs)
          attrs.each do |attr|
            next unless source.class.method_defined?(attr)
            val = source.public_send(attr)
            next if val.nil?
            target.public_send(:"#{attr}=", val.to_s) unless val.to_s.empty?
          end
        end

        def transform_list_item(item)
          li = Rfcxml::V3::Li.new

          text = item.text
          text = item.content_text if text.nil? || (text.is_a?(Array) && text.empty?)
          if text
            text_val = text.is_a?(Array) ? text.map { |t| ls_text(t) }.compact.join : ls_text(text)
            li.content = [text_val] unless text_val.nil? || text_val.empty?
          end

          get_paragraphs(item).each do |p|
            t = transform_paragraph(p)
            if t
              append_ordered(li, :t, t)
            end
          end

          to_array(item.unordered_lists || []).each do |ul|
            list = transform_unordered_list(ul)
            append_ordered(li, :ul, list) if list
          end

          to_array(item.ordered_lists || []).each do |ol|
            list = transform_ordered_list(ol)
            append_ordered(li, :ol, list) if list
          end

          dls = item.class.method_defined?(:definition_lists) ? item.definition_lists : nil
          dls = nil unless dls.is_a?(Array)
          if dls
            dls.each do |dl|
              list = transform_definition_list(dl)
              append_ordered(li, :dl, list) if list
            end
          end

          sourcecodes = item.class.method_defined?(:sourcecode) ? item.sourcecode : nil
          to_array(sourcecodes).each do |sc|
            src = transform_sourcecode(sc)
            append_ordered(li, :sourcecode, src) if src
          end

          li_t = li.t
          li_content = li.content
          if li_t.is_a?(Array) && !li_t.empty? && li_content.is_a?(Array) && li_content.all? { |c| c.to_s.strip.empty? }
            li.content = []
          end

          li
        end

        def transform_definition_list(dl_node)
          dl = Rfcxml::V3::Dl.new
          dl.anchor = to_ncname(anchor_for(dl_node)) if anchor_for(dl_node)

          apply_list_attributes(dl, dl_node, %i[newline spacing indent])

          dts = dl_node.dt
          dds = dl_node.dd

          dts = [dts] unless dts.is_a?(Array)
          dds = [dds] unless dds.is_a?(Array)

          dts.each_with_index do |dt, i|
            dt_elem = build_dt(dt)

            append_ordered(dl, :dt, dt_elem)

            dd = dds[i]
            next unless dd

            dd_elem = build_dd(dd)

            append_ordered(dl, :dd, dd_elem)
          end

          dl
        end

        def build_dt(dt)
          dt_elem = Rfcxml::V3::Dt.new
          dt_elem.anchor = to_ncname(anchor_for(dt)) if anchor_for(dt)

          src_order = dt.element_order
          if src_order && src_order.any?
            build_dt_interleaved(dt_elem, dt, src_order)
          else
            dt_text = extract_dt_text(dt)
            dt_elem.content = dt_text if dt_text && !dt_text.empty?
          end

          dt_elem
        end

        def build_dt_interleaved(dt_elem, dt_node, src_order)
          content_fragments = []
          counters = Hash.new(0)

          src_order.each do |e|
            if e.text?
              content_fragments << e.text_content
              track_text_order(dt_elem, e.text_content)
            else
              tag = e.element_tag
              idx = counters[tag]
              inline = build_dt_inline(dt_node, tag, idx)
              if inline
                if inline.is_a?(String)
                  content_fragments << inline
                  track_text_order(dt_elem, inline)
                else
                  coll_name = case tag
                              when "xref" then :xref
                              when "eref" then :eref
                              when "strong" then :strong
                              when "em" then :em
                              when "tt" then :tt
                              when "sub" then :sub
                              when "sup" then :sup
                              else nil
                              end
                  if coll_name
                    safe_append(dt_elem, coll_name, inline)
                    track_element_order(dt_elem, coll_name, inline)
                  end
                end
              end
              counters[tag] += 1
            end
          end

          dt_elem.content = content_fragments
        end

        def build_dt_inline(dt_node, tag, idx)
          simple = build_simple_inline(dt_node, tag, idx)
          return simple if simple

          case tag
          when "xref"
            coll = dt_node.xref
            return nil unless coll.is_a?(Array) && coll[idx]
            build_xref(coll[idx])
          when "eref"
            coll = dt_node.eref
            return nil unless coll.is_a?(Array) && coll[idx]
            build_eref_xref(coll[idx])
          else
            nil
          end
        end

        def extract_dt_text(dt)
          content = dt.content
          if content.is_a?(Array)
            text = content.join
            return text unless text.strip.empty?
          end

          ps = dt.p
          if ps.is_a?(Array) && !ps.empty?
            return ps.map { |p| ls_text(p) }.compact.join
          end

          ls_text(dt).to_s
        end

        def build_dd(dd)
          dd_elem = Rfcxml::V3::Dd.new

          dd_id = to_ncname(dd.id)
          dd_elem.anchor = dd_id if dd_id

          src_order = dd.element_order
          if src_order && src_order.any?
            build_dd_ordered(dd_elem, dd, src_order)
          else
            build_dd_unordered(dd_elem, dd)
          end

          dd_elem
        end

        # tag => [source_attr, target_attr]
        DD_CHILD_MAP = {
          "p"           => [:p,           :t],
          "ul"          => [:ul,          :ul],
          "ol"          => [:ol,          :ol],
          "dl"          => [:dl,          :dl],
          "sourcecode"  => [:sourcecode,  :sourcecode],
          "table"       => [:table,       :table],
        }.freeze

        # WS5 (rfc6350): appends must be ORDER-TRACKED — safe_append
        # puts children into separate per-tag collections and
        # serialisation then follows the model's schema order, which
        # displaced a dd's leading paragraph after its nested dl (the
        # "Special notes" entries). Same OrderTracker treatment as
        # table rows (th/td interleave).
        def build_dd_ordered(dd_elem, dd, src_order)
          counters = Hash.new(0)

          src_order.each do |e|
            if e.text?
              text = e.text_content
              next if text.nil? || text.strip.empty?
              dd_elem.content = to_array(dd_elem.content)
              dd_elem.content << text
              track_text_order(dd_elem, text)
              next
            end

            tag = e.element_tag
            idx = counters[tag]
            counters[tag] += 1

            if tag == "figure"
              build_dd_figure_at(dd_elem, dd, idx, ordered: true)
            else
              mapping = DD_CHILD_MAP[tag]
              build_dd_child(dd_elem, dd, idx, *mapping, ordered: true) if mapping
            end
          end
        end

        def build_dd_unordered(dd_elem, dd)
          ps = dd.p
          if ps.is_a?(Array)
            ps.each do |p|
              t = transform_paragraph(p)
              safe_append(dd_elem, :t, t) if t
            end
          end

          DD_CHILD_MAP.each do |_tag, (src_attr, target_attr)|
            to_array(dd.public_send(src_attr)).each do |child|
              result = dispatch_dd_child_transform(src_attr, child)
              safe_append(dd_elem, target_attr, result) if result
            end
          end

          to_array(dd.figure).each do |fig|
            f = transform_figure(fig)
            if f.is_a?(Rfcxml::V3::Figure)
              safe_append(dd_elem, :figure, f)
            elsif f.is_a?(Rfcxml::V3::Sourcecode)
              safe_append(dd_elem, :sourcecode, f)
            end
          end
        end

        def build_dd_child(dd_elem, dd, idx, src_attr, target_attr,
                           ordered: false)
          items = to_array(dd.public_send(src_attr))
          return unless items[idx]

          result = dispatch_dd_child_transform(src_attr, items[idx])
          return unless result

          if ordered
            append_ordered(dd_elem, target_attr, result)
          else
            safe_append(dd_elem, target_attr, result)
          end
        end

        def dispatch_dd_child_transform(src_attr, child)
          case src_attr
          when :p then transform_paragraph(child)
          when :ul then transform_unordered_list(child)
          when :ol then transform_ordered_list(child)
          when :dl then transform_definition_list(child)
          when :sourcecode then transform_sourcecode(child)
          when :table then transform_table(child)
          end
        end

        def build_dd_figure_at(dd_elem, dd, idx, ordered: false)
          figs = to_array(dd.figure)
          return unless figs[idx]

          f = transform_figure(figs[idx])
          attr = if f.is_a?(Rfcxml::V3::Figure) then :figure
                 elsif f.is_a?(Rfcxml::V3::Sourcecode) then :sourcecode
                 end
          return unless attr

          if ordered
            append_ordered(dd_elem, attr, f)
          else
            safe_append(dd_elem, attr, f)
          end
        end

        def map_ol_type(type)
          case type.to_s
          when "arabic" then "1"
          when "roman", "lowerroman" then "i"
          when "alphabet", "loweralpha" then "a"
          when "upperroman", "roman_upper" then "I"
          when "upperalphabet", "upperalpha", "alphabet_upper" then "A"
          else "1"
          end
        end
      end
    end
  end
end
