# frozen_string_literal: true

module Metanorma
  module Ietf
    module Transformer
      module TableTransformer
        private

        def transform_table(table_node)
          table = Rfcxml::V3::Table.new
          table.anchor = to_ncname(table_node.id) if table_node.id

          # Handle unnumbered tables
          if table_node.unnumbered == "true"
            table.anchor = nil
          end

          name_node = table_node.name
          if name_node
            name = Rfcxml::V3::Name.new
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

          rows = section_node.tr
          rows = [rows] unless rows.is_a?(Array)

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
            cells = tr_node.th
            cells = [cells] unless cells.is_a?(Array)
            cells.each do |cell|
              tc = transform_table_cell(cell)
              safe_append(tr, :th, tc) if tc
            end
            # Also check for td cells in header rows (fallback)
            if tr.th.nil? || !tr.th.is_a?(Array) || tr.th.empty?
              td_cells = tr_node.td
              td_cells = [td_cells] unless td_cells.is_a?(Array)
              td_cells.each do |cell|
                tc = transform_table_cell(cell)
                safe_append(tr, :th, tc) if tc
              end
            end
          else
            # Check for th cells in body rows
            th_cells = tr_node.th
            if th_cells
              th_cells = [th_cells] unless th_cells.is_a?(Array)
              th_cells.each do |cell|
                tc = transform_table_cell(cell)
                safe_append(tr, :th, tc) if tc
              end
            end

            cells = tr_node.td
            cells = [cells] unless cells.is_a?(Array)
            cells.each do |cell|
              tc = transform_table_cell(cell)
              safe_append(tr, :td, tc) if tc
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

          # Table cells use .text attribute (Array of String)
          if cell_node.text
            text_val = cell_node.text
            text_val = text_val.join if text_val.is_a?(Array)
            tc.content = [text_val] if !text_val.to_s.strip.empty?
          end

          tc
        end

        def build_table_surroundings(table_node, _section)
          results = []

          # Key → <dl>
          key = table_node.key rescue nil
          if key
            key = [key] unless key.is_a?(Array)
            key.each do |dl_node|
              next unless dl_node
              dl = transform_definition_list(dl_node)
              results << dl if dl
            end
          end

          # Notes → <aside>
          notes = table_node.notes rescue nil
          if notes
            notes = [notes] unless notes.is_a?(Array)
            notes.each do |note_node|
              aside = transform_note(note_node, nil)
              results << aside if aside
            end
          end

          results
        end

        def format_source_text(source)
          return ls_text(source) if source
          nil
        end
      end
    end
  end
end
