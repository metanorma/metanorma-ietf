# frozen_string_literal: true

require "sterile"
require "htmlentities"
require_relative "order_tracker"

module Metanorma
  module Ietf
    module Transformer
      # Shared utilities for both forward and reverse transformers.
      #
      # Provides text extraction, ID normalization, collection helpers,
      # and organization building that both directions need.
      module Base
        # Types that use .text for their primary content
        TEXT_BASED_TYPES = [
          Metanorma::Document::Components::Inline::TitleWithAnnotationElement,
          Metanorma::Document::Components::Inline::EmRawElement,
          Metanorma::Document::Components::Inline::StrongRawElement,
          Metanorma::Document::Components::Inline::SupElement,
          Metanorma::Document::Components::Inline::TtElement,
          Metanorma::Document::Components::Inline::Bcp14Element,
          Metanorma::Document::Components::Inline::SpanElement,
          Metanorma::Document::Components::Inline::SmallCapElement,
          Metanorma::Document::Components::Inline::NameWithIdElement,
          Metanorma::Document::Components::Inline::ErefElement,
          Metanorma::Document::Components::Inline::XrefElement,
          Metanorma::Document::Components::Inline::FmtTitleElement,
          Metanorma::Document::Components::Inline::FmtXrefLabelElement,
          Metanorma::Document::Components::Inline::FmtNameElement,
          Metanorma::Document::Components::Inline::FmtFnLabelElement,
          Metanorma::Document::Components::Inline::FmtSourcecodeElement,
          Metanorma::Document::Components::Inline::FmtConceptElement,
          Metanorma::Document::Components::Inline::FmtXrefElement,
          Metanorma::Document::Components::Inline::SemxElement,
          Metanorma::Document::Components::Inline::BiblioTagElement,
          Metanorma::Document::Components::Inline::DisplayTextElement,
          Metanorma::Document::Components::Inline::VariantTitleElement,
        ].freeze

        # Extract plain text from a metanorma-document value.
        # Handles LocalizedString, FormattedString, inline elements, arrays.
        def ls_text(obj)
          return nil unless obj
          return obj if obj.is_a?(String)
          return obj.map { |o| ls_text(o) }.compact.join if obj.is_a?(Array)

          if obj.is_a?(Metanorma::Document::Components::DataTypes::LocalizedString) ||
             obj.is_a?(Metanorma::Document::Components::DataTypes::FormattedString)
            val = obj.value
            return val.is_a?(Array) ? val.join : val.to_s
          end

          if obj.is_a?(Metanorma::Document::Relaton::DocumentIdentifier)
            return obj.id.to_s
          end

          if TEXT_BASED_TYPES.any? { |t| obj.is_a?(t) }
            t = obj.text
            return t.is_a?(Array) ? t.join : t.to_s
          end

          c = obj.content
          return c.is_a?(Array) ? c.join : c.to_s if c

          t = obj.text
          return t.is_a?(Array) ? t.join : t.to_s if t

          obj.to_s
        end

        def extract_text(node)
          return "" unless node
          result = ls_text(node)
          result.is_a?(String) ? result.strip : ""
        end

        # Get the anchor/id for a node
        def anchor_for(node)
          node.anchor || node.id || node.semx_id
        end

        # Sanitize an id to be a valid NCName (for XML anchors)
        def to_ncname(id)
          return nil unless id
          id = id.to_s.strip
          return nil if id.empty?
          id = "_" + id unless id.match?(/\A[a-zA-Z_]/)
          id.gsub(/[^a-zA-Z0-9._\-]/, "_")
        end

        # Coerce a value into an Array.
        def to_array(val)
          return [] if val.nil?
          val.is_a?(Array) ? val : [val]
        end

        # Build an Rfcxml::V3::Organization from a metanorma-document organization node.
        def build_rfc_organization(org_node)
          org = Rfcxml::V3::Organization.new
          name_text = extract_text(to_array(org_node.name).first)
          org.content = [name_text] if name_text && !name_text.empty?

          abbrev = org_node.abbreviation
          if abbrev
            abbrev_text = abbrev.to_s.strip
            org.abbrev = abbrev_text if abbrev_text && !abbrev_text.empty?
          end

          if name_text && !name_text.empty?
            ascii = Sterile.transliterate(name_text)
            org.ascii = ascii unless ascii == name_text
          end

          org
        end

        # Build a Metanorma::Document::Relaton::Organization from an rfcxml Organization.
        def build_mn_organization(rfc_org)
          org = Metanorma::Document::Relaton::Organization.new
          name_text = extract_rfc_text(rfc_org)
          if name_text && !name_text.empty?
            ls = Metanorma::Document::Relaton::LocalizedName.new(
              content: [name_text],
            )
            org.name = [ls]
          end
          org.abbreviation = rfc_org.abbrev if rfc_org.abbrev && !rfc_org.abbrev.to_s.empty?
          org
        end

        # Extract plain text from an rfcxml model object.
        def extract_rfc_text(node)
          return "" unless node
          return node.to_s.strip if node.is_a?(String)
          return node.map { |n| extract_rfc_text(n) }.join if node.is_a?(Array)

          content = node.content
          if content
            return content.is_a?(Array) ? content.map(&:to_s).join.strip : content.to_s.strip
          end

          text = node.text
          if text
            return text.is_a?(Array) ? text.map(&:to_s).join.strip : text.to_s.strip
          end

          node.to_s.strip
        end

        # Extract all text content from a mixed-content rfcxml node,
        # walking inline elements for their text.
        def extract_rfc_mixed_text(node)
          return "" unless node
          return node.to_s if node.is_a?(String)
          return node.map { |n| extract_rfc_mixed_text(n) }.join if node.is_a?(Array)

          # For nodes with element_order (mixed content), walk the order
          if node.element_order.is_a?(Array) && !node.element_order.empty?
            parts = []
            node.element_order.each_with_index do |entry, idx|
              if entry.text?
                parts << (entry.text_content || "")
              elsif entry.element?
                # Find the corresponding child element(s)
                attr_name = entry.name.to_sym
                children = node.public_send(attr_name)
                children = [children] unless children.is_a?(Array)
                child = children.is_a?(Array) ? children[idx] : children
                if child
                  parts << extract_rfc_mixed_text(child)
                end
              end
            end
            return parts.join.strip
          end

          # Fallback: concatenate content and text
          c = node.content
          c = c.is_a?(Array) ? c.join : c.to_s if c
          return c.strip if c && !c.strip.empty?

          ""
        rescue NoMethodError
          ""
        end
      end
    end
  end
end
