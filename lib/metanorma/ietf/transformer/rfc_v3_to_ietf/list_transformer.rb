# frozen_string_literal: true

module Metanorma
  module Ietf
    module Transformer
      module RfcV3ToIetf
        # Transforms RFC XML v3 list elements (ul, ol, dl) into Metanorma
        # list model objects.
        module ListTransformer

          def transform_ul(ul_node)
            return nil unless ul_node

            list = Metanorma::Document::Components::Lists::UnorderedList.new(
              id: resolve_id(ul_node),
            )

            to_array(ul_node.li).each do |li_node|
              item = transform_li(li_node)
              list.listitem = to_array(list.listitem)
              list.listitem << item if item
            end

            list
          end

          def transform_ol(ol_node)
            return nil unless ol_node

            list = Metanorma::Document::Components::Lists::OrderedList.new(
              id: resolve_id(ol_node),
            )

            # Map ol type to metanorma type
            if ol_node.type && !ol_node.type.to_s.empty?
              list.type = ol_type_to_mn(ol_node.type)
            end

            list.start = ol_node.start if ol_node.start && !ol_node.start.to_s.empty?

            to_array(ol_node.li).each do |li_node|
              item = transform_li(li_node)
              list.listitem = to_array(list.listitem)
              list.listitem << item if item
            end

            list
          end

          def transform_dl(dl_node)
            return nil unless dl_node

            list = Metanorma::Document::Components::Lists::DefinitionList.new(
              id: resolve_id(dl_node),
            )

            dt_nodes = to_array(dl_node.dt)
            dd_nodes = to_array(dl_node.dd)

            dt_nodes.each_with_index do |dt_node, idx|
              dt = transform_dt(dt_node)
              OrderTracker.append_ordered(list, :dt, dt) if dt

              if dd_nodes[idx]
                dd = transform_dd(dd_nodes[idx])
                OrderTracker.append_ordered(list, :dd, dd) if dd
              end
            end

            list
          end

          def transform_li(li_node)
            return nil unless li_node

            item = Metanorma::Document::Components::Lists::ListItem.new(
              id: resolve_id(li_node),
            )

            # Text content
            text = extract_rfc_mixed_text(li_node)
            item.content_text = [text] if text && !text.empty?

            # Block children (paragraphs, sublists, etc.)
            to_array(li_node.t).each do |t_node|
              p = transform_t(t_node)
              item.paragraphs = to_array(item.paragraphs)
              item.paragraphs << p if p
            end

            to_array(li_node.ul).each do |ul|
              sub = transform_ul(ul)
              item.unordered_lists = to_array(item.unordered_lists)
              item.unordered_lists << sub if sub
            end

            to_array(li_node.ol).each do |ol|
              sub = transform_ol(ol)
              item.ordered_lists = to_array(item.ordered_lists)
              item.ordered_lists << sub if sub
            end

            to_array(li_node.dl).each do |dl|
              sub = transform_dl(dl)
              item.dl = sub if sub
            end

            to_array(li_node.sourcecode).each do |sc_node|
              sc = transform_sourcecode(sc_node)
              item.sourcecode = to_array(item.sourcecode)
              item.sourcecode << sc if sc
            end

            to_array(li_node.figure).each do |fig_node|
              fig = transform_figure(fig_node)
              item.figure = to_array(item.figure)
              item.figure << fig if fig
            end

            to_array(li_node.table).each do |tbl_node|
              tbl = transform_table(tbl_node)
              item.table = to_array(item.table)
              item.table << tbl if tbl
            end

            item
          end

          def transform_dt(dt_node)
            return nil unless dt_node

            dt = Metanorma::Document::Components::Lists::DtElement.new
            dt.id = resolve_id(dt_node) if dt_node.anchor && !dt_node.anchor.to_s.empty?

            text = extract_rfc_mixed_text(dt_node)
            dt.content = [text] if text && !text.empty?

            dt
          end

          def transform_dd(dd_node)
            return nil unless dd_node

            dd = Metanorma::Document::Components::Lists::DdElement.new
            dd.id = resolve_id(dd_node) if dd_node.anchor && !dd_node.anchor.to_s.empty?

            src_order = dd_node.element_order
            if src_order && src_order.any?
              transform_dd_ordered(dd, dd_node, src_order)
            else
              transform_dd_unordered(dd, dd_node)
            end

            dd
          end

          # tag => [src_attr, target_attr]
          DD_REVERSE_CHILD_MAP = {
            "t"          => [:t,          :p],
            "ul"         => [:ul,         :ul],
            "ol"         => [:ol,         :ol],
            "dl"         => [:dl,         :dl],
            "sourcecode" => [:sourcecode, :sourcecode],
            "table"      => [:table,      :table],
          }.freeze

          def transform_dd_ordered(dd, dd_node, src_order)
            counters = Hash.new(0)
            text_fragments = []

            src_order.each do |e|
              if e.text?
                text = e.text_content
                text_fragments << text if text && !text.strip.empty?
                next
              end

              tag = e.element_tag
              idx = counters[tag]
              counters[tag] += 1

              if tag == "figure"
                append_dd_child(dd, dd_node, idx, :figure, :figure)
              else
                mapping = DD_REVERSE_CHILD_MAP[tag]
                append_dd_child(dd, dd_node, idx, *mapping) if mapping
              end
            end

            unless text_fragments.empty?
              p = wrap_dd_text_as_paragraph(text_fragments.join.strip)
              dd.p = to_array(dd.p)
              dd.p.unshift(p) if p
            end
          end

          def transform_dd_unordered(dd, dd_node)
            to_array(dd_node.t).each do |t_node|
              p = transform_t(t_node)
              dd.p = to_array(dd.p)
              dd.p << p if p
            end

            if !dd.p.is_a?(Array) || dd.p.empty?
              text = extract_rfc_text(dd_node)
              if text && !text.empty?
                p = wrap_dd_text_as_paragraph(text)
                dd.p = [p] if p
              end
            end

            DD_REVERSE_CHILD_MAP.each do |_tag, (src_attr, target_attr)|
              to_array(dd_node.public_send(src_attr)).each do |child|
                result = dispatch_dd_child_transform(src_attr, child)
                dd.public_send(:"#{target_attr}=", to_array(dd.public_send(target_attr)))
                dd.public_send(target_attr) << result if result
              end
            end

            to_array(dd_node.figure).each do |fig_node|
              fig = transform_figure(fig_node)
              dd.figure = to_array(dd.figure)
              dd.figure << fig if fig
            end
          end

          def append_dd_child(dd, dd_node, idx, src_attr, target_attr)
            items = to_array(dd_node.public_send(src_attr))
            return unless items[idx]

            result = dispatch_dd_child_transform(src_attr, items[idx])
            dd.public_send(:"#{target_attr}=", to_array(dd.public_send(target_attr)))
            dd.public_send(target_attr) << result if result
          end

          def dispatch_dd_child_transform(src_attr, child)
            case src_attr
            when :t then transform_t(child)
            when :ul then transform_ul(child)
            when :ol then transform_ol(child)
            when :dl then transform_dl(child)
            when :sourcecode then transform_sourcecode(child)
            when :table then transform_table(child)
            when :figure then transform_figure(child)
            end
          end

          def wrap_dd_text_as_paragraph(text)
            return nil if text.nil? || text.strip.empty?
            Metanorma::Document::Components::Paragraphs::ParagraphBlock.new(text: [text.strip])
          end

          # Canonical Metanorma ol types (the vocabulary standoc emits and
          # the presentation layer's ol_label_template keys on)
          def ol_type_to_mn(type)
            case type.to_s
            when "1", "arabic" then "arabic"
            when "a", "loweralpha" then "alphabet"
            when "A", "upperalpha" then "alphabet_upper"
            when "i", "lowerroman" then "roman"
            when "I", "upperroman" then "roman_upper"
            else type.to_s
            end
          end
        end
      end
    end
  end
end
