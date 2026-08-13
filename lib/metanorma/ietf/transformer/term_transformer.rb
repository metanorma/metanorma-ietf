# frozen_string_literal: true

module Metanorma
  module Ietf
    module Transformer
      module TermTransformer

        def transform_terms_section(terms_node)
          section = Rfcxml::V3::Section.new
          section.anchor = to_ncname(terms_node.id) if terms_node.id

          # inline markup in titles is carried, not flattened (#292)
          name = build_inline_name(terms_node.title)
          section.name = name if name

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

          # Render deprecated designations — the model's accessor is
          # :deprecates, matching the semantic element; probing
          # :deprecated made this branch dead code (#300)
          to_array(model_attr(term_node, :deprecates)).each do |dep|
            term_text = extract_term_name(dep)
            next if term_text.nil? || term_text.empty?

            t = Rfcxml::V3::Text.new
            t.content = ["DEPRECATED: #{term_text}"]
            safe_append(section, :t, t)
          end

          # Definition rendering. The enumeration unit is the
          # DEFINITION, not the paragraph (#300): one definition with
          # two paragraphs is a single definition, not two enumerated
          # ones — only multiple <definition> elements get the ol.
          definition_groups = definition_paragraph_groups(term_node)
          first_para = true
          apply_domain = lambda do |t|
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
            t
          end
          if definition_groups.size > 1
            ol = Rfcxml::V3::Ol.new
            # the released path keeps <t anchor> inside term-definition
            # list items by construction (terms.rb), unlike body lists;
            # exempt this ol from the single-t li flatten (WS3)
            (@term_definition_ols ||= []) << ol.object_id
            definition_groups.each do |group|
              li = Rfcxml::V3::Li.new
              group.each do |p|
                t = transform_paragraph(p)
                next unless t

                safe_append(li, :t, apply_domain.call(t))
              end
              safe_append(ol, :li, li)
            end
            safe_append(section, :ol, ol)
          else
            definition_groups.flatten.each do |p|
              t = transform_paragraph(p)
              next unless t

              safe_append(section, :t, apply_domain.call(t))
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

          # Term sources → ONE merged <t>[SOURCE: A; B]</t> (#300):
          # the released path merged consecutive sources into a single
          # bracket instead of one per source
          t = transform_term_sources(to_array(model_attr(term_node,
                                                         :source)))
          safe_append(section, :t, t) if t

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

        # one group of paragraphs per <definition> element; the flat
        # get_paragraphs carrier (vintage shapes) is a single group
        def definition_paragraph_groups(term_node)
          if term_node.respond_to?(:definition)
            groups = to_array(term_node.definition).map do |d|
              verbs = model_attr(d, :verbalexpression)
              to_array(verbs).flat_map do |v|
                to_array(model_attr(v, :paragraph))
              end.compact
            end.reject(&:empty?)
            return groups if groups.any?
          end

          flat = get_paragraphs(term_node)
          flat.empty? ? [] : [flat]
        end

        def extract_term_name(designation)
          return "" unless designation

          if designation.class.method_defined?(:expression) && designation.expression
            expr = designation.expression
            # descendant text survives markup in designations (#292)
            return flatten_inline_text(expr.name || expr)
          end

          # MODEL GAP (metanorma-document 0.2.9): Designation maps
          # only expression + geographic_area — <letter-symbol> and
          # <graphical-symbol> designations are parse-ghosted, so no
          # branch can reach them (#300; the former :letter_symbol /
          # :graphical_symbol probes were dead guards). Re-add the
          # branches on the model upgrade.
          ls_text(designation) || ""
        end

        def transform_term_sources(sources)
          return nil if sources.empty?

          t = Rfcxml::V3::Text.new
          append_text = lambda do |s|
            t.content = to_array(t.content) + [s]
            track_text_order(t, s)
          end
          append_text.call("[SOURCE: ")
          sources.each_with_index do |src, i|
            append_text.call("; ") if i.positive?
            append_term_source(t, src, append_text)
          end
          append_text.call("]")
          t
        end

        def append_term_source(t, source, append_text)
          origin = source.origin
          if origin
            target = origin.class.method_defined?(:bibitemid) &&
              origin.bibitemid
            if target
              # a REAL xref element, not spliced markup text \u2014 the
              # string splice serialised as escaped &lt;xref&gt;
              # literals (#300). WS3: the origin locality itself is
              # not mapped by the model (metanorma-document 0.2.9),
              # so no section can be emitted yet
              xref = Rfcxml::V3::Xref.new
              xref.target = to_ncname(target.to_s)
              safe_append(t, :xref, xref)
              track_element_order(t, :xref, xref)
            else
              append_text.call(ls_text(origin).to_s)
            end
          end

          status = source.status
          case status.to_s
          when "modified" then append_text.call(", modified")
          when "adapted" then append_text.call(", adapted")
          end
          # the modification note is appended REGARDLESS of status
          # (#300): the released path did not gate it on "modified"
          mod = model_attr(source, :modification)
          if mod
            # mixed_text: the modification is a mixed-content
            # paragraph; ls_text saw only its (empty) string runs
            mod_text = mixed_text(mod)
            if mod_text && !mod_text.empty?
              append_text.call(" \u2014 #{mod_text}")
            end
          end
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
