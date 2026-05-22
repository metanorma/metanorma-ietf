# frozen_string_literal: true

module Metanorma
  module Ietf
    module Transformer
      module RfcV3ToIetf
        # Transforms RFC XML v3 <front> content into Metanorma bibdata
        # contributors and preface sections.
        module FrontTransformer

          def transform_abstract(abstract_node)
            return nil unless abstract_node

            section = Metanorma::IetfDocument::Sections::IetfContentSection.new(
              id: "_abstract",
            )

            to_array(abstract_node.t).each do |t_node|
              p = transform_t(t_node)
              OrderTracker.append_ordered(section, :paragraphs, p) if p
            end

            to_array(abstract_node.dl).each do |dl_node|
              dl = transform_dl(dl_node)
              OrderTracker.append_ordered(section, :definition_lists, dl) if dl
            end

            section
          end

          def transform_front_note(note_node)
            return nil unless note_node

            clause = Metanorma::IetfDocument::Sections::IetfContentSection.new(
              id: resolve_id(note_node),
            )

            title = extract_node_title(note_node)
            clause.title = build_title_element(title) if title && !title.empty?

            note = Metanorma::Document::Components::Blocks::NoteBlock.new
            to_array(note_node.t).each do |t_node|
              p = transform_t(t_node)
              note.content = to_array(note.content)
              note.content << p if p
            end

            clause.notes = [note] unless note.content.nil? || (note.content.is_a?(Array) && note.content.empty?)

            clause
          end

          def build_contributors_from_front(front)
            contributors = []
            return contributors unless front

            to_array(front.author).each do |author_node|
              contributor = build_author_contributor(author_node)
              contributors << contributor if contributor
            end

            contributors
          end

          def build_author_contributor(author_node)
            role_type = author_node.role == "editor" ? "editor" : "author"
            role = Metanorma::Document::Relaton::ContributorRole.new(type: role_type)

            person = build_person(author_node)
            org = nil

            if author_node.organization
              org = build_mn_organization(author_node.organization)
            end

            # Add postal address
            if author_node.address && author_node.address.postal
              postal_lines = to_array(author_node.address.postal.postal_line)
              formatted = postal_lines.map { |pl| extract_rfc_text(pl) }.select { |t| !t.empty? }
              if formatted.any?
                org ||= Metanorma::Document::Relaton::Organization.new
                fa = build_formatted_address(formatted)
                addr = Metanorma::Document::Relaton::Address.new(
                  formatted_address: fa,
                )
                org.address = [addr]
              end
            end

            contributor = Metanorma::Document::Relaton::ContributionInfo.new(role: [role])
            contributor.person = person if person

            if person && org
              affiliation = Metanorma::Document::Relaton::Affiliation.new(organization: org)
              person.affiliation = [affiliation]
            elsif org && !person
              contributor.organization = org
            end

            contributor
          end

          def build_person(author_node)
            fullname = author_node.fullname
            surname = author_node.surname
            initials = author_node.initials

            return nil if !fullname && !surname

            person = Metanorma::Document::Relaton::Person.new
            name = Metanorma::Document::Relaton::FullName.new

            if fullname && !fullname.to_s.empty?
              name.complete_name = build_localized_string(fullname)
            end
            if surname && !surname.to_s.empty?
              name.surname = build_localized_string(surname)
            end
            if initials && !initials.to_s.empty?
              name.initials = [build_localized_string(initials)]
            end

            person.name = name

            # Add contact info from address
            if author_node.address
              address = author_node.address
              if address.email
                to_array(address.email).each do |email_node|
                  text = extract_rfc_text(email_node)
                  person.email = to_array(person.email)
                  person.email << text if text && !text.empty?
                end
              end

              if address.uri
                text = extract_rfc_text(address.uri)
                if text && !text.empty?
                  person.uri = Metanorma::Document::Relaton::TypedUri.new(content: text)
                end
              end
            end

            person
          end

          def build_formatted_address(lines)
            return nil if lines.empty?

            Metanorma::Document::Relaton::FormattedAddress.from_lines(lines)
          end
        end
      end
    end
  end
end
