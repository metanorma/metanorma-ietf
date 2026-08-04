# frozen_string_literal: true

module Metanorma
  module Ietf
    module Transformer
      module SectionTransformer

        def build_middle
          middle = Rfcxml::V3::Middle.new

          preface = doc.preface
          if preface
            if preface.introduction
              sec = transform_clause(preface.introduction)
              safe_append(middle, :section, sec) if sec
            end

            if preface.acknowledgements
              sec = transform_clause(preface.acknowledgements)
              safe_append(middle, :section, sec) if sec
            end
          end

          sections = doc.sections
          return middle unless sections

          src_order = sections.element_order
          if src_order && src_order.any?
            counters = Hash.new(0)
            clauses = to_array(sections.clause || [])
            terms = to_array(sections.terms || [])
            definitions = to_array(sections.definitions || [])

            src_order.each do |e|
              next if e.text?
              tag = e.element_tag
              idx = counters[tag]
              counters[tag] += 1
              case tag
              when "clause"
                if clauses[idx]
                  # a clause carrying <references> relocates to back
                  # as a references group (v3 admits references only
                  # in <back>; the released path does the same)
                  if clause_has_references?(clauses[idx])
                    (@deferred_reference_groups ||= []) <<
                      transform_references_group(clauses[idx])
                  else
                    section = transform_clause(clauses[idx])
                    safe_append(middle, :section, section) if section
                  end
                end
              # WS3 (terms_spec port): top-level <sections>/<terms> and
              # <definitions> were silently skipped — only their nested
              # (clause-embedded) forms were walked
              when "terms"
                if terms[idx]
                  section = transform_terms_section(terms[idx])
                  safe_append(middle, :section, section) if section
                end
              when "definitions"
                if definitions[idx]
                  section = transform_definitions_section(definitions[idx])
                  safe_append(middle, :section, section) if section
                end
              when "bibitem"
                section = transform_loose_bibitem(sections)
                safe_append(middle, :section, section) if section
              end
            end
          else
            to_array(sections.clause || []).each do |clause|
              if clause_has_references?(clause)
                (@deferred_reference_groups ||= []) <<
                  transform_references_group(clause)
                next
              end
              section = transform_clause(clause)
              safe_append(middle, :section, section) if section
            end
            to_array(sections.terms || []).each do |term_section|
              section = transform_terms_section(term_section)
              safe_append(middle, :section, section) if section
            end
            to_array(sections.definitions || []).each do |defn|
              section = transform_definitions_section(defn)
              safe_append(middle, :section, section) if section
            end
          end

          middle
        end

        def transform_loose_bibitem(sections_node)
          bibitems = to_array(sections_node.bibitem)
          return nil if bibitems.empty?

          bib = bibitems.first
          bib_id = bib.id

          title_text = extract_bibitem_title(bib)
          title_text ||= bib_id

          section = Rfcxml::V3::Section.new
          section.anchor = to_ncname(bib_id) if bib_id

          name = Rfcxml::V3::Name.new
          name.content = [title_text]
          section.name = name

          paragraphs = bib.class.method_defined?(:paragraphs) ? get_paragraphs(bib) : []
          paragraphs.each do |p|
            text = extract_paragraph_text(p)
            next if text.nil? || text.strip.empty?
            t = Rfcxml::V3::Text.new
            t.content = [text.strip]
            safe_append(section, :t, t)
          end

          section
        end

        def build_back
          back = Rfcxml::V3::Back.new

          # references groups deferred from the middle walk (clauses
          # carrying <references>) come first, as the released path
          # orders them
          to_array(@deferred_reference_groups).each do |group|
            safe_append(back, :references, group)
          end

          bib = doc.bibliography
          if bib
            # walk the bibliography in source order: bare <references>
            # render flat; clause-wrapped ones render as nested groups
            src_order = bib.respond_to?(:element_order) ? bib.element_order : nil
            refs_sections = to_array(bib.references)
            bib_clauses = to_array(model_attr(bib, :clause))
            if src_order && src_order.any?
              counters = Hash.new(0)
              src_order.each do |e|
                next if e.text?
                tag = e.element_tag
                idx = counters[tag]
                counters[tag] += 1
                case tag
                when "references"
                  references = transform_references_section(refs_sections[idx])
                  safe_append(back, :references, references) if references
                when "clause"
                  next unless bib_clauses[idx]

                  group = transform_references_group(bib_clauses[idx])
                  safe_append(back, :references, group) if group
                end
              end
            else
              refs_sections.each do |refs|
                references = transform_references_section(refs)
                safe_append(back, :references, references) if references
              end
              bib_clauses.each do |c|
                group = transform_references_group(c)
                safe_append(back, :references, group) if group
              end
            end
          end

          build_annotations.each do |cref|
            safe_append(back, :cref, cref)
          end

          annexes = doc.annex || []
          annexes.each do |annex|
            section = transform_clause(annex)
            safe_append(back, :section, section) if section
          end

          endnotes = build_endnotes
          safe_append(back, :section, endnotes) if endnotes

          back
        end

        def build_endnotes
          return nil if @collected_footnotes.empty?

          section = Rfcxml::V3::Section.new
          section.anchor = "endnotes"

          name = Rfcxml::V3::Name.new
          name.content = ["Endnotes"]
          section.name = name

          @collected_footnotes.keys.sort.each do |num|
            paragraphs = @collected_footnotes[num]
            paragraphs.each do |text|
              t = Rfcxml::V3::Text.new
              t.content = ["[#{num}] #{text}"]
              safe_append(section, :t, t)
            end
          end

          section
        end

        def transform_clause(clause)
          section = Rfcxml::V3::Section.new

          section.anchor = to_ncname(anchor_for(clause)) if anchor_for(clause)

          unnumbered = clause.unnumbered if clause.class.method_defined?(:unnumbered)
          if unnumbered == "true"
            section.numbered = "false"
          end

          toc_val = clause.toc if clause.class.method_defined?(:toc)
          if toc_val
            toc_val = [toc_val] unless toc_val.is_a?(Array)
            first = toc_val.first
            section.toc = first if first && !first.to_s.empty?
          end

          title = clause.title
          if title
            name = Rfcxml::V3::Name.new
            title_text = ls_text(title)
            name.content = [title_text] if title_text && !title_text.empty?
            section.name = name unless name.content.nil? || name.content.empty?
          end

          parse_clause_children(clause, section)

          section
        end

        def parse_clause_children(clause, section)
          src_order = clause.element_order

          if src_order && src_order.any?
            parse_ordered_children(clause, section, src_order)
          else
            parse_unordered_children(clause, section)
          end
        end

        SRC_TO_RFC_TAG = {
          "p" => "t",
          "ul" => "ul",
          "ol" => "ol",
          "dl" => "dl",
          "table" => "table",
          "figure" => "figure",
          "sourcecode" => "sourcecode",
          "clause" => "section",
          "formula" => "t",
          "note" => "aside",
          "quote" => "blockquote",
          "example" => "t",
          "terms" => "section",
          "definitions" => "section",
          "admonition" => "aside",
        }.freeze

        def parse_ordered_children(clause, section, src_order)
          counters = Hash.new(0)

          if section.name
            track_element_order(section, :name, section.name)
          end

          src_order.each do |e|
            next if e.text?
            tag = e.element_tag
            next if tag == "title"
            idx = counters[tag]
            counters[tag] += 1

            case tag
            when "p"
              paras = get_paragraphs(clause)
              if paras[idx]
                t = transform_paragraph(paras[idx])
                if t
                  append_ordered(section, :t, t)
                  extract_inline_notes(paras[idx]).each do |aside|
                    append_ordered(section, :aside, aside)
                  end
                end
              end
            when "ul"
              uls = to_array(clause.unordered_lists)
              if uls[idx]
                list = transform_unordered_list(uls[idx])
                append_ordered(section, :ul, list) if list
              end
            when "ol"
              ols = to_array(clause.ordered_lists)
              if ols[idx]
                list = transform_ordered_list(ols[idx])
                append_ordered(section, :ol, list) if list
              end
            when "dl"
              dls = to_array(clause.definition_lists)
              if dls[idx]
                list = transform_definition_list(dls[idx])
                append_ordered(section, :dl, list) if list
              end
            when "table"
              tables = to_array(model_attr(clause, :tables))
              if tables[idx]
                table = transform_table(tables[idx])
                append_ordered(section, :table, table) if table
                build_table_surroundings(tables[idx]).each do |surr|
                  if surr.is_a?(Rfcxml::V3::Dl)
                    append_ordered(section, :dl, surr)
                  elsif surr.is_a?(Rfcxml::V3::Text)
                    append_ordered(section, :t, surr)
                  elsif surr.is_a?(Rfcxml::V3::Aside)
                    append_ordered(section, :aside, surr)
                  end
                end
              end
            when "figure"
              figures = to_array(model_attr(clause, :figures))
              if figures[idx]
                f = transform_figure(figures[idx])
                if f.is_a?(Rfcxml::V3::Figure)
                  append_ordered(section, :figure, f)
                elsif f.is_a?(Rfcxml::V3::Sourcecode)
                  append_ordered(section, :sourcecode, f)
                end
                extract_figure_asides(figures[idx]).each do |aside|
                  append_ordered(section, :aside, aside)
                end
              end
            when "sourcecode"
              sourcecodes = to_array(model_attr(clause, :sourcecode_blocks))
              if sourcecodes[idx]
                src = transform_sourcecode(sourcecodes[idx])
                if src
                  append_ordered(section, :sourcecode, src)
                end
                build_sourcecode_callouts(sourcecodes[idx]).each do |aside|
                  append_ordered(section, :aside, aside)
                end
              end
            when "clause"
              sub_clauses = to_array(model_attr(clause, :clause) || model_attr(clause, :subsection))
              if sub_clauses[idx]
                sec = transform_clause(sub_clauses[idx])
                append_ordered(section, :section, sec) if sec
              end
            when "formula"
              formulas = to_array(model_attr(clause, :formulas))
              if formulas[idx]
                elements = transform_formula(formulas[idx])
                elements.each do |elem|
                  if elem.is_a?(Rfcxml::V3::Text)
                    append_ordered(section, :t, elem)
                  elsif elem.is_a?(Rfcxml::V3::Dl)
                    append_ordered(section, :dl, elem)
                  end
                end
              end
            when "note"
              notes = to_array(model_attr(clause, :notes))
              if notes[idx]
                aside = transform_note(notes[idx], section)
                append_ordered(section, :aside, aside) if aside
              end
            when "quote"
              quotes = to_array(model_attr(clause, :quote_blocks))
              if quotes[idx]
                bq = transform_quote(quotes[idx])
                append_ordered(section, :blockquote, bq) if bq
              end
            when "example"
              examples = to_array(model_attr(clause, :examples))
              if examples[idx]
                ts = transform_example(examples[idx])
                # mixed results since F7: each child lands in its own
                # typed collection, not blanket :t
                ts.each { |n| append_ordered(section, example_result_tag(n), n) }
              end
            when "terms"
              terms = to_array(model_attr(clause, :terms))
              if terms[idx]
                sec = transform_terms_section(terms[idx])
                append_ordered(section, :section, sec) if sec
              end
            when "definitions"
              defs = to_array(model_attr(clause, :definitions))
              if defs[idx]
                sec = transform_definitions_section(defs[idx])
                append_ordered(section, :section, sec) if sec
              end
            when "admonition"
              admonitions = to_array(clause.admonitions)
              if admonitions[idx]
                aside = transform_admonition(admonitions[idx])
                append_ordered(section, :aside, aside) if aside
              end
            end
          end
        end

        def parse_unordered_children(clause, section)
          if section.name
            track_element_order(section, :name, section.name)
          end

          get_paragraphs(clause).each do |p|
            t = transform_paragraph(p)
            if t
              append_ordered(section, :t, t)
              extract_inline_notes(p).each do |aside|
                append_ordered(section, :aside, aside)
              end
            end
          end

          to_array(model_attr(clause, :notes)).each do |note|
            aside = transform_note(note, section)
            append_ordered(section, :aside, aside) if aside
          end

          to_array(model_attr(clause, :examples)).each do |ex|
            ts = transform_example(ex)
            # mixed results since F7: each child lands in its own
            # typed collection, not blanket :t
            ts.each { |n| append_ordered(section, example_result_tag(n), n) }
          end

          to_array(model_attr(clause, :sourcecode_blocks)).each do |sc|
            src = transform_sourcecode(sc)
            if src
              append_ordered(section, :sourcecode, src)
            end
            build_sourcecode_callouts(sc).each do |aside|
              append_ordered(section, :aside, aside)
            end
          end

          to_array(model_attr(clause, :quote_blocks)).each do |q|
            bq = transform_quote(q)
            append_ordered(section, :blockquote, bq) if bq
          end

          to_array(clause.admonitions).each do |admon|
            aside = transform_admonition(admon)
            append_ordered(section, :aside, aside) if aside
          end

          to_array(model_attr(clause, :formulas)).each do |f|
            elements = transform_formula(f)
            elements.each do |elem|
              if elem.is_a?(Rfcxml::V3::Text)
                append_ordered(section, :t, elem)
              elsif elem.is_a?(Rfcxml::V3::Dl)
                append_ordered(section, :dl, elem)
              end
            end
          end

          to_array(clause.unordered_lists).each do |ul|
            list = transform_unordered_list(ul)
            append_ordered(section, :ul, list) if list
          end

          to_array(clause.ordered_lists).each do |ol|
            list = transform_ordered_list(ol)
            append_ordered(section, :ol, list) if list
          end

          to_array(clause.definition_lists).each do |dl|
            list = transform_definition_list(dl)
            append_ordered(section, :dl, list) if list
          end

          to_array(model_attr(clause, :tables)).each do |tbl|
            table = transform_table(tbl)
            if table
              append_ordered(section, :table, table)
            end
            build_table_surroundings(tbl).each do |surr|
              if surr.is_a?(Rfcxml::V3::Dl)
                append_ordered(section, :dl, surr)
              elsif surr.is_a?(Rfcxml::V3::Text)
                append_ordered(section, :t, surr)
              elsif surr.is_a?(Rfcxml::V3::Aside)
                append_ordered(section, :aside, surr)
              end
            end
          end

          to_array(model_attr(clause, :figures)).each do |fig|
            f = transform_figure(fig)
            if f.is_a?(Rfcxml::V3::Figure)
              append_ordered(section, :figure, f)
            elsif f.is_a?(Rfcxml::V3::Sourcecode)
              append_ordered(section, :sourcecode, f)
            end
            extract_figure_asides(fig).each do |aside|
              append_ordered(section, :aside, aside)
            end
          end

          to_array(model_attr(clause, :clause) || model_attr(clause, :subsection)).each do |sub|
            sec = transform_clause(sub)
            append_ordered(section, :section, sec) if sec
          end

          to_array(model_attr(clause, :terms)).each do |term_section|
            sec = transform_terms_section(term_section)
            append_ordered(section, :section, sec) if sec
          end

          to_array(model_attr(clause, :definitions)).each do |defn|
            sec = transform_definitions_section(defn)
            append_ordered(section, :section, sec) if sec
          end
        end
      end
    end
  end
end
