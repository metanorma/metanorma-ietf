# frozen_string_literal: true

module Metanorma
  module Ietf
    module Transformer
      module RfcV3ToIetf
        # Transforms RFC XML v3 list elements (ul, ol, dl) into Metanorma
        # list model objects.
        module ListTransformer
          private

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

            # dd can contain paragraphs
            to_array(dd_node.t).each do |t_node|
              p = transform_t(t_node)
              dd.p = to_array(dd.p)
              dd.p << p if p
            end

            # Fallback: extract text content directly
            if !dd.p.is_a?(Array) || dd.p.empty?
              text = extract_rfc_text(dd_node)
              if text && !text.empty?
                p = Metanorma::Document::Components::Paragraphs::ParagraphBlock.new(text: [text])
                dd.p = [p]
              end
            end

            dd
          end

          def ol_type_to_mn(type)
            case type.to_s
            when "1", "arabic" then "arabic"
            when "a", "loweralpha" then "loweralpha"
            when "A", "upperalpha" then "upperalpha"
            when "i", "lowerroman" then "lowerroman"
            when "I", "upperroman" then "upperroman"
            else type.to_s
            end
          end
        end
      end
    end
  end
end
