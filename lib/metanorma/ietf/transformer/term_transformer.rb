# frozen_string_literal: true

module Metanorma
  module Ietf
    module Transformer
      module TermTransformer

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

          # Vintage tolerance (WS3): one model maps <p> to .p and
          # <term> to .term; another maps paragraphs to .paragraphs
          # and puts Term entries on .terms itself. respond_to? guards
          # also avoid Kernel#p (private) where .p is unmapped.
          ps = if terms_node.respond_to?(:p) then terms_node.p
               elsif terms_node.respond_to?(:paragraphs)
                 terms_node.paragraphs
               end
          if ps
            ps = [ps] unless ps.is_a?(Array)
            ps.each do |p|
              t = transform_paragraph(p)
              safe_append(section, :t, t) if t
            end
          end

          term_entries =
            terms_node.respond_to?(:term) ? to_array(terms_node.term) : []
          nested_sections = []
          terms_children =
            terms_node.respond_to?(:terms) ? to_array(terms_node.terms) : []
          terms_children.each do |child|
            if child.respond_to?(:preferred)
              term_entries << child
            else
              nested_sections << child
            end
          end

          term_entries.each do |term|
            term_sec = transform_term(term)
            safe_append(section, :section, term_sec) if term_sec
          end

          nested_sections.each do |ts|
            sec = transform_terms_section(ts)
            safe_append(section, :section, sec) if sec
          end

          clauses = terms_node.respond_to?(:clause) ? terms_node.clause : nil
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

          preferred = to_array(term_node.preferred)

          if preferred.first
            name = Rfcxml::V3::Name.new
            name_text = extract_term_name(preferred.first)
            name.content = [name_text] if name_text && !name_text.empty?
            section.name = name unless name.content.nil? || name.content.empty?
          end

          # Render admitted designations
          admitted = term_node.admitted if term_node.class.method_defined?(:admitted)
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
          deprecated = term_node.deprecated if term_node.class.method_defined?(:deprecated)
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
          if definition_paragraphs.empty? && term_node.respond_to?(:definition)
            # vintage shape (WS3): <definition><verbal-definition><p>
            # maps definition[] -> verbalexpression[] -> paragraph[]
            definition_paragraphs =
              to_array(term_node.definition).flat_map do |d|
                verbs = d.respond_to?(:verbalexpression) ? d.verbalexpression : nil
                to_array(verbs).flat_map do |v|
                  to_array(v.respond_to?(:paragraph) ? v.paragraph : nil)
                end
              end.compact
          end
          if definition_paragraphs.size > 1
            first_para = true
            ol = Rfcxml::V3::Ol.new
            # the released path keeps <t anchor> inside term-definition
            # list items by construction (terms.rb), unlike body lists;
            # exempt this ol from the single-t li flatten (WS3)
            (@term_definition_ols ||= []) << ol.object_id
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
                    t.content = ["<#{domain_text}> #{existing}"]
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
                    t.content = ["<#{domain_text}> #{existing}"]
                  end
                end
                first_para = false
              end

              safe_append(section, :t, t) if t
            end
          end

          # Definition lists within term
          term_dls = term_node.definition_lists if term_node.class.method_defined?(:definition_lists)
          if term_dls
            term_dls = [term_dls] unless term_dls.is_a?(Array)
            term_dls.each do |dl|
              list = transform_definition_list(dl)
              safe_append(section, :dl, list) if list
            end
          end

          # Examples within terms (vintage maps the singular :example)
          examples = if term_node.class.method_defined?(:examples)
                       term_node.examples
                     elsif term_node.respond_to?(:example)
                       term_node.example
                     end
          if examples
            examples = [examples] unless examples.is_a?(Array)
            examples.each_with_index do |ex, idx|
              ts = transform_example(ex, example_counter: idx + 1)
              ts.each { |_t| safe_append(section, :t, _t) }
            end
          end

          notes = if term_node.respond_to?(:notes) then term_node.notes
                  elsif term_node.respond_to?(:note) then term_node.note
                  end
          to_array(notes).each do |note|
            aside = transform_note(note, section)
            safe_append(section, :aside, aside) if aside
          end

          # Term sources → <t>[SOURCE: ...]</t>
          sources = term_node.respond_to?(:source) ? term_node.source : nil
          to_array(sources).each do |src|
            t = transform_term_source(src)
            safe_append(section, :t, t) if t
          end

          # Related terms
          related = term_node.respond_to?(:related) ? term_node.related : nil
          to_array(related).each do |rel|
            t = transform_related_term(rel)
            safe_append(section, :t, t) if t
          end

          # Nested terms
          subterms = term_node.respond_to?(:term) ? term_node.term : nil
          to_array(subterms).each do |t|
            sec = transform_term(t)
            safe_append(section, :section, sec) if sec
          end

          section
        end

        def extract_term_name(designation)
          return "" unless designation

          if designation.class.method_defined?(:expression) && designation.expression
            expr = designation.expression
            return ls_text(expr.name || expr)
          end

          if designation.class.method_defined?(:letter_symbol) && designation.letter_symbol
            return extract_letter_symbol_text(designation.letter_symbol)
          end

          if designation.class.method_defined?(:graphical_symbol) && designation.graphical_symbol
            return "[graphical symbol]"
          end

          ls_text(designation) || ""
        end

        def extract_letter_symbol_text(letter_symbol)
          return "" unless letter_symbol

          if letter_symbol.class.method_defined?(:stem) && letter_symbol.stem
            text = build_stem_text(letter_symbol.stem)
            return text if text && !text.empty?
          end

          if letter_symbol.class.method_defined?(:text) && letter_symbol.text
            text = letter_symbol.text
            text = [text] unless text.is_a?(Array)
            return text.join unless text.empty?
          end

          ""
        end

        def transform_term_source(source)
          return nil unless source

          text = "[SOURCE: "

          origin = source.origin
          if origin
            target = origin.bibitemid if origin.class.method_defined?(:bibitemid)
            if target
              # WS3: empty section=/relative= attributes dropped; the
              # origin locality itself is not mapped by the model
              # (metanorma-document 0.2.9 \u2014 see qa-plan WS3 note), so
              # no section can be emitted yet
              text += "<xref target='#{target}'/>"
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
                # mixed_text: the modification is a mixed-content
                # paragraph; ls_text saw only its (empty) string runs
                mod_text = mixed_text(mod)
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

          to_array(defn_node.definition_lists).each do |dl|
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
