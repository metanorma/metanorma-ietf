# frozen_string_literal: true

require "cgi"

module Metanorma
  module Ietf
    module Transformer
      module ReferenceTransformer
        private

        def transform_references_section(refs_node)
          references = Rfcxml::V3::References.new
          references.anchor = to_ncname(refs_node.id) if refs_node.id

          title = refs_node.title
          if title
            name = Rfcxml::V3::Name.new
            name_text = ls_text(title)
            name.content = [name_text] if name_text && !name_text.empty?
            references.name = name unless name.content.nil? || name.content.empty?
          end

          src_order = refs_node.element_order
          bibitems = to_array(refs_node.references)
          bibitem_queue = bibitems.dup

          passthroughs = to_array(refs_node.passthrough)
          pass_queue = passthroughs.dup

          if src_order && src_order.any?
            src_order.each do |e|
              next if e.text?
              case e.element_tag
              when "passthrough"
                pass_model = pass_queue.shift
                raw_ref = extract_passthrough_reference(pass_model) if pass_model
                safe_append(references, :reference, raw_ref) if raw_ref
              when "bibitem"
                ref = transform_bibitem(bibitem_queue.shift)
                safe_append(references, :reference, ref) if ref
              end
            end
          else
            pass_queue.each do |pass_model|
              raw_ref = extract_passthrough_reference(pass_model)
              safe_append(references, :reference, raw_ref) if raw_ref
            end
            bibitem_queue.each do |bibitem|
              next unless bibitem
              next if hidden_bibitem?(bibitem)
              ref = transform_bibitem(bibitem)
              safe_append(references, :reference, ref) if ref
            end
          end

          references
        end

        def hidden_bibitem?(bibitem)
          bibitem && bibitem.hidden == "true"
        end

        def extract_passthrough_reference(pass_model)
          content = pass_model.content
          return nil if content.nil? || content.strip.empty?

          content = CGI.unescapeHTML(content)

          begin
            ref = Rfcxml::V3::Reference.from_xml(content)
            return ref if ref
          rescue StandardError
            nil
          end

          nil
        end

        def transform_bibitem(bibitem)
          return nil unless bibitem

          if reference_group?(bibitem)
            return transform_referencegroup(bibitem)
          end

          if formattedref_only?(bibitem)
            return transform_formattedref_bibitem(bibitem)
          end

          ref = Rfcxml::V3::Reference.new

          ref.anchor = bibitem_anchor(bibitem)

          target = extract_bibitem_target(bibitem)
          ref.target = target if target && !target.empty?

          front = Rfcxml::V3::Front.new

          title = extract_bibitem_title(bibitem)
          if title && !title.empty?
            t = Rfcxml::V3::Title.new
            t.content = [title]
            front.title = t
          end

          authors = extract_bibitem_authors(bibitem)
          front.author = authors

          date = extract_bibitem_date(bibitem)
          front.date = date if date

          abstract = extract_bibitem_abstract(bibitem)
          front.abstract = abstract if abstract

          ref.front = front

          refcontent_text = extract_bibitem_refcontent(bibitem)
          if refcontent_text && !refcontent_text.empty?
            rc = Rfcxml::V3::Refcontent.new
            rc.content = [refcontent_text]
            safe_append(ref, :refcontent, rc)
          end

          series_infos = extract_bibitem_series_info(bibitem)
          series_infos.each { |si| safe_append(ref, :series_info, si) }

          annotation_text = extract_bibitem_annotation(bibitem)
          if annotation_text && !annotation_text.empty?
            ann = Rfcxml::V3::Annotation.new
            ann.content = annotation_text
            safe_append(ref, :annotation, ann)
          end

          ref
        end

        def reference_group?(bibitem)
          return false unless bibitem
          constituents = bibitem.constituent
          return false unless constituents
          consts = [constituents].flatten
          consts.any? { |c| c && !c.to_s.strip.empty? }
        rescue NoMethodError
          false
        end

        def transform_referencegroup(bibitem)
          group = Rfcxml::V3::Referencegroup.new
          group.anchor = bibitem_anchor(bibitem)

          target = extract_bibitem_target(bibitem)
          group.target = target if target && !target.empty?

          to_array(bibitem.constituent).each do |constituent|
            next unless constituent
            ref = transform_constituent(constituent)
            safe_append(group, :reference, ref) if ref
          end

          group
        end

        def transform_constituent(constituent)
          ref = Rfcxml::V3::Reference.new

          if constituent.id
            ref.anchor = to_ncname(constituent.id)
          end

          if constituent.title
            title_text = ls_text(constituent.title)
            if title_text && !title_text.empty?
              front = ref.front || Rfcxml::V3::Front.new
              t = Rfcxml::V3::Title.new
              t.content = [title_text]
              front.title = t
              ref.front = front
            end
          end

          to_array(constituent.docidentifier).each do |d|
            next unless d.type == "IETF" || d.type == "DOI"
            si = Rfcxml::V3::SeriesInfo.new
            si.name = d.type
            si.value = id_content(d)
            safe_append(ref, :series_info, si) if si.value && !si.value.empty?
          end

          ref
        end

        def formattedref_only?(bibitem)
          return false unless bibitem
          title = extract_bibitem_title(bibitem)
          title.nil? || title.empty?
        end

        def transform_formattedref_bibitem(bibitem)
          ref = Rfcxml::V3::Reference.new
          ref.anchor = bibitem_anchor(bibitem)

          target = extract_bibitem_target(bibitem)
          ref.target = target if target && !target.empty?

          front = Rfcxml::V3::Front.new

          formatted = bibitem.formatted_ref
          if formatted
            title_text = ls_text(formatted)
            if title_text && !title_text.empty?
              t = Rfcxml::V3::Title.new
              t.content = [title_text]
              front.title = t
            end
          end

          authors = extract_bibitem_authors(bibitem)
          if authors.nil? || authors.empty?
            author = Rfcxml::V3::Author.new
            author.surname = "Unknown"
            front.author = [author]
          else
            front.author = authors
          end

          ref.front = front

          series_infos = extract_bibitem_series_info(bibitem)
          series_infos.each { |si| safe_append(ref, :series_info, si) }

          refcontent_text = extract_bibitem_refcontent(bibitem)
          if refcontent_text && !refcontent_text.empty?
            rc = Rfcxml::V3::Refcontent.new
            rc.content = [refcontent_text]
            safe_append(ref, :refcontent, rc)
          end

          annotation_text = extract_bibitem_annotation(bibitem)
          if annotation_text && !annotation_text.empty?
            ann = Rfcxml::V3::Annotation.new
            ann.content = annotation_text
            safe_append(ref, :annotation, ann)
          end

          ref
        end

        def bibitem_anchor(bibitem)
          return nil unless bibitem

          return bibitem.anchor if bibitem.anchor && !bibitem.anchor.to_s.empty?

          ids = to_array(bibitem.docidentifier)
          ietf_id = ids.find { |d| d.type == "IETF" }
          if ietf_id
            text = id_content(ietf_id)
            return text.gsub(/\s/, "") if text && !text.empty?
          end

          rfc_anchor = ids.find { |d| d.type == "rfc-anchor" }
          return id_content(rfc_anchor) if rfc_anchor

          to_ncname(bibitem.id) if bibitem.id
        end

        def extract_bibitem_target(bibitem)
          uris = to_array(bibitem.link)

          src = uris.find { |u| u.type == "src" }
          if src
            text = u_content(src)
            return text if text && !text.empty?
          end

          u_content(uris.first) if uris.first
        end

        def extract_bibitem_title(bibitem)
          titles = to_array(bibitem.title)

          first = titles.first
          return ls_text(first) if first

          nil
        end

        def extract_bibitem_authors(bibitem)
          authors = []
          publishers = []
          to_array(bibitem.contributor).each do |contrib|
            next unless contrib.role
            roles = to_array(contrib.role)
            role_type = roles.first&.type

            org = contrib.organization
            person = contrib.person

            author = build_bibitem_author(person, org)

            case role_type
            when "author", "editor"
              authors << author if author
            when "publisher"
              publishers << author if author
            end
          end

          authors.empty? ? publishers : authors
        end

        def build_bibitem_author(person, org)
          author = Rfcxml::V3::Author.new
          if person && person.name
            name = person.name
            surname = ls_text(name.surname)
            complete = ls_text(name.complete_name)

            if surname
              author.surname = surname
              ascii_s = Sterile.transliterate(surname)
              author.ascii_surname = ascii_s unless ascii_s == surname

              forenames = name.forename
              if forenames.is_a?(Array) && !forenames.empty?
                parts = forenames.map { |f| ls_text(f).to_s.strip }.reject(&:empty?)
                if parts.any?
                  author.initials = parts.map { |p| "#{p.chars.first}." }.join(" ")
                  first_name = parts.first
                  author.fullname = "#{first_name} #{surname}"
                  ascii_full = "#{Sterile.transliterate(first_name)} #{ascii_s}"
                  author.ascii_fullname = ascii_full unless ascii_full == author.fullname
                end
              end
            elsif complete
              author.fullname = complete
              ascii = Sterile.transliterate(complete)
              author.ascii_fullname = ascii unless ascii == complete
            end
          end

          if org
            author.organization = build_organization(org)
          end

          author
        end

        def extract_bibitem_date(bibitem)
          dates = to_array(bibitem.date)

          pub = dates.find { |d| d.type == "published" }
          return nil unless pub

          date = Rfcxml::V3::Date.new
          on = pub.on
          if on
            on_str = date_value_to_str(on, bibitem)
            parse_date_into(date, on_str)
          elsif pub.text && !pub.text.empty?
            parse_date_into(date, pub.text)
          end
          date
        end

        def date_value_to_str(val, _bibitem = nil)
          return val if val.is_a?(String)
          if val.content
            val.content.to_s
          elsif val.text
            val.text.to_s
          elsif val.is_a?(Date) || val.is_a?(Time)
            val.strftime("%Y-%m-%d")
          else
            val.to_s
          end
        end

        def extract_bibitem_abstract(bibitem)
          abstracts = to_array(bibitem.abstract)
          return nil if abstracts.empty?

          abs_text = abstracts.first
          text = ls_text(abs_text)
          return nil if text.nil? || text.empty?

          abstract = Rfcxml::V3::Abstract.new
          t = Rfcxml::V3::Text.new
          t.content = [text]
          safe_append(abstract, :t, t)
          abstract
        end

        def extract_bibitem_refcontent(bibitem)
          ids = to_array(bibitem.docidentifier)

          id = ids.find { |d| d.type == "IETF" }
          id ||= ids.find { |d| d.type == "ISO" }
          id ||= ids.first

          return nil unless id
          id_content(id)
        end

        def extract_bibitem_series_info(bibitem)
          infos = []

          to_array(bibitem.docidentifier).each do |d|
            next unless d.type == "IETF" || d.type == "DOI"
            si = Rfcxml::V3::SeriesInfo.new
            si.name = d.type
            si.value = id_content(d)
            infos << si if si.value && !si.value.empty?
          end

          infos
        end

        def extract_bibitem_annotation(bibitem)
          return nil unless bibitem
          notes = bibitem.note
          return nil unless notes
          notes = [notes] unless notes.is_a?(Array)
          texts = notes.map { |n| ls_text(n) }.compact.reject(&:empty?)
          return nil if texts.empty?
          texts.join(" ")
        end

        def u_content(typed_uri)
          return nil unless typed_uri
          return typed_uri.content if typed_uri.content
          ls_text(typed_uri)
        end

        def id_content(doc_id)
          return nil unless doc_id
          return doc_id.id if doc_id.id
          ls_text(doc_id)
        end

      end
    end
  end
end
