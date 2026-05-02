# frozen_string_literal: true

module Metanorma
  module Ietf
    module Transformer
      module CleanupTransformer
        private

        BCP14_KEYWORDS = [
          "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
          "SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED",
          "MAY", "OPTIONAL",
          "must", "must not", "required", "shall", "shall not",
          "should", "should not", "recommended", "not recommended",
          "may", "optional",
        ].freeze

        INLINE_ATTRS = %i[em strong tt sub sup eref xref relref bcp14 iref cref br u].freeze

        def cleanup(rfc)
          li_cleanup(rfc)
          sourcecode_cleanup(rfc)
          deflist_cleanup(rfc)
          bcp14_cleanup(rfc)
          front_cleanup(rfc)
          biblio_cleanup(rfc)
          cref_cleanup(rfc)
          aside_cleanup(rfc)
          figure_cleanup(rfc)
          unicode_cleanup(rfc)
          image_cleanup(rfc)
          rfc
        end

        # ── Model traversal helpers ──────────────────────────────

        def walk_sections(sections, &block)
          return unless sections
          sections = [sections] unless sections.is_a?(Array)
          sections.compact.each do |section|
            block.call(section)
            walk_sections(section.section, &block)
          end
        end

        def walk_all_sections(rfc, &block)
          walk_sections(rfc.middle&.section, &block) if rfc.middle
          walk_sections(rfc.back&.section, &block) if rfc.back
        end

        # ── List Item Unwrapping ────────────────────────────────

        def li_cleanup(rfc)
          walk_all_sections(rfc) do |section|
            cleanup_list_items(section.ul) if section.ul.is_a?(Array)
            cleanup_list_items(section.ol) if section.ol.is_a?(Array)
            walk_nested_list_items(section)
          end
        end

        def cleanup_list_items(lists)
          return unless lists.is_a?(Array)
          lists.each { |list| cleanup_single_li_items(list) }
        end

        def cleanup_single_li_items(list)
          return unless list && list.li.is_a?(Array)
          list.li.each do |li|
            unwrap_single_t_in_li(li)
            cleanup_list_items(li.ul)
            cleanup_list_items(li.ol)
          end
        end

        def unwrap_single_t_in_li(li)
          return unless li.t.is_a?(Array) && li.t.size == 1
          has_other_children = false
          %i[ul ol dl sourcecode table figure blockquote].each do |attr|
            val = li.send(attr)
            if val.is_a?(Array) && !val.empty?
              has_other_children = true
              break
            end
          end
          return if has_other_children

          t = li.t.first
          t_content = extract_text_content(t)
          li_content = li.content

          if li_content.is_a?(Array) && li_content.any? { |c| c.to_s.strip.empty? } && t_content && !t_content.strip.empty?
            li.content = [t_content]
          elsif li_content.nil? || (li_content.is_a?(Array) && li_content.all? { |c| c.to_s.strip.empty? })
            li.content = [t_content]
          else
            existing = li_content.is_a?(Array) ? li_content.join : li_content.to_s
            new_content = existing.strip.empty? ? t_content : existing + t_content
            li.content = [new_content]
          end

          migrate_inline_elements(t, li)

          li.t = []
          li.element_order = nil
        end

        def extract_text_content(text_elem)
          return "" unless text_elem
          content = text_elem.content
          return content.is_a?(Array) ? content.join : content.to_s if content
          ""
        end

        def migrate_inline_elements(source, target)
          INLINE_ATTRS.each do |attr|
            src_val = source.send(attr)
            next unless src_val.is_a?(Array) && !src_val.empty?
            tgt_val = target.send(attr)
            tgt_val = [] unless tgt_val.is_a?(Array)
            tgt_val.concat(src_val)
            target.send(:"#{attr}=", tgt_val)
          end
        end

        def walk_nested_list_items(section)
          return unless section.section.is_a?(Array)
          section.section.each do |sub|
            cleanup_list_items(sub.ul) if sub.ul.is_a?(Array)
            cleanup_list_items(sub.ol) if sub.ol.is_a?(Array)
            walk_nested_list_items(sub)
          end
        end

        # ── Definition List Cleanup ──────────────────────────────

        def deflist_cleanup(rfc)
          walk_all_sections(rfc) do |section|
            cleanup_definition_lists(section.dl) if section.dl.is_a?(Array)
          end
        end

        def cleanup_definition_lists(dls)
          return unless dls.is_a?(Array)
          dls.each { |dl| cleanup_single_dl(dl) }
        end

        def cleanup_single_dl(dl)
          return unless dl && dl.dt.is_a?(Array)
          dl.dt.each { |dt| dt_cleanup_single(dt) }
          dl.dd.each { |dd| dd_cleanup_single(dd) } if dl.dd.is_a?(Array)
        end

        def dt_cleanup_single(dt)
          return unless dt
          if dt.xref.is_a?(Array)
            dt.xref.each do |xref|
              if xref.target && !xref.target.empty?
                dt.anchor ||= xref.target
              end
            end
          end
        end

        def dd_cleanup_single(dd)
          return unless dd
          if dd.t.is_a?(Array) && !dd.t.empty?
            first_t = dd.t.first
            dd.anchor ||= first_t.anchor if first_t.anchor
          end
        end

        # ── Sourcecode Cleanup ──────────────────────────────────

        def sourcecode_cleanup(rfc)
          walk_all_sections(rfc) do |section|
            cleanup_sourcecodes(section.sourcecode) if section.sourcecode.is_a?(Array)
            cleanup_sourcecodes_in_text(section.t) if section.t.is_a?(Array)
          end
        end

        def cleanup_sourcecodes(sourcecodes)
          return unless sourcecodes.is_a?(Array)
          sourcecodes.each { |sc| cleanup_single_sourcecode(sc) }
        end

        def cleanup_sourcecodes_in_text(texts)
          return unless texts.is_a?(Array)
          texts.each { |t| cleanup_single_sourcecode(t) if t.is_a?(Rfcxml::V3::Sourcecode) }
        end

        def cleanup_single_sourcecode(sc)
          return unless sc
          content = sc.content
          return unless content.is_a?(Array)
          cleaned = content.map do |c|
            next c unless c.is_a?(String)
            c.gsub("<br/>", "\n").gsub("<br/>", "\n")
              .gsub(%r{\s+<t[ >]}, "<t>")
              .gsub("</t>", "")
              .gsub(%r{</?[^>]+>}, "")
          end
          sc.content = cleaned
        end

        # ── BCP14 from Strong ───────────────────────────────────

        def bcp14_cleanup(rfc)
          walk_all_text_elements(rfc) do |text_elem|
            convert_strong_to_bcp14(text_elem)
          end
        end

        def walk_all_text_elements(rfc, &block)
          if rfc.front && rfc.front.abstract
            abs = rfc.front.abstract
            abs.t.each { |t| block.call(t) } if abs.t.is_a?(Array)
          end

          walk_all_sections(rfc) do |section|
            section.t.each { |t| block.call(t) } if section.t.is_a?(Array)
            section.blockquote.each { |bq| bq.t.each { |t| block.call(t) } if bq.t.is_a?(Array) } if section.blockquote.is_a?(Array)
            walk_t_in_lists(section, &block)
          end
        end

        def walk_t_in_lists(section, &block)
          %i[ul ol].each do |list_attr|
            next unless section.send(list_attr).is_a?(Array)
            section.send(list_attr).each { |list| walk_t_in_li(list, &block) }
          end
        end

        def walk_t_in_li(list, &block)
          return unless list && list.li.is_a?(Array)
          list.li.each do |li|
            li.t.each { |t| block.call(t) } if li.t.is_a?(Array)
            li.ul.each { |ul| walk_t_in_li(ul, &block) } if li.ul.is_a?(Array)
            li.ol.each { |ol| walk_t_in_li(ol, &block) } if li.ol.is_a?(Array)
          end
        end

        def convert_strong_to_bcp14(text_elem)
          strongs = text_elem.strong
          return unless strongs.is_a?(Array)

          changed = false
          new_strongs = []
          strongs.each_with_index do |s, i|
            text = extract_bcp14_text(s)
            if bcp14_keyword?(text)
              bcp = Rfcxml::V3::Bcp14.new
              bcp.content = text.upcase
              safe_append(text_elem, :bcp14, bcp)
              replace_in_element_order(text_elem, "strong", i, "bcp14")
              changed = true
            else
              new_strongs << s
            end
          end

          text_elem.strong = new_strongs if changed
        end

        def extract_bcp14_text(strong_elem)
          content = strong_elem.content
          return content.is_a?(Array) ? content.join.strip : content.to_s.strip if content
          ""
        end

        def bcp14_keyword?(text)
          return false unless text
          BCP14_KEYWORDS.include?(text)
        end

        def replace_in_element_order(text_elem, old_tag, old_idx, new_tag)
          order = text_elem.element_order
          return unless order.is_a?(Array)

          count = 0
          order.each_with_index do |e, i|
            next if e.text?
            if e.element_tag == old_tag
              if count == old_idx
                order[i] = Lutaml::Xml::Element.new("Element", new_tag)
                return
              end
              count += 1
            end
          end
        end

        # ── Front Cleanup ──────────────────────────────────────

        def front_cleanup(rfc)
          return unless rfc.front
          cleanup_front_title(rfc.front.title) if rfc.front.title
        end

        def cleanup_front_title(title)
          return unless title
          content = title.content
          return unless content.is_a?(Array)
          title.content = content.map { |c| c.to_s.gsub(%r{</?[^>]+>}, "") }
        end

        # ── Bibliography Cleanup ───────────────────────────────

        def biblio_cleanup(rfc)
          return unless rfc.back && rfc.back.references.is_a?(Array)
          rfc.back.references.each do |refs|
            next unless refs.reference.is_a?(Array)
            refs.reference.each do |ref|
              cleanup_single_reference(ref)
            end
            # Nested references
            if refs.references.is_a?(Array)
              refs.references.each do |nested_refs|
                next unless nested_refs.reference.is_a?(Array)
                nested_refs.reference.each do |ref|
                  cleanup_single_reference(ref)
                end
              end
            end
          end
        end

        def cleanup_single_reference(ref)
          return unless ref
          biblio_refcontent_cleanup(ref)
          biblio_format_cleanup(ref)
        end

        def biblio_refcontent_cleanup(ref)
          return unless ref.refcontent.is_a?(Array)
          ref.refcontent.each do |rc|
            content = rc.content
            if content.is_a?(Array)
              val = content.map(&:to_s).join.strip
              if val.empty?
                ref.refcontent.delete(rc)
              else
                rc.content = [val]
              end
            end
          end
        end

        def biblio_format_cleanup(ref)
          ref.format = [] if ref.format.is_a?(Array)
        end

        # ── Aside Cleanup ──────────────────────────────────────

        def aside_cleanup(rfc)
          walk_all_sections(rfc) do |section|
            cleanup_asides_in_blockquotes(section)
            cleanup_asides_in_lists(section)
          end
        end

        def cleanup_asides_in_blockquotes(section)
          return unless section.blockquote.is_a?(Array)
          section.blockquote.each do |bq|
            next unless bq.t.is_a?(Array)
            moved_asides = extract_moved_asides(bq, :t)
            moved_asides.each do |aside|
              safe_append(section, :aside, aside)
            end
          end
        end

        def cleanup_asides_in_lists(section)
          %i[ul ol].each do |list_type|
            next unless section.send(list_type).is_a?(Array)
            section.send(list_type).each { |list| cleanup_asides_in_list_items(list, section) }
          end
        end

        def cleanup_asides_in_list_items(list, section)
          return unless list && list.li.is_a?(Array)
          # Li doesn't have aside collection in RFC XML v3 — no cleanup needed
        end

        def extract_moved_asides(container, child_attr)
          moved = []
          children = container.send(child_attr)
          return moved unless children.is_a?(Array)

          # Check if any children are Aside elements
          aside_children = children.select { |c| c.is_a?(Rfcxml::V3::Aside) }
          return moved if aside_children.empty?

          aside_children.each do |aside|
            children.delete(aside)
            moved << aside
          end

          moved
        end

        # ── Unicode Wrapping ───────────────────────────────────

        UNICODE_PARENT_TAGS = Set.new(%w[t blockquote li dd preamble td th annotation dt]).freeze

        def unicode_cleanup(rfc)
          walk_all_text_elements(rfc) do |text_elem|
            wrap_unicode_in_text(text_elem)
          end

          # Also walk DD and TD elements
          walk_all_sections(rfc) do |section|
            wrap_unicode_in_dd(section.dl) if section.dl.is_a?(Array)
            wrap_unicode_in_td(section.table) if section.table.is_a?(Array)
          end
        end

        def wrap_unicode_in_text(text_elem)
          content = text_elem.content
          return unless content.is_a?(Array)
          return if content.empty?

          new_content = []
          changed = false

          content.each do |fragment|
            if fragment.is_a?(String) && contains_unicode?(fragment)
              parts = split_unicode(fragment)
              new_content.concat(parts)
              changed = true
            else
              new_content << fragment
            end
          end

          return unless changed

          # Build new element_order with <u> elements
          u_elements = []
          new_content.each do |part|
            next if part.is_a?(String)
            if part.is_a?(Rfcxml::V3::U)
              u_elements << part
            end
          end

          u_elements.each { |u| safe_append(text_elem, :u, u) }
          text_elem.content = new_content
        end

        def wrap_unicode_in_dd(dls)
          return unless dls.is_a?(Array)
          dls.each do |dl|
            next unless dl.dd.is_a?(Array)
            dl.dd.each do |dd|
              next unless dd.t.is_a?(Array)
              dd.t.each { |t| wrap_unicode_in_text(t) }
            end
          end
        end

        def wrap_unicode_in_td(tables)
          return unless tables.is_a?(Array)
          tables.each do |table|
            [:thead, :tbody, :tfoot].each do |section|
              rows = table.send(section)
              next unless rows.is_a?(Rfcxml::V3::Tbody)
              next unless rows.tr.is_a?(Array)
              rows.tr.each do |tr|
                [:th, :td].each do |cell_type|
                  cells = tr.send(cell_type)
                  next unless cells.is_a?(Array)
                  cells.each do |cell|
                    next unless cell.t.is_a?(Array)
                    cell.t.each { |t| wrap_unicode_in_text(t) }
                  end
                end
              end
            end
          end
        end

        def contains_unicode?(text)
          text.match?(/[\u0080-\uffff]/)
        end

        def split_unicode(text)
          parts = []
          buffer = ""
          text.each_char do |ch|
            if ch.match?(/[\u0080-\uffff]/)
              unless buffer.empty?
                parts << buffer
                buffer = ""
              end
              u = Rfcxml::V3::U.new
              u.format = "lit-name-num"
              u.content = ch
              u.ascii = unicode_char_name(ch)
              parts << u
            else
              buffer += ch
            end
          end
          parts << buffer unless buffer.empty?
          parts
        end

        def unicode_char_name(ch)
          begin
            name = Unicode::Name.of(ch)
            return name.downcase if name && !name.empty?
          rescue StandardError
            nil
          end
          "U+#{ch.ord.to_s(16).upcase.rjust(4, '0')}"
        end

        # ── Inline Image Cleanup ───────────────────────────────

        def image_cleanup(rfc)
          return unless @queued_images && !@queued_images.empty?

          walk_all_sections(rfc) do |section|
            next unless section.t.is_a?(Array)
            section.t.each do |t|
              extract_queued_images(t, section)
            end
          end
        end

        def extract_queued_images(text_elem, section)
          content = text_elem.content
          return unless content.is_a?(Array)

          indices_to_extract = []
          content.each_with_index do |fragment, i|
            next unless fragment.is_a?(String)
            @queued_images.each do |qi|
              if fragment.include?("[IMAGE #{qi[:number]}]")
                indices_to_extract << { index: i, image: qi }
              end
            end
          end

          return if indices_to_extract.empty?

          indices_to_extract.each do |item|
            figure = Rfcxml::V3::Figure.new
            safe_append(figure, :artwork, item[:image][:artwork])
            safe_append(section, :figure, figure)

            content[item[:index]] = content[item[:index]].gsub("[IMAGE #{item[:image][:number]}]", "")
            @queued_images.delete(item[:image])
          end

          text_elem.content = content
        end

        # ── Cref Cleanup ──────────────────────────────────────

        def cref_cleanup(rfc)
          # Crefs are rendered as section-level elements by annotation_transformer.
          # Walk all sections looking for cref elements and unwrap them from t wrappers.
          cref_unwrap(rfc)
        end

        def cref_unwrap(rfc)
          walk_all_sections(rfc) do |section|
            next unless section.cref.is_a?(Array)
            crefs = section.cref.dup
            crefs.each do |cref|
              next unless cref.content.is_a?(Array) && !cref.content.empty?
              # Crefs with text content are fine as-is
            end
          end
        rescue NoMethodError
          # Section may not have cref collection
        end

        # ── Figure Cleanup ───────────────────────────────────

        def figure_cleanup(rfc)
          unnest_figures(rfc)
        end

        def unnest_figures(rfc)
          walk_all_sections(rfc) do |section|
            next unless section.figure.is_a?(Array)
            section.figure.dup.each do |fig|
              inner_figs = fig.figure rescue nil
              next unless inner_figs.is_a?(Array) && !inner_figs.empty?
              inner_figs.each { |f| safe_append(section, :figure, f) }
              fig.figure = []
            end
          end
        rescue NoMethodError
          nil
        end
      end
    end
  end
end
