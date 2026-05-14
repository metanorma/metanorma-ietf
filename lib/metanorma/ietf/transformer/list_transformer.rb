# frozen_string_literal: true

module Metanorma
  module Ietf
    module Transformer
      module ListTransformer
        private

        def transform_unordered_list(ul_node)
          ul = Rfcxml::V3::Ul.new
          ul.anchor = to_ncname(ul_node.id) if ul_node.id

          apply_list_attributes(ul, ul_node, %i[empty bare spacing indent])

          to_array(ul_node.listitem || []).each do |item|
            li = transform_list_item(item)
            safe_append(ul, :li, li) if li
          end

          ul
        end

        def transform_ordered_list(ol_node)
          ol = Rfcxml::V3::Ol.new
          ol.anchor = to_ncname(ol_node.id) if ol_node.id

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
            val = source.send(attr)
            target.send(:"#{attr}=", val.to_s) if val && !val.to_s.empty?
          end
        rescue NoMethodError
          nil
        end

        def transform_list_item(item)
          li = Rfcxml::V3::Li.new

          text = item.text
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

          dls = item.definition_lists rescue nil
          dls = nil unless dls.is_a?(Array)
          if dls
            dls.each do |dl|
              list = transform_definition_list(dl)
              append_ordered(li, :dl, list) if list
            end
          end

          sourcecodes = item.sourcecode rescue nil
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
          dl.anchor = to_ncname(dl_node.id) if dl_node.id

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
          dt_elem.anchor = to_ncname(dt.id) if dt.id

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
          case tag
          when "xref"
            coll = dt_node.xref
            return nil unless coll.is_a?(Array) && coll[idx]
            build_xref(coll[idx])
          when "eref"
            coll = dt_node.eref
            return nil unless coll.is_a?(Array) && coll[idx]
            build_eref_xref(coll[idx])
          when "strong"
            coll = dt_node.strong
            return nil unless coll.is_a?(Array) && coll[idx]
            strong = Rfcxml::V3::Strong.new
            val = ls_text(coll[idx])
            strong.content = [val] if val && !val.empty?
            strong
          when "em"
            coll = dt_node.em
            return nil unless coll.is_a?(Array) && coll[idx]
            em = Rfcxml::V3::Em.new
            val = ls_text(coll[idx])
            em.content = [val] if val && !val.empty?
            em
          when "tt"
            coll = dt_node.tt
            return nil unless coll.is_a?(Array) && coll[idx]
            tt = Rfcxml::V3::Tt.new
            val = ls_text(coll[idx])
            tt.content = [val] if val && !val.empty?
            tt
          when "sub"
            coll = dt_node.sub
            return nil unless coll.is_a?(Array) && coll[idx]
            sub = Rfcxml::V3::Sub.new
            val = ls_text(coll[idx])
            sub.content = [val] if val && !val.empty?
            sub
          when "sup"
            coll = dt_node.sup
            return nil unless coll.is_a?(Array) && coll[idx]
            sup = Rfcxml::V3::Sup.new
            val = ls_text(coll[idx])
            sup.content = [val] if val && !val.empty?
            sup
          else
            nil
          end
        rescue NoMethodError
          nil
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

          ps = dd.p
          if ps.is_a?(Array)
            ps.each do |p|
              t = transform_paragraph(p)
              if t && dd_id && t.anchor == dd_id
                t.anchor = nil
              end
              safe_append(dd_elem, :t, t) if t
            end
          end

          dd_uls = dd.ul
          if dd_uls.is_a?(Array)
            dd_uls.each do |ul|
              list = transform_unordered_list(ul)
              safe_append(dd_elem, :ul, list) if list
            end
          end

          dd_ols = dd.ol
          if dd_ols.is_a?(Array)
            dd_ols.each do |ol|
              list = transform_ordered_list(ol)
              safe_append(dd_elem, :ol, list) if list
            end
          end

          dd_dls = dd.dl
          if dd_dls.is_a?(Array)
            dd_dls.each do |nested_dl|
              list = transform_definition_list(nested_dl)
              safe_append(dd_elem, :dl, list) if list
            end
          end

          dd_scs = dd.sourcecode
          if dd_scs.is_a?(Array)
            dd_scs.each do |sc|
              src = transform_sourcecode(sc)
              safe_append(dd_elem, :sourcecode, src) if src
            end
          end

          dd_elem
        end

        def map_ol_type(type)
          case type.to_s
          when "arabic" then "1"
          when "roman" then "i"
          when "alphabet" then "a"
          when "upperroman" then "I"
          when "upperalphabet", "upperalpha", "alphabet_upper" then "A"
          else "1"
          end
        end
      end
    end
  end
end
