# frozen_string_literal: true

module Metanorma
  module Ietf
    module Transformer
      module RfcV3ToIetf
        # Transforms RFC XML v3 <references>, <reference>, and
        # <referencegroup> elements into Metanorma
        # StandardReferencesSection / BibliographicItem model objects.
        module ReferenceTransformer
          private

          def transform_references_section(refs_node)
            return nil unless refs_node

            section = Metanorma::StandardDocument::Sections::StandardReferencesSection.new(
              id: refs_node.anchor,
            )

            # Title
            title_text = extract_refs_title(refs_node)
            section.title = build_title_element(title_text) if title_text

            # References and reference groups in order
            if refs_node.element_order.is_a?(Array) && !refs_node.element_order.empty?
              transform_refs_by_order(refs_node, section)
            else
              transform_refs_by_attributes(refs_node, section)
            end

            section
          end

          def transform_refs_by_order(refs_node, section)
            child_counts = Hash.new(0)

            refs_node.element_order.each do |entry|
              next if entry.text?

              case entry.name
              when "reference"
                refs = to_array(refs_node.reference)
                ref = refs[child_counts["reference"]]
                child_counts["reference"] += 1
                bibitem = transform_reference_to_bibitem(ref) if ref
                append_bibitem(section, bibitem)
              when "referencegroup"
                groups = to_array(refs_node.referencegroup)
                group = groups[child_counts["referencegroup"]]
                child_counts["referencegroup"] += 1
                bibitem = transform_referencegroup_to_bibitem(group) if group
                append_bibitem(section, bibitem)
              when "references"
                nested = to_array(refs_node.references)
                sub = nested[child_counts["references"]]
                child_counts["references"] += 1
                sub_section = transform_references_section(sub) if sub
                append_bibitem(section, sub_section)
              end
            end
          end

          def transform_refs_by_attributes(refs_node, section)
            to_array(refs_node.reference).each do |ref|
              bibitem = transform_reference_to_bibitem(ref)
              append_bibitem(section, bibitem)
            end

            to_array(refs_node.referencegroup).each do |group|
              bibitem = transform_referencegroup_to_bibitem(group)
              append_bibitem(section, bibitem)
            end

            to_array(refs_node.references).each do |nested|
              sub_section = transform_references_section(nested)
              append_bibitem(section, sub_section)
            end
          end

          def append_bibitem(section, item)
            return unless item

            section.references = to_array(section.references)
            section.references << item
          end

          def extract_refs_title(refs_node)
            if refs_node.name
              extract_rfc_text(refs_node.name)
            elsif refs_node.title && !refs_node.title.to_s.empty?
              refs_node.title.to_s
            else
              nil
            end
          end

          def transform_reference_to_bibitem(ref_node)
            return nil unless ref_node

            bibitem = Metanorma::Document::Components::BibData::BibliographicItem.new(
              id: ref_node.anchor,
            )

            # Title from front
            if ref_node.front
              populate_bibitem_from_front(bibitem, ref_node.front)
            end

            # Target → link
            if ref_node.target && !ref_node.target.to_s.empty?
              link = Metanorma::Document::Relaton::TypedUri.new(
                type: "src",
                content: ref_node.target,
              )
              bibitem.link = [link]
            end

            # SeriesInfo → docidentifier
            to_array(ref_node.series_info).each do |si|
              id = build_docidentifier_from_series(si)
              bibitem.docidentifier = to_array(bibitem.docidentifier)
              bibitem.docidentifier << id if id
            end

            # Refcontent → formattedRef
            refcontent_text = extract_refcontent_text(ref_node)
            if refcontent_text
              bibitem.formatted_ref = Metanorma::Document::Components::DataTypes::FormattedString.new(
                content: [refcontent_text],
              )
            end

            # Annotation → note
            to_array(ref_node.annotation).each do |ann|
              text = extract_rfc_text(ann)
              next if text.empty?

              note = Metanorma::Document::Relaton::TypedNote.new(
                type: "annotation",
              )
              note.content = [text]
              bibitem.note = to_array(bibitem.note)
              bibitem.note << note
            end

            bibitem
          end

          def transform_referencegroup_to_bibitem(group_node)
            return nil unless group_node

            bibitem = Metanorma::Document::Components::BibData::BibliographicItem.new(
              id: group_node.anchor,
            )

            if group_node.target && !group_node.target.to_s.empty?
              link = Metanorma::Document::Relaton::TypedUri.new(
                type: "src",
                content: group_node.target,
              )
              bibitem.link = [link]
            end

            # Group members → docidentifier (as constituent references)
            to_array(group_node.reference).each do |ref|
              sub = transform_reference_to_bibitem(ref)
              next unless sub

              bibitem.relation = to_array(bibitem.relation)
              rel = Metanorma::Document::Relaton::DocumentRelation.new(
                type: "includes",
                bibitem: sub,
              )
              bibitem.relation << rel
            end

            bibitem
          end

          def populate_bibitem_from_front(bibitem, front)
            # Title
            if front.title
              title_text = extract_rfc_text(front.title)
              if title_text && !title_text.empty?
                title = Metanorma::Document::Relaton::TypedTitleString.new(
                  type: "main",
                  content: [title_text],
                )
                bibitem.title = [title]
              end
            end

            # Authors → contributors
            to_array(front.author).each do |author_node|
              contributor = build_bibitem_contributor(author_node)
              bibitem.contributor = to_array(bibitem.contributor)
              bibitem.contributor << contributor if contributor
            end

            # Date
            if front.date
              on = build_date_on(front.date)
              if on
                bibitem.date = [
                  Metanorma::Document::Relaton::BibliographicDate.new(
                    type: "published",
                    on: on,
                  ),
                ]
              end
            end

            # Abstract
            if front.abstract
              abs_text = extract_abstract_text(front.abstract)
              if abs_text && !abs_text.empty?
                bibitem.abstract = [
                  Metanorma::Document::Components::DataTypes::FormattedString.new(
                    content: [abs_text],
                  ),
                ]
              end
            end
          end

          def build_bibitem_contributor(author_node)
            role_type = author_node.role == "editor" ? "editor" : "author"
            role = Metanorma::Document::Relaton::ContributorRole.new(type: role_type)

            person = build_person(author_node)

            contributor = Metanorma::Document::Relaton::ContributionInfo.new(role: [role])
            if person
              contributor.person = person

              if author_node.organization
                org = build_mn_organization(author_node.organization)
                affiliation = Metanorma::Document::Relaton::Affiliation.new(organization: org)
                person.affiliation = [affiliation]
              end
            elsif author_node.organization
              contributor.organization = build_mn_organization(author_node.organization)
            end

            contributor
          end

          def build_docidentifier_from_series(si)
            return nil unless si.name || si.value

            type = si.name.to_s.empty? ? nil : si.name
            value = si.value.to_s.empty? ? nil : si.value

            return nil unless type && value

            Metanorma::Document::Relaton::DocumentIdentifier.new(
              id: value,
              type: type,
            )
          end

          def extract_refcontent_text(ref_node)
            contents = to_array(ref_node.refcontent)
            return nil if contents.empty?

            texts = contents.map { |rc| extract_rfc_text(rc) }.reject(&:empty?)
            texts.empty? ? nil : texts.join(" ")
          end

          def extract_abstract_text(abstract_node)
            paragraphs = to_array(abstract_node.t)
            return nil if paragraphs.empty?

            paragraphs.map { |t| extract_rfc_mixed_text(t) }.reject(&:empty?).join(" ")
          end
        end
      end
    end
  end
end
