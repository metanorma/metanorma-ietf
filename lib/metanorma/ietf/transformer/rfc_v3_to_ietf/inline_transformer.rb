# frozen_string_literal: true

module Metanorma
  module Ietf
    module Transformer
      module RfcV3ToIetf
        # Transforms RFC XML v3 inline elements into Metanorma inline model objects.
        module InlineTransformer
          private

          # Walk an rfcxml node's mixed-content children and populate
          # a metanorma-document mixed-content target (like ParagraphBlock).
          def transform_inline_children(source_node, target)
            return unless source_node

            if source_node.element_order.is_a?(Array) && !source_node.element_order.empty?
              transform_inline_by_order(source_node, target)
            else
              transform_inline_by_attributes(source_node, target)
            end
          end

          def transform_inline_by_order(source_node, target)
            # Track element indices for collections
            child_counts = Hash.new(0)

            source_node.element_order.each do |entry|
              if entry.text?
                text = entry.text_content || ""
                next if text.strip.empty?

                target.text = to_array(target.text)
                target.text << text
                OrderTracker.track_text(target, text)
              else
                attr_name = entry.name.to_sym
                children = to_array(source_node.public_send(attr_name))
                child = children[child_counts[attr_name]]
                child_counts[attr_name] += 1
                next unless child

                inline = transform_inline_element(attr_name, child)
                next unless inline

                mn_attr = rfc_to_mn_inline_attr(attr_name)
                next unless mn_attr

                target.public_send(:"#{mn_attr}=", []) unless target.public_send(mn_attr).is_a?(Array)
                target.public_send(mn_attr) << inline
                OrderTracker.track_element(target, mn_attr)
              end
            end
          end

          def transform_inline_by_attributes(source_node, target)
            # Text content
            text = extract_rfc_mixed_text(source_node)
            unless text.empty?
              target.text = [text]
            end

            # Strong
            to_array(source_node.strong).each do |s|
              el = Metanorma::Document::Components::Inline::StrongRawElement.new(
                text: [extract_rfc_mixed_text(s)],
              )
              target.strong = to_array(target.strong)
              target.strong << el
            end

            # Em
            to_array(source_node.em).each do |e|
              el = Metanorma::Document::Components::Inline::EmRawElement.new(
                text: [extract_rfc_mixed_text(e)],
              )
              target.em = to_array(target.em)
              target.em << el
            end

            # Tt
            to_array(source_node.tt).each do |t|
              el = Metanorma::Document::Components::Inline::TtElement.new(
                text: [extract_rfc_mixed_text(t)],
              )
              target.tt = to_array(target.tt)
              target.tt << el
            end

            # Sub
            to_array(source_node.sub).each do |s|
              el = Metanorma::Document::Components::Inline::SubElement.new(
                text: [extract_rfc_mixed_text(s)],
              )
              target.sub = to_array(target.sub)
              target.sub << el
            end

            # Sup
            to_array(source_node.sup).each do |s|
              el = Metanorma::Document::Components::Inline::SupElement.new(
                text: [extract_rfc_mixed_text(s)],
              )
              target.sup = to_array(target.sup)
              target.sup << el
            end

            # Xref
            to_array(source_node.xref).each do |x|
              xref = transform_xref(x)
              target.xref = to_array(target.xref)
              target.xref << xref if xref
            end

            # Eref
            to_array(source_node.eref).each do |e|
              eref = transform_eref(e)
              target.eref = to_array(target.eref)
              target.eref << eref if eref
            end

            # Bcp14
            to_array(source_node.bcp14).each do |b|
              el = Metanorma::Document::Components::Inline::Bcp14Element.new(
                text: [extract_rfc_text(b)],
              )
              target.bcp14 = to_array(target.bcp14)
              target.bcp14 << el
            end
          end

          def transform_inline_element(attr_name, node)
            case attr_name
            when :strong
              Metanorma::Document::Components::Inline::StrongRawElement.new(
                text: [extract_rfc_mixed_text(node)],
              )
            when :em
              Metanorma::Document::Components::Inline::EmRawElement.new(
                text: [extract_rfc_mixed_text(node)],
              )
            when :tt
              Metanorma::Document::Components::Inline::TtElement.new(
                text: [extract_rfc_mixed_text(node)],
              )
            when :sub
              Metanorma::Document::Components::Inline::SubElement.new(
                text: [extract_rfc_mixed_text(node)],
              )
            when :sup
              Metanorma::Document::Components::Inline::SupElement.new(
                text: [extract_rfc_mixed_text(node)],
              )
            when :xref
              transform_xref(node)
            when :eref
              transform_eref(node)
            when :bcp14
              Metanorma::Document::Components::Inline::Bcp14Element.new(
                text: [extract_rfc_text(node)],
              )
            end
          end

          def rfc_to_mn_inline_attr(rfc_attr)
            mapping = {
              strong: :strong,
              em: :em,
              tt: :tt,
              sub: :sub,
              sup: :sup,
              xref: :xref,
              eref: :eref,
              bcp14: :bcp14,
              br: :br,
              cref: nil, # handled by annotation_transformer
            }
            mapping[rfc_attr]
          end

          def transform_xref(xref_node)
            return nil unless xref_node

            target = xref_node.target
            return nil unless target

            xref = Metanorma::Document::Components::Inline::XrefElement.new(
              target: target,
            )

            text = extract_rfc_mixed_text(xref_node)
            xref.text = [text] if text && !text.empty?

            xref
          end

          def transform_eref(eref_node)
            return nil unless eref_node

            target = eref_node.target
            return nil unless target

            eref = Metanorma::Document::Components::Inline::ErefElement.new(
              citeas: target,
            )

            text = extract_rfc_text(eref_node)
            eref.text = [text] if text && !text.empty?

            eref
          end
        end
      end
    end
  end
end
