# frozen_string_literal: true

module Metanorma
  module Ietf
    module Transformer
      module TableTransformer

        def transform_table(table_node)
          table = Rfcxml::V3::Table.new
          table.anchor = to_ncname(anchor_for(table_node)) if anchor_for(table_node)

          # Handle unnumbered tables
          if table_node.unnumbered == "true"
            table.anchor = nil
          end

          name_node = table_node.name
          if name_node
            name = Rfcxml::V3::Name.new
            # MODEL GAP (metanorma-document 0.2.9, WS3): caption inline
            # markup (<em> …) is lost at parse — NameWithIdElement maps
            # no inline collections and each_mixed_content yields
            # nothing, so only the text runs survive
            name_text = ls_text(name_node)
            name.content = [name_text] if name_text && !name_text.empty?
            table.name = name unless name.content.nil? || name.content.empty?
          end

          thead_node = table_node.thead
          if thead_node
            thead = transform_table_section(thead_node, :header)
            table.thead = thead
          end

          tbody_node = table_node.tbody
          if tbody_node
            tbody = transform_table_section(tbody_node, :body)
            table.tbody = tbody
          end

          tfoot_node = table_node.tfoot
          if tfoot_node
            tfoot = transform_table_section(tfoot_node, :footer)
            table.tfoot = tfoot
          end

          table
        end

        def transform_table_section(section_node, role)
          return nil unless section_node

          rows = to_array(section_node.tr)

          result_rows = []
          rows.each do |tr|
            row = transform_table_row(tr, role)
            result_rows << row if row
          end

          section = Rfcxml::V3::Tbody.new
          result_rows.each { |r| safe_append(section, :tr, r) }
          section
        end

        def transform_table_row(tr_node, role)
          return nil unless tr_node

          tr = Rfcxml::V3::Tr.new

          if role == :header
            to_array(tr_node.th).each do |cell|
              tc = transform_table_cell(cell)
              safe_append(tr, :th, tc) if tc
            end
            # Also check for td cells in header rows (fallback)
            if tr.th.nil? || !tr.th.is_a?(Array) || tr.th.empty?
              to_array(tr_node.td).each do |cell|
                tc = transform_table_cell(cell)
                safe_append(tr, :th, tc) if tc
              end
            end
          else
            # Body rows: mixed th/td rows must keep cell order (WS3 —
            # separate th-then-td appends serialised the header cell
            # after its sibling data cells)
            src_order = tr_node.respond_to?(:element_order) ? tr_node.element_order : nil
            ths = to_array(tr_node.th)
            tds = to_array(tr_node.td)
            if src_order && src_order.any? && !ths.empty?
              counters = Hash.new(0)
              src_order.each do |e|
                next if e.text?
                tag = e.element_tag
                idx = counters[tag]
                counters[tag] += 1
                case tag
                when "th"
                  tc = transform_table_cell(ths[idx])
                  append_ordered(tr, :th, tc) if tc
                when "td"
                  tc = transform_table_cell(tds[idx])
                  append_ordered(tr, :td, tc) if tc
                end
              end
            else
              ths.each do |cell|
                tc = transform_table_cell(cell)
                safe_append(tr, :th, tc) if tc
              end
              tds.each do |cell|
                tc = transform_table_cell(cell)
                safe_append(tr, :td, tc) if tc
              end
            end
          end

          tr
        end

        def transform_table_cell(cell_node)
          return nil unless cell_node

          tc = Rfcxml::V3::Td.new

          align = cell_node.align
          tc.align = align if align && !align.to_s.empty?

          colspan = cell_node.colspan
          tc.colspan = colspan.to_s if colspan && colspan.to_i > 1

          rowspan = cell_node.rowspan
          tc.rowspan = rowspan.to_s if rowspan && rowspan.to_i > 1

          get_paragraphs(cell_node).each do |p|
            t = transform_paragraph(p)
            safe_append(tc, :t, t) if t
          end

          cell_order = cell_node.respond_to?(:element_order) ? cell_node.element_order : nil
          if cell_order && cell_order.any? { |e| !e.text? }
            # mixed cell content: keep inline elements (fn, stem, em …)
            # in place instead of joining the bare text runs (WS3)
            build_interleaved_content(tc, cell_node, cell_order)
          elsif cell_node.text
            # Table cells use .text attribute (Array of String)
            text_val = cell_node.text
            text_val = text_val.join if text_val.is_a?(Array)
            tc.content = [text_val] if !text_val.to_s.strip.empty?
          end

          tc
        end

        def build_table_surroundings(table_node)
          results = []

          # Key → <dl>
          key = table_node.key if table_node.class.method_defined?(:key)
          if key
            key = [key] unless key.is_a?(Array)
            key.each do |dl_node|
              next unless dl_node
              # some vintages wrap the key dl in a KeyElement (WS3)
              if !dl_node.respond_to?(:dt) && dl_node.respond_to?(:dl)
                to_array(dl_node.dl).each do |inner|
                  dl = transform_definition_list(inner)
                  results << dl if dl
                end
                next
              end
              dl = transform_definition_list(dl_node)
              results << dl if dl
            end
          end

          # [SOURCE: …] → <t> (same element family as term sources)
          if table_node.respond_to?(:source)
            to_array(table_node.source).each do |src|
              t = transform_term_source(src)
              results << t if t
            end
          end

          # Notes → <aside> (vintage carries them on the singular
          # :note — prefer whichever collection is populated)
          notes = nil
          if table_node.class.method_defined?(:notes)
            notes = table_node.notes
          end
          if to_array(notes).empty? && table_node.respond_to?(:note)
            notes = table_node.note
          end
          if notes
            notes = [notes] unless notes.is_a?(Array)
            notes.each do |note_node|
              aside = transform_note(note_node, nil)
              results << aside if aside
            end
          end

          results
        end

      end
    end
  end
end
