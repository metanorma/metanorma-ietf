# frozen_string_literal: true

module Metanorma
  module Ietf
    module Transformer
      module InlineTransformer

        def extract_paragraph_text(paragraph)
          text = paragraph.text
          if text && !Array(text).empty?
            text.is_a?(Array) ? text.join : text.to_s
          else
            ""
          end
        end

        def build_eref_xref(elem)
          bibitem_id = elem.bibitemid
          link_text = extract_eref_text(elem)

          return nil unless bibitem_id

          section, relative = extract_eref_locality(elem)

          # WS3 (cleanup_spec): the RFC XML abstract is standalone
          # metadata (reused outside the document), so the released
          # path flattens its cross-references to text — display-text
          # if authored, else citeas + locality label. This is the
          # SEMANTIC FALLBACK of the fmt-consumption exception (see
          # abstract_semx_rendering): the preferred wording is the
          # presentation rendering; this branch serves when no semx
          # rendering is reachable. Nested display-text markup
          # flattens to plain text here (the old path kept <tt>; a
          # string is what the mixed-content walk can carry).
          if @abstract_flatten
            text = inline_flat_text(elem, link_text)
            if text.empty?
              citeas = model_attr(elem, :citeas)
              citeas = citeas.join if citeas.is_a?(Array)
              text = citeas.to_s
              text += ", Section #{section}" unless section.to_s.empty?
            end
            return text.empty? ? nil : text
          end

          if section && !section.to_s.empty?
            # B-3: the released path (and current xml2rfc, which dropped
            # <relref>) express section references as <xref section=
            # sectionFormat=>
            xref = Rfcxml::V3::Xref.new
            xref.target = to_ncname(bibitem_id.to_s)
            xref.section = section
            xref.relative = relative unless relative.to_s.empty?
            elem.display_format and xref.section_format = elem.display_format
            xref.content = [link_text.to_s] unless link_text.to_s.empty?
            xref
          else
            # No section info — plain <xref>; relative= and
            # sectionFormat= still pass through when authored (WS3,
            # inline_spec — the released path emits them regardless of
            # a section value)
            xref = Rfcxml::V3::Xref.new
            xref.target = to_ncname(bibitem_id.to_s)
            xref.relative = relative unless relative.to_s.empty?
            elem.display_format and xref.section_format = elem.display_format
            xref.content = [link_text.to_s] unless link_text.to_s.empty?
            xref
          end
        end

        def extract_eref_locality(elem)
          stacks = to_array(elem.locality_stack)

          relative_attr = elem.relative.to_s

          if relative_attr && !relative_attr.empty?
            section_val = ""
            stacks.each do |stack|
              to_array(stack.bib_locality).each do |loc|
                if loc.type == "section" && loc.reference_from
                  section_val = loc.reference_from.to_s
                end
              end
            end
            return [section_val, relative_attr]
          end

          return ["", ""] if stacks.empty?

          # B-3 + WS3 (inline_spec): the released path derives section=
          # from shared isodoc eref_localities and strips the leading
          # Section/Clause word; that carrier (fmt-eref) is
          # model-ghosted, so this is an interim local rendering of the
          # same grammar — per-locality "<Type> <from>[–<to>]" labels
          # ("whole" → "Whole of text"; anchor localities skipped),
          # localities within a stack joined with ", ", stacks joined
          # by their connective, then the leading Section/Clause label
          # stripped. Consuming fmt-eref is the DRY-clean future path
          # (0.4.x ledger).
          parts = []
          stacks.each_with_index do |stack, i|
            labels = to_array(stack.bib_locality).filter_map do |loc|
              next if loc.type.to_s == "anchor"

              eref_locality_label(loc)
            end
            next if labels.empty?

            if i.positive?
              conn = stack.connective.to_s
              parts << (conn.empty? ? ", " : " #{conn} ")
            end
            parts << labels.join(", ")
          end
          section = parts.join
            .sub(/\A\s*(Sections?|Clauses?)\s*/, "").strip.sub(/\A, /, "")
          [section, ""]
        end

        def eref_locality_label(loc)
          type = loc.type.to_s
          return "Whole of text" if type == "whole"

          from = loc.reference_from&.to_s
          to = loc.reference_to&.to_s
          num = from.to_s
          num += "–#{to}" if to && !to.empty?
          return nil if num.empty?

          label = type.capitalize
          %w[Section Clause].include?(label) ? "#{label} #{num}" : "#{label} #{num}"
        end

        def extract_eref_text(elem)
          # text arrives as an Array of fragments on some vintages —
          # join it; to_s on the array produced inspect strings like
          # ["A"] in output (WS3, inline_spec)
          t = elem.text
          t = t.join if t.is_a?(Array)
          return t.to_s if t && !t.to_s.empty?

          a = elem.alt
          a = a.join if a.is_a?(Array)
          return a.to_s if a && !a.to_s.empty?

          ""
        end

        # EXCEPTION to the general fmt-/semx avoidance rule
        # (user-ratified 2026-07-31, see qa-plan): the transformer
        # otherwise ignores fmt-/semx and works from semantic data,
        # but xref smoothing — rendering a cross-reference as its
        # citation text — is a core presentation-XML function, and
        # xref processing in general is deliberately entrusted to
        # the presentation layer (the shared, flavour-aware citation
        # grammar lives there). So the abstract flatten prefers the
        # presentation layer's own rendering: the paragraph carries
        # a semx sibling per cross-reference (matched by source id)
        # whose fmt-xref text is the full rendered label incl.
        # locality ("ISO 712, Section 3.1") — re-deriving that
        # wording locally is the reimplementation the DRY criterion
        # forbids. Exception constraints: text-only (never
        # structure), with the semantic fallback below (falls back
        # to nil so the builders' local flatten — display-text /
        # citeas — applies). Nested markup inside the fmt-xref text
        # is still ghosted (WS3, cleanup_spec; semx survives on this
        # vintage's paragraph model).
        def abstract_semx_rendering(p_node, elem)
          sid = model_attr(elem, :id).to_s
          return nil if sid.empty? || !p_node.respond_to?(:semx)

          to_array(p_node.semx).each do |s|
            next unless model_attr(s, :source).to_s == sid

            to_array(model_attr(s, :fmt_xref)).each do |fx|
              t = fx.respond_to?(:text) ? [fx.text].flatten.compact.join : ""
              # rendering artifacts have no place in flattened text:
              # the label's NBSP would end up u-wrapped (N11), and the
              # locality join doubles a space
              t = t.tr("\u{00A0}", " ").squeeze(" ")
              return t unless t.strip.empty?
            end
          end
          nil
        end

        # display-text (own text) plus the texts of nested simple
        # inline children, in that order — for the abstract flatten
        def inline_flat_text(elem, own_text)
          parts = [own_text.to_s]
          %w[em strong tt sub sup].each do |t|
            next unless elem.respond_to?(t)

            to_array(elem.public_send(t)).each { |c| parts << ls_text(c).to_s }
          end
          parts.reject(&:empty?).join
        end

        def build_xref(elem)
          target = elem.target
          return nil unless target

          if @abstract_flatten
            text = inline_flat_text(elem, extract_xref_text(elem))
            return text.empty? ? nil : text
          end

          xref = Rfcxml::V3::Xref.new
          # sanitised like element anchors, so IDREFs stay consistent
          # (#302: '#'-carrying anchors produced dangling targets)
          xref.target = to_ncname(target.to_s)

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
            # The source notation carriers (Asciiml/Latexml) are model
            # objects exposing only :value — not Strings — so they must
            # be unwrapped here, not just type-checked (F8: falling
            # through to the MathML re-serialisation altered notation)
            content = stem_source_text(model_attr(elem, :asciimath))
            content ||= stem_source_text(model_attr(elem, :latexmath))

            if content.nil?
              math = model_attr(elem, :math)
              math = math.first if math.is_a?(Array)
              if math
                mathml = math.to_xml
                if mathml && !mathml.empty?
                  ascii_text = plurimath_mathml_to_asciimath(mathml)
                  content = ascii_text if ascii_text && !ascii_text.empty?
                end
              end
            end

            return nil unless content
            # asciimath/latexmath carriers may hold element objects
            # rather than strings on some vintages (WS3, inline_spec)
            content = ls_text(content) unless content.is_a?(String)
            return nil if content.nil? || content.empty?
            delim = stem_delimiter(content)
            # explicit return: without it the if-expression value is
            # discarded and the trailing nil is what the method returns
            return "#{delim} #{content} #{delim}"
          end

          # AsciiMath / LaTeX stems carry their source text directly
          # (WS3, table_spec: the MathML-only branch dropped them)
          content = ls_text(elem)
          content = content&.strip
          return nil if content.nil? || content.empty?

          delim = stem_delimiter(content)
          "#{delim} #{content} #{delim}"
        end

        def stem_source_text(carrier)
          carrier = carrier.first if carrier.is_a?(Array)
          return nil unless carrier

          text = if carrier.is_a?(String)
                   carrier
                 elsif carrier.respond_to?(:value)
                   v = carrier.value
                   v.is_a?(Array) ? v.join : v
                 else
                   ls_text(carrier)
                 end
          text = text.to_s
          text.empty? ? nil : text
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

        # <index><primary>/<secondary> map to iref item/subitem (WS3,
        # inline_spec — only the flat text made it through before).
        # The primary="true" ATTRIBUTE is unreachable: the model's
        # :primary accessor is claimed by the child element
        # (0.2.9 ledger).
        def build_iref(elem)
          iref = Rfcxml::V3::Iref.new
          prim = model_attr(elem, :primary)
          prim = prim.first if prim.is_a?(Array)
          item = prim && ls_text(prim)
          item = extract_text(elem) if item.nil? || item.to_s.empty?
          iref.item = item if item && !item.to_s.empty?

          sec = model_attr(elem, :secondary)
          sec = sec.first if sec.is_a?(Array)
          sub = sec && ls_text(sec)
          iref.subitem = sub if sub && !sub.to_s.empty?
          iref
        end
      end
    end
  end
end
