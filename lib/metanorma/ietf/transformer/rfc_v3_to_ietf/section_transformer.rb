# frozen_string_literal: true

module Metanorma
  module Ietf
    module Transformer
      module RfcV3ToIetf
        # Transforms RFC XML v3 <section> elements into Metanorma clauses.
        module SectionTransformer
          private

          def transform_section(section_node)
            return nil unless section_node

            clause = Metanorma::IsoDocument::Sections::IsoClauseSection.new(
              id: resolve_id(section_node),
            )

            # Title
            title_text = section_node.title || (section_node.name ? extract_rfc_text(section_node.name) : nil)
            if title_text && !title_text.empty?
              OrderTracker.set_ordered(clause, :title, build_title_element(title_text))
            end

            # Section attributes
            clause.unnumbered = section_node.numbered if section_node.numbered && section_node.numbered.to_s == "false"
            clause.toc = section_node.toc if section_node.toc && section_node.toc.to_s != "default"

            # Transform children in order
            transform_section_children(section_node, clause)

            clause
          end

          def transform_annex(section_node)
            return nil unless section_node

            annex = Metanorma::IsoDocument::Sections::IsoAnnexSection.new(
              id: resolve_id(section_node),
              obligation: "informative",
            )

            title_text = section_node.title || (section_node.name ? extract_rfc_text(section_node.name) : nil)
            if title_text && !title_text.empty?
              OrderTracker.set_ordered(annex, :title, build_title_element(title_text))
            end

            transform_section_children(section_node, annex)

            annex
          end

          def transform_section_children(section_node, target)
            # Walk element_order if available for proper interleaving
            if section_node.element_order.is_a?(Array) && !section_node.element_order.empty?
              transform_children_by_order(section_node, target)
            else
              transform_children_by_attributes(section_node, target)
            end
          end

          def transform_children_by_order(section_node, target)
            counters = Hash.new(0)

            section_node.element_order.each do |entry|
              next if entry.text?

              attr_name = entry.name.to_sym
              idx = counters[attr_name]
              counters[attr_name] += 1
              transform_child_element(section_node, target, attr_name, idx)
            end
          end

          def transform_children_by_attributes(section_node, target)
            # Paragraphs
            to_array(section_node.t).each do |t_node|
              p = transform_t(t_node)
              OrderTracker.append_ordered(target, :paragraphs, p) if p
            end

            # Sub-sections
            to_array(section_node.section).each do |sub|
              clause = transform_section(sub)
              OrderTracker.append_ordered(target, :clause, clause) if clause
            end

            # Lists
            to_array(section_node.ul).each do |ul|
              list = transform_ul(ul)
              OrderTracker.append_ordered(target, :unordered_lists, list) if list
            end

            to_array(section_node.ol).each do |ol|
              list = transform_ol(ol)
              OrderTracker.append_ordered(target, :ordered_lists, list) if list
            end

            to_array(section_node.dl).each do |dl|
              list = transform_dl(dl)
              OrderTracker.append_ordered(target, :definition_lists, list) if list
            end

            # Figures
            to_array(section_node.figure).each do |fig|
              figure = transform_figure(fig)
              OrderTracker.append_ordered(target, :figures, figure) if figure
            end

            # Tables
            to_array(section_node.table).each do |tbl|
              table = transform_table(tbl)
              OrderTracker.append_ordered(target, :tables, table) if table
            end

            # Sourcecode
            to_array(section_node.sourcecode).each do |sc|
              sourcecode = transform_sourcecode(sc)
              OrderTracker.append_ordered(target, :sourcecode_blocks, sourcecode) if sourcecode
            end

            # Blockquotes
            to_array(section_node.blockquote).each do |bq|
              quote = transform_blockquote(bq)
              OrderTracker.append_ordered(target, :quote_blocks, quote) if quote
            end

            # Asides → notes
            to_array(section_node.aside).each do |aside|
              note = transform_aside_to_note(aside)
              OrderTracker.append_ordered(target, :notes, note) if note
            end
          end

          def transform_child_element(section_node, target, attr_name, idx)
            case attr_name
            when :t
              children = to_array(section_node.t)
              t_node = children[idx]
              if t_node
                p = transform_t(t_node)
                OrderTracker.append_ordered(target, :paragraphs, p) if p
              end
            when :section
              children = to_array(section_node.section)
              sub = children[idx]
              if sub
                clause = transform_section(sub)
                OrderTracker.append_ordered(target, :clause, clause) if clause
              end
            when :ul
              children = to_array(section_node.ul)
              ul = children[idx]
              if ul
                list = transform_ul(ul)
                OrderTracker.append_ordered(target, :unordered_lists, list) if list
              end
            when :ol
              children = to_array(section_node.ol)
              ol = children[idx]
              if ol
                list = transform_ol(ol)
                OrderTracker.append_ordered(target, :ordered_lists, list) if list
              end
            when :dl
              children = to_array(section_node.dl)
              dl = children[idx]
              if dl
                list = transform_dl(dl)
                OrderTracker.append_ordered(target, :definition_lists, list) if list
              end
            when :figure
              children = to_array(section_node.figure)
              fig = children[idx]
              if fig
                figure = transform_figure(fig)
                OrderTracker.append_ordered(target, :figures, figure) if figure
              end
            when :table
              children = to_array(section_node.table)
              tbl = children[idx]
              if tbl
                table = transform_table(tbl)
                OrderTracker.append_ordered(target, :tables, table) if table
              end
            when :sourcecode
              children = to_array(section_node.sourcecode)
              sc = children[idx]
              if sc
                sc_obj = transform_sourcecode(sc)
                OrderTracker.append_ordered(target, :sourcecode_blocks, sc_obj) if sc_obj
              end
            when :blockquote
              children = to_array(section_node.blockquote)
              bq = children[idx]
              if bq
                quote = transform_blockquote(bq)
                OrderTracker.append_ordered(target, :quote_blocks, quote) if quote
              end
            when :aside
              children = to_array(section_node.aside)
              aside = children[idx]
              if aside
                note = transform_aside_to_note(aside)
                OrderTracker.append_ordered(target, :notes, note) if note
              end
            end
          end
        end
      end
    end
  end
end
