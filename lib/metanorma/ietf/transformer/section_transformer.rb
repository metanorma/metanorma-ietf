# frozen_string_literal: true

module Metanorma
  module Ietf
    module Transformer
      module SectionTransformer
        private

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
            clause_idx = 0
            clauses = to_array(sections.clause || [])

            src_order.each do |e|
              next if e.text?
              tag = e.element_tag
              case tag
              when "clause"
                if clauses[clause_idx]
                  section = transform_clause(clauses[clause_idx])
                  safe_append(middle, :section, section) if section
                end
                clause_idx += 1
              when "bibitem"
                section = transform_loose_bibitem(sections)
                safe_append(middle, :section, section) if section
              end
            end
          else
            to_array(sections.clause || []).each do |clause|
              section = transform_clause(clause)
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

          paragraphs = get_paragraphs(bib) rescue []
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

          bib = doc.bibliography
          if bib
            refs_sections = bib.references || []
            refs_sections.each do |refs|
              references = transform_references_section(refs)
              safe_append(back, :references, references) if references
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

          section.anchor = to_ncname(clause.id) if clause.id

          if clause.unnumbered == "true"
            section.numbered = "false"
          end

          toc_val = clause.toc
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
              tables = to_array(clause.tables)
              if tables[idx]
                table = transform_table(tables[idx])
                append_ordered(section, :table, table) if table
                build_table_surroundings(tables[idx], section).each do |surr|
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
              figures = to_array(clause.figures)
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
              sourcecodes = to_array(clause.sourcecode_blocks)
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
              sub_clauses = to_array(clause.clause)
              if sub_clauses[idx]
                sec = transform_clause(sub_clauses[idx])
                append_ordered(section, :section, sec) if sec
              end
            when "formula"
              formulas = to_array(clause.formulas)
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
              notes = to_array(clause.notes)
              if notes[idx]
                aside = transform_note(notes[idx], section)
                append_ordered(section, :aside, aside) if aside
              end
            when "quote"
              quotes = to_array(clause.quote_blocks)
              if quotes[idx]
                bq = transform_quote(quotes[idx])
                append_ordered(section, :blockquote, bq) if bq
              end
            when "example"
              examples = to_array(clause.examples)
              if examples[idx]
                ts = transform_example(examples[idx])
                ts.each { |_t| append_ordered(section, :t, _t) }
              end
            when "terms"
              terms = to_array(clause.terms)
              if terms[idx]
                sec = transform_terms_section(terms[idx])
                append_ordered(section, :section, sec) if sec
              end
            when "definitions"
              defs = to_array(clause.definitions)
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

          to_array(clause.notes).each do |note|
            aside = transform_note(note, section)
            append_ordered(section, :aside, aside) if aside
          end

          to_array(clause.examples).each do |ex|
            ts = transform_example(ex)
            ts.each { |_t| append_ordered(section, :t, _t) }
          end

          to_array(clause.sourcecode_blocks).each do |sc|
            src = transform_sourcecode(sc)
            if src
              append_ordered(section, :sourcecode, src)
            end
            build_sourcecode_callouts(sc).each do |aside|
              append_ordered(section, :aside, aside)
            end
          end

          to_array(clause.quote_blocks).each do |q|
            bq = transform_quote(q)
            append_ordered(section, :blockquote, bq) if bq
          end

          to_array(clause.admonitions).each do |admon|
            aside = transform_admonition(admon)
            append_ordered(section, :aside, aside) if aside
          end

          to_array(clause.formulas).each do |f|
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

          to_array(clause.tables).each do |tbl|
            table = transform_table(tbl)
            if table
              append_ordered(section, :table, table)
            end
            build_table_surroundings(tbl, section).each do |surr|
              if surr.is_a?(Rfcxml::V3::Dl)
                append_ordered(section, :dl, surr)
              elsif surr.is_a?(Rfcxml::V3::Text)
                append_ordered(section, :t, surr)
              elsif surr.is_a?(Rfcxml::V3::Aside)
                append_ordered(section, :aside, surr)
              end
            end
          end

          to_array(clause.figures).each do |fig|
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

          to_array(clause.clause).each do |sub|
            sec = transform_clause(sub)
            append_ordered(section, :section, sec) if sec
          end

          to_array(clause.terms).each do |term_section|
            sec = transform_terms_section(term_section)
            append_ordered(section, :section, sec) if sec
          end

          to_array(clause.definitions).each do |defn|
            sec = transform_definitions_section(defn)
            append_ordered(section, :section, sec) if sec
          end
        end
      end
    end
  end
end
