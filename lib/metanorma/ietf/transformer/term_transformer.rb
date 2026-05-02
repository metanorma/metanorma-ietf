# frozen_string_literal: true

module Metanorma
  module Ietf
    module Transformer
      module TermTransformer
        private

        def transform_terms_section(terms_node)
          section = Rfcxml::V3::Section.new
          section.anchor = to_ncname(terms_node.id) if terms_node.id

          title = terms_node.title
          if title
            name = Rfcxml::V3::Name.new
            name_text = ls_text(title)
            name.content = [name_text] if name_text && !name_text.empty?
            section.name = name unless name.content.nil? || name.content.empty?
          end

          ps = terms_node.p
          if ps
            ps = [ps] unless ps.is_a?(Array)
            ps.each do |p|
              t = transform_paragraph(p)
              safe_append(section, :t, t) if t
            end
          end

          terms = terms_node.term
          terms = [terms] unless terms.is_a?(Array)
          terms.each do |term|
            term_sec = transform_term(term)
            safe_append(section, :section, term_sec) if term_sec
          end

          nested = terms_node.terms
          nested = [nested] unless nested.is_a?(Array)
          nested.each do |ts|
            sec = transform_terms_section(ts)
            safe_append(section, :section, sec) if sec
          end

          clauses = terms_node.clause
          if clauses
            clauses = [clauses] unless clauses.is_a?(Array)
            clauses.each do |cl|
              sec = transform_clause(cl)
              safe_append(section, :section, sec) if sec
            end
          end

          section
        end

        def transform_term(term_node)
          section = Rfcxml::V3::Section.new
          section.anchor = to_ncname(term_node.id) if term_node.id

          preferred = term_node.preferred
          preferred = [preferred] unless preferred.is_a?(Array)

          if preferred.first
            name = Rfcxml::V3::Name.new
            name_text = extract_term_name(preferred.first)
            name.content = [name_text] if name_text && !name_text.empty?
            section.name = name unless name.content.nil? || name.content.empty?
          end

          # Render admitted designations
          admitted = term_node.admitted rescue nil
          if admitted
            admitted = [admitted] unless admitted.is_a?(Array)
            admitted.each do |adm|
              term_text = extract_term_name(adm)
              next if term_text.nil? || term_text.empty?
              t = Rfcxml::V3::Text.new
              t.content = [term_text]
              safe_append(section, :t, t)
            end
          end

          # Render deprecated designations
          deprecated = term_node.deprecated rescue nil
          if deprecated
            deprecated = [deprecated] unless deprecated.is_a?(Array)
            deprecated.each do |dep|
              term_text = extract_term_name(dep)
              next if term_text.nil? || term_text.empty?
              t = Rfcxml::V3::Text.new
              t.content = ["DEPRECATED: #{term_text}"]
              safe_append(section, :t, t)
            end
          end

          # Definition paragraphs — wrap multiple in ordered list
          definition_paragraphs = get_paragraphs(term_node)
          if definition_paragraphs.size > 1
            first_para = true
            ol = Rfcxml::V3::Ol.new
            definition_paragraphs.each_with_index do |p, idx|
              li = Rfcxml::V3::Li.new
              t = transform_paragraph(p)
              next unless t

              if first_para
                domain = term_node.domain
                if domain
                  domain_text = domain.is_a?(String) ? domain : ls_text(domain)
                  if domain_text && !domain_text.empty?
                    existing = t.content.is_a?(Array) ? t.content.join : t.content.to_s
                    t.content = ["&lt;#{domain_text}&gt; #{existing}"]
                  end
                end
                first_para = false
              end

              safe_append(li, :t, t) if t
              safe_append(ol, :li, li)
            end
            safe_append(section, :ol, ol)
          else
            first_para = true
            definition_paragraphs.each do |p|
              t = transform_paragraph(p)
              next unless t

              if first_para
                domain = term_node.domain
                if domain
                  domain_text = domain.is_a?(String) ? domain : ls_text(domain)
                  if domain_text && !domain_text.empty?
                    existing = t.content.is_a?(Array) ? t.content.join : t.content.to_s
                    t.content = ["&lt;#{domain_text}&gt; #{existing}"]
                  end
                end
                first_para = false
              end

              safe_append(section, :t, t) if t
            end
          end

          # Definition lists within term
          term_dls = term_node.definition_lists rescue nil
          if term_dls
            term_dls = [term_dls] unless term_dls.is_a?(Array)
            term_dls.each do |dl|
              list = transform_definition_list(dl)
              safe_append(section, :dl, list) if list
            end
          end

          # Examples within terms
          examples = term_node.examples rescue nil
          if examples
            examples = [examples] unless examples.is_a?(Array)
            examples.each_with_index do |ex, idx|
              ts = transform_example(ex, example_counter: idx + 1)
              ts.each { |_t| safe_append(section, :t, _t) }
            end
          end

          # Term notes with numbering
          notes = term_node.notes
          notes = [notes] unless notes.is_a?(Array)
          notes.each_with_index do |note, idx|
            aside = transform_note(note, section, note_counter: idx + 1)
            safe_append(section, :aside, aside) if aside
          end

          # Term sources → <t>[SOURCE: ...]</t>
          sources = term_node.source
          sources = [sources] unless sources.is_a?(Array)
          sources.each do |src|
            t = transform_term_source(src)
            safe_append(section, :t, t) if t
          end

          # Related terms
          related_list = term_node.related
          related_list = [related_list] unless related_list.is_a?(Array)
          related_list.each do |rel|
            t = transform_related_term(rel)
            safe_append(section, :t, t) if t
          end

          # Nested terms
          nested = term_node.term
          nested = [nested] unless nested.is_a?(Array)
          nested.each do |t|
            sec = transform_term(t)
            safe_append(section, :section, sec) if sec
          end

          section
        end

        def extract_term_name(designation)
          return "" unless designation

          # Check for expression designation
          expr = designation.expression
          if expr
            return ls_text(expr.name || expr)
          end

          # Check for letter-symbol designation
          letter = designation.letter_symbol rescue nil
          if letter
            return extract_letter_symbol_text(letter)
          end

          # Check for graphical-symbol designation
          graphical = designation.graphical_symbol rescue nil
          if graphical
            return "[graphical symbol]"
          end

          ls_text(designation) || ""
        rescue NoMethodError
          ls_text(designation) || ""
        end

        def extract_letter_symbol_text(letter_symbol)
          stem = letter_symbol.stem
          if stem
            text = build_stem_text(stem)
            return text if text && !text.empty?
          end

          text = letter_symbol.text
          if text
            text = [text] unless text.is_a?(Array)
            return text.join unless text.empty?
          end

          ""
        rescue NoMethodError
          ""
        end

        def transform_term_source(source)
          return nil unless source

          text = "[SOURCE: "

          origin = source.origin
          if origin
            target = origin.bibitemid rescue nil
            if target
              text += "<xref target='#{target}' section='' relative=''/>"
            else
              text += ls_text(origin).to_s
            end
          end

          status = source.status
          if status
            case status.to_s
            when "modified"
              text += ", modified"
              mod = source.modification
              if mod
                mod_text = ls_text(mod)
                text += " \u2014 #{mod_text}" if mod_text && !mod_text.empty?
              end
            when "adapted"
              text += ", adapted"
            end
          end

          text += "]"

          t = Rfcxml::V3::Text.new
          t.content = [text]
          t
        end

        def transform_related_term(related)
          return nil unless related

          preferred = related.preferred
          term_text = nil
          if preferred
            preferred = [preferred] unless preferred.is_a?(Array)
            term_text = extract_term_name(preferred.first) if preferred.first
          end

          return nil unless term_text && !term_text.empty?

          type = related.type
          prefix = case type.to_s
                   when "deprecates" then "DEPRECATED: "
                   when "equivalent" then ""
                   when "see-also" then "SEE ALSO: "
                   else ""
                   end

          t = Rfcxml::V3::Text.new
          t.content = ["#{prefix}#{term_text}"]
          t
        end

        def transform_definitions_section(defn_node)
          section = Rfcxml::V3::Section.new
          section.anchor = to_ncname(defn_node.id) if defn_node.id

          title = defn_node.title
          if title
            name = Rfcxml::V3::Name.new
            name_text = ls_text(title)
            name.content = [name_text] if name_text && !name_text.empty?
            section.name = name unless name.content.nil? || name.content.empty?
          end

          dls = defn_node.definition_lists
          dls = [dls] unless dls.is_a?(Array)
          dls.each do |dl|
            list = transform_definition_list(dl)
            safe_append(section, :dl, list) if list
          end

          get_paragraphs(defn_node).each do |p|
            t = transform_paragraph(p)
            safe_append(section, :t, t) if t
          end

          section
        end
      end
    end
  end
end
