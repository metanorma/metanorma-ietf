# frozen_string_literal: true

module Metanorma
  module Ietf
    module Transformer
      module InlineTransformer
        private

        def extract_paragraph_text(paragraph)
          if paragraph.content
            c = paragraph.content
            case c
            when String then c
            when Array then c.join
            else c.to_s
            end
          elsif paragraph.text
            paragraph.text.is_a?(Array) ? paragraph.text.join : paragraph.text.to_s
          else
            ""
          end
        end

        def build_eref_xref(elem)
          bibitem_id = elem.bibitemid
          link_text = extract_eref_text(elem)

          if bibitem_id
            xref = Rfcxml::V3::Relref.new
            xref.target = bibitem_id.to_s

            section, relative = extract_eref_locality(elem)
            xref.section = section
            xref.relative = relative

            if elem.display_format
              xref.display_format = elem.display_format
            end

            xref.content = [link_text.to_s]
            xref
          else
            nil
          end
        end

        def extract_eref_locality(elem)
          stacks = elem.locality_stack
          stacks = [stacks] unless stacks.is_a?(Array)

          relative_attr = elem.relative.to_s

          if relative_attr && !relative_attr.empty?
            section_val = ""
            stacks.each do |stack|
              locals = stack.bib_locality
              locals = [locals] unless locals.is_a?(Array)
              locals.each do |loc|
                if loc.type == "section" && loc.reference_from
                  section_val = loc.reference_from.to_s
                end
              end
            end
            return [section_val, relative_attr]
          end

          return ["", ""] if stacks.empty?

          # Collect all section localities with connectives
          sections = []
          anchor_found = false

          stacks.each_with_index do |stack, i|
            locals = stack.bib_locality
            locals = [locals] unless locals.is_a?(Array)
            locals.each do |loc|
              if loc.type == "section" && loc.reference_from
                sections << loc.reference_from.to_s
              elsif loc.type == "anchor"
                anchor_found = true
              end
            end

            # Check for connective on this stack
            if i > 0
              connective = stack.connective
              if connective && sections.size >= 2
                case connective.to_s
                when "to"
                  sections[-2] = "#{sections[-2]}-#{sections[-1]}"
                  sections.pop
                when "and"
                  # Keep both sections - join later
                end
              end
            end
          end

          if anchor_found
            section_val = sections.join(", ")
            [section_val, "section"]
          else
            ["", ""]
          end
        end

        def extract_eref_text(elem)
          if elem.text && !elem.text.to_s.empty?
            return elem.text.to_s
          end

          if elem.alt && !elem.alt.to_s.empty?
            return elem.alt.to_s
          end

          ""
        end

        def build_xref(elem)
          target = elem.target
          return nil unless target

          xref = Rfcxml::V3::Xref.new
          xref.target = target.to_s

          format = elem.format
          xref.format = format if format && !format.to_s.empty?

          text = extract_xref_text(elem)
          text = text.strip if text && text.is_a?(String)
          xref.content = [text] if text && !text.empty?
          xref
        end

        def extract_xref_text(elem)
          text = elem.text
          return nil unless text
          text.is_a?(Array) ? text.join : text.to_s
        end

        def build_link(elem)
          target = elem.target
          return nil unless target

          ref = Rfcxml::V3::Eref.new
          ref.target = target.to_s
          text = ls_text(elem)
          ref.content = [text] if text && !text.empty?
          ref
        end

        def build_stem_text(elem)
          stem_type = elem.stem_type || "MathML"

          if stem_type == "MathML"
            content = nil

            ascii = elem.asciimath
            if ascii.is_a?(String) && !ascii.empty?
              content = ascii
            elsif ascii.is_a?(Array) && !ascii.empty?
              content = ascii.first
            end

            if content.nil?
              latex = elem.latexmath
              if latex.is_a?(String) && !latex.empty?
                content = latex
              elsif latex.is_a?(Array) && !latex.empty?
                content = latex.first
              end
            end

            if content.nil?
              math = elem.math
              if math
                mathml = math.to_xml
                if mathml && !mathml.empty?
                  ascii_text = plurimath_mathml_to_asciimath(mathml)
                  content = ascii_text if ascii_text && !ascii_text.empty?
                end
              end
            end

            return nil unless content
            delim = stem_delimiter(content)
            "#{delim} #{content} #{delim}"
          end

          nil
        end

        def stem_delimiter(content)
          delim = "$$"
          delim += "$" while content.include?(delim)
          delim
        end

        def plurimath_mathml_to_asciimath(mathml)
          require "plurimath"
          inst = Plurimath::Math.parse(mathml, :mathml)
          inst.to_asciimath
        rescue StandardError
          nil
        end

        def build_iref(elem)
          iref = Rfcxml::V3::Iref.new
          primary = extract_text(elem)
          iref.item = primary if primary
          iref
        end
      end
    end
  end
end
