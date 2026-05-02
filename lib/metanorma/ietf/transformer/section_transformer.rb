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
            clauses = sections.clause || []
            clauses = [clauses] unless clauses.is_a?(Array)

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
            clauses = sections.clause || []
            clauses = [clauses] unless clauses.is_a?(Array)
            clauses.each do |clause|
              section = transform_clause(clause)
              safe_append(middle, :section, section) if section
            end
          end

          middle
        end

        def transform_loose_bibitem(sections_node)
          bibitems = sections_node.bibitem
          bibitems = [bibitems] unless bibitems.is_a?(Array)
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

          # Render bibitem content
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

          # Endnotes section for collected footnotes
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
          rfc_order = []

          if section.name
            rfc_order << Lutaml::Xml::Element.new("Element", "name")
          end

          src_order.each do |e|
            next if e.text?
            tag = e.element_tag
            next if tag == "title"
            idx = counters[tag]
            counters[tag] += 1
            rfc_tag = SRC_TO_RFC_TAG[tag]

            case tag
            when "p"
              paras = get_paragraphs(clause)
              if paras[idx]
                t = transform_paragraph(paras[idx])
                if t
                  safe_append(section, :t, t)
                  rfc_order << Lutaml::Xml::Element.new("Element", rfc_tag)
                end
                extract_inline_notes(paras[idx]).each do |aside|
                  safe_append(section, :aside, aside)
                  rfc_order << Lutaml::Xml::Element.new("Element", "aside")
                end
              end
            when "ul"
              uls = clause.unordered_lists
              uls = [uls] unless uls.is_a?(Array)
              if uls[idx]
                list = transform_unordered_list(uls[idx])
                if list
                  safe_append(section, :ul, list)
                  rfc_order << Lutaml::Xml::Element.new("Element", rfc_tag)
                end
              end
            when "ol"
              ols = clause.ordered_lists
              ols = [ols] unless ols.is_a?(Array)
              if ols[idx]
                list = transform_ordered_list(ols[idx])
                if list
                  safe_append(section, :ol, list)
                  rfc_order << Lutaml::Xml::Element.new("Element", rfc_tag)
                end
              end
            when "dl"
              dls = clause.definition_lists
              dls = [dls] unless dls.is_a?(Array)
              if dls[idx]
                list = transform_definition_list(dls[idx])
                if list
                  safe_append(section, :dl, list)
                  rfc_order << Lutaml::Xml::Element.new("Element", rfc_tag)
                end
              end
            when "table"
              tables = clause.tables
              tables = [tables] unless tables.is_a?(Array)
              if tables[idx]
                table = transform_table(tables[idx])
                if table
                  safe_append(section, :table, table)
                  rfc_order << Lutaml::Xml::Element.new("Element", rfc_tag)
                end
                build_table_surroundings(tables[idx], section).each do |surr|
                  if surr.is_a?(Rfcxml::V3::Dl)
                    safe_append(section, :dl, surr)
                    rfc_order << Lutaml::Xml::Element.new("Element", "dl")
                  elsif surr.is_a?(Rfcxml::V3::Text)
                    safe_append(section, :t, surr)
                    rfc_order << Lutaml::Xml::Element.new("Element", "t")
                  elsif surr.is_a?(Rfcxml::V3::Aside)
                    safe_append(section, :aside, surr)
                    rfc_order << Lutaml::Xml::Element.new("Element", "aside")
                  end
                end
              end
            when "figure"
              figures = clause.figures
              figures = [figures] unless figures.is_a?(Array)
              if figures[idx]
                f = transform_figure(figures[idx])
                if f.is_a?(Rfcxml::V3::Figure)
                  safe_append(section, :figure, f)
                  rfc_order << Lutaml::Xml::Element.new("Element", "figure")
                elsif f.is_a?(Rfcxml::V3::Sourcecode)
                  safe_append(section, :sourcecode, f)
                  rfc_order << Lutaml::Xml::Element.new("Element", "sourcecode")
                end
                extract_figure_asides(figures[idx]).each do |aside|
                  safe_append(section, :aside, aside)
                  rfc_order << Lutaml::Xml::Element.new("Element", "aside")
                end
              end
            when "sourcecode"
              sourcecodes = clause.sourcecode_blocks
              sourcecodes = [sourcecodes] unless sourcecodes.is_a?(Array)
              if sourcecodes[idx]
                src = transform_sourcecode(sourcecodes[idx])
                if src
                  safe_append(section, :sourcecode, src)
                  rfc_order << Lutaml::Xml::Element.new("Element", rfc_tag)
                end
                # Sourcecode callout annotations
                build_sourcecode_callouts(sourcecodes[idx]).each do |aside|
                  safe_append(section, :aside, aside)
                  rfc_order << Lutaml::Xml::Element.new("Element", "aside")
                end
              end
            when "clause"
              sub_clauses = clause.clause
              sub_clauses = [sub_clauses] unless sub_clauses.is_a?(Array)
              if sub_clauses[idx]
                sec = transform_clause(sub_clauses[idx])
                if sec
                  safe_append(section, :section, sec)
                  rfc_order << Lutaml::Xml::Element.new("Element", rfc_tag)
                end
              end
            when "formula"
              formulas = clause.formulas
              formulas = [formulas] unless formulas.is_a?(Array)
              if formulas[idx]
                elements = transform_formula(formulas[idx])
                elements.each do |elem|
                  if elem.is_a?(Rfcxml::V3::Text)
                    safe_append(section, :t, elem)
                    rfc_order << Lutaml::Xml::Element.new("Element", "t")
                  elsif elem.is_a?(Rfcxml::V3::Dl)
                    safe_append(section, :dl, elem)
                    rfc_order << Lutaml::Xml::Element.new("Element", "dl")
                  end
                end
              end
            when "note"
              notes = clause.notes
              notes = [notes] unless notes.is_a?(Array)
              if notes[idx]
                aside = transform_note(notes[idx], section)
                if aside
                  safe_append(section, :aside, aside)
                  rfc_order << Lutaml::Xml::Element.new("Element", rfc_tag)
                end
              end
            when "quote"
              quotes = clause.quote_blocks
              quotes = [quotes] unless quotes.is_a?(Array)
              if quotes[idx]
                bq = transform_quote(quotes[idx])
                if bq
                  safe_append(section, :blockquote, bq)
                  rfc_order << Lutaml::Xml::Element.new("Element", rfc_tag)
                end
              end
            when "example"
              examples = clause.examples
              examples = [examples] unless examples.is_a?(Array)
              if examples[idx]
                ts = transform_example(examples[idx])
                ts.each do |_t|
                  safe_append(section, :t, _t)
                  rfc_order << Lutaml::Xml::Element.new("Element", rfc_tag)
                end
              end
            when "terms"
              terms = clause.terms
              terms = [terms] unless terms.is_a?(Array)
              if terms[idx]
                sec = transform_terms_section(terms[idx])
                if sec
                  safe_append(section, :section, sec)
                  rfc_order << Lutaml::Xml::Element.new("Element", rfc_tag)
                end
              end
            when "definitions"
              defs = clause.definitions
              defs = [defs] unless defs.is_a?(Array)
              if defs[idx]
                sec = transform_definitions_section(defs[idx])
                if sec
                  safe_append(section, :section, sec)
                  rfc_order << Lutaml::Xml::Element.new("Element", rfc_tag)
                end
              end
            when "admonition"
              admonitions = clause.admonitions
              admonitions = [admonitions] unless admonitions.is_a?(Array)
              if admonitions[idx]
                aside = transform_admonition(admonitions[idx])
                if aside
                  safe_append(section, :aside, aside)
                  rfc_order << Lutaml::Xml::Element.new("Element", rfc_tag)
                end
              end
            end
          end

          section.element_order = rfc_order if rfc_order.any?
        end

        def parse_unordered_children(clause, section)
          rfc_order = []

          if section.name
            rfc_order << Lutaml::Xml::Element.new("Element", "name")
          end

          get_paragraphs(clause).each do |p|
            t = transform_paragraph(p)
            if t
              safe_append(section, :t, t)
              rfc_order << Lutaml::Xml::Element.new("Element", "t")
              extract_inline_notes(p).each do |aside|
                safe_append(section, :aside, aside)
                rfc_order << Lutaml::Xml::Element.new("Element", "aside")
              end
            end
          end

          notes = clause.notes
          notes = [notes] unless notes.is_a?(Array)
          notes.each do |note|
            aside = transform_note(note, section)
            if aside
              safe_append(section, :aside, aside)
              rfc_order << Lutaml::Xml::Element.new("Element", "aside")
            end
          end

          examples = clause.examples
          examples = [examples] unless examples.is_a?(Array)
          examples.each do |ex|
            ts = transform_example(ex)
            ts.each do |_t|
              safe_append(section, :t, _t)
              rfc_order << Lutaml::Xml::Element.new("Element", "t")
            end
          end

          sourcecodes = clause.sourcecode_blocks
          sourcecodes = [sourcecodes] unless sourcecodes.is_a?(Array)
          sourcecodes.each do |sc|
            src = transform_sourcecode(sc)
            if src
              safe_append(section, :sourcecode, src)
              rfc_order << Lutaml::Xml::Element.new("Element", "sourcecode")
            end
            build_sourcecode_callouts(sc).each do |aside|
              safe_append(section, :aside, aside)
              rfc_order << Lutaml::Xml::Element.new("Element", "aside")
            end
          end

          quotes = clause.quote_blocks
          quotes = [quotes] unless quotes.is_a?(Array)
          quotes.each do |q|
            bq = transform_quote(q)
            if bq
              safe_append(section, :blockquote, bq)
              rfc_order << Lutaml::Xml::Element.new("Element", "blockquote")
            end
          end

          admonitions = clause.admonitions
          admonitions = [admonitions] unless admonitions.is_a?(Array)
          admonitions.each do |admon|
            aside = transform_admonition(admon)
            if aside
              safe_append(section, :aside, aside)
              rfc_order << Lutaml::Xml::Element.new("Element", "aside")
            end
          end

          formulas = clause.formulas
          formulas = [formulas] unless formulas.is_a?(Array)
          formulas.each do |f|
            elements = transform_formula(f)
            elements.each do |elem|
              if elem.is_a?(Rfcxml::V3::Text)
                safe_append(section, :t, elem)
                rfc_order << Lutaml::Xml::Element.new("Element", "t")
              elsif elem.is_a?(Rfcxml::V3::Dl)
                safe_append(section, :dl, elem)
                rfc_order << Lutaml::Xml::Element.new("Element", "dl")
              end
            end
          end

          uls = clause.unordered_lists
          uls = [uls] unless uls.is_a?(Array)
          uls.each do |ul|
            list = transform_unordered_list(ul)
            if list
              safe_append(section, :ul, list)
              rfc_order << Lutaml::Xml::Element.new("Element", "ul")
            end
          end

          ols = clause.ordered_lists
          ols = [ols] unless ols.is_a?(Array)
          ols.each do |ol|
            list = transform_ordered_list(ol)
            if list
              safe_append(section, :ol, list)
              rfc_order << Lutaml::Xml::Element.new("Element", "ol")
            end
          end

          dls = clause.definition_lists
          dls = [dls] unless dls.is_a?(Array)
          dls.each do |dl|
            list = transform_definition_list(dl)
            if list
              safe_append(section, :dl, list)
              rfc_order << Lutaml::Xml::Element.new("Element", "dl")
            end
          end

          tables = clause.tables
          tables = [tables] unless tables.is_a?(Array)
          tables.each do |tbl|
            table = transform_table(tbl)
            if table
              safe_append(section, :table, table)
              rfc_order << Lutaml::Xml::Element.new("Element", "table")
            end
            build_table_surroundings(tbl, section).each do |surr|
              if surr.is_a?(Rfcxml::V3::Dl)
                safe_append(section, :dl, surr)
                rfc_order << Lutaml::Xml::Element.new("Element", "dl")
              elsif surr.is_a?(Rfcxml::V3::Text)
                safe_append(section, :t, surr)
                rfc_order << Lutaml::Xml::Element.new("Element", "t")
              elsif surr.is_a?(Rfcxml::V3::Aside)
                safe_append(section, :aside, surr)
                rfc_order << Lutaml::Xml::Element.new("Element", "aside")
              end
            end
          end

          figures = clause.figures
          figures = [figures] unless figures.is_a?(Array)
          figures.each do |fig|
            f = transform_figure(fig)
            if f.is_a?(Rfcxml::V3::Figure)
              safe_append(section, :figure, f)
              rfc_order << Lutaml::Xml::Element.new("Element", "figure")
            elsif f.is_a?(Rfcxml::V3::Sourcecode)
              safe_append(section, :sourcecode, f)
              rfc_order << Lutaml::Xml::Element.new("Element", "sourcecode")
            end
            extract_figure_asides(fig).each do |aside|
              safe_append(section, :aside, aside)
              rfc_order << Lutaml::Xml::Element.new("Element", "aside")
            end
          end

          sub_clauses = clause.clause
          sub_clauses = [sub_clauses] unless sub_clauses.is_a?(Array)
          sub_clauses.each do |sub|
            sec = transform_clause(sub)
            if sec
              safe_append(section, :section, sec)
              rfc_order << Lutaml::Xml::Element.new("Element", "section")
            end
          end

          terms = clause.terms
          terms = [terms] unless terms.is_a?(Array)
          terms.each do |term_section|
            sec = transform_terms_section(term_section)
            if sec
              safe_append(section, :section, sec)
              rfc_order << Lutaml::Xml::Element.new("Element", "section")
            end
          end

          defs = clause.definitions
          defs = [defs] unless defs.is_a?(Array)
          defs.each do |defn|
            sec = transform_definitions_section(defn)
            if sec
              safe_append(section, :section, sec)
              rfc_order << Lutaml::Xml::Element.new("Element", "section")
            end
          end

          section.element_order = rfc_order if rfc_order.any?
        end
      end
    end
  end
end
