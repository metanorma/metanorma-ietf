# frozen_string_literal: true

module Metanorma
  module Ietf
    module Transformer
      module RfcV3ToIetf
        # Transforms RFC XML v3 <table> elements into Metanorma table model objects.
        module TableTransformer
          private

          def transform_table(table_node)
            return nil unless table_node

            table = Metanorma::Document::Components::Tables::TableBlock.new(
              id: resolve_id(table_node),
            )

            # Table name/title
            title_text = table_node.name ? extract_rfc_text(table_node.name) : nil
            table.name = build_name_element(title_text) if title_text && !title_text.empty?

            # Thead
            if table_node.thead
              table.thead = transform_table_head(table_node.thead)
            end

            # Tbody (collection)
            to_array(table_node.tbody).each do |tbody_node|
              tbody = transform_table_body_section(tbody_node, :tbody)
              table.tbody = tbody
            end

            # Tfoot
            if table_node.tfoot
              table.tfoot = transform_table_body_section(table_node.tfoot, :tfoot)
            end

            table
          end

          def transform_table_head(thead_node)
            return nil unless thead_node

            rows = to_array(thead_node.tr).map { |tr| transform_table_row(tr) }
            Metanorma::Document::Components::Tables::TableHeadSection.new(tr: rows)
          end

          def transform_table_body_section(section_node, _type)
            return nil unless section_node

            rows = to_array(section_node.tr).map { |tr| transform_table_row(tr) }

            case _type
            when :tbody
              Metanorma::Document::Components::Tables::TableBodySection.new(tr: rows)
            when :tfoot
              Metanorma::Document::Components::Tables::TableFootSection.new(tr: rows)
            end
          end

          def transform_table_row(tr_node)
            return nil unless tr_node

            row = Metanorma::Document::Components::Tables::TextTableRow.new(
              id: resolve_id(tr_node),
            )

            to_array(tr_node.td).each do |td_node|
              cell = transform_table_cell(td_node)
              row.td = to_array(row.td)
              row.td << cell if cell
            end

            to_array(tr_node.th).each do |th_node|
              cell = transform_table_cell(th_node)
              row.th = to_array(row.th)
              row.th << cell if cell
            end

            row
          end

          def transform_table_cell(td_node)
            return nil unless td_node

            cell = Metanorma::Document::Components::Tables::TextTableCell.new
            cell.id = resolve_id(td_node) if td_node.anchor && !td_node.anchor.to_s.empty?
            cell.colspan = td_node.colspan.to_i if td_node.colspan
            cell.rowspan = td_node.rowspan.to_i if td_node.rowspan
            cell.align = td_node.align if td_node.align && !td_node.align.to_s.empty?

            # Cell content — may have mixed inline content or block content
            text = extract_rfc_mixed_text(td_node)
            cell.text = [text] if text && !text.empty?

            # If cell has block children (paragraphs, lists, etc.), transform those
            to_array(td_node.t).each do |t_node|
              p = transform_t(t_node)
              cell.p = to_array(cell.p)
              cell.p << p if p
            end

            cell
          end
        end
      end
    end
  end
end
