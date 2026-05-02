# frozen_string_literal: true

module Metanorma
  module Ietf
    module Transformer
      module FrontTransformer
        private

        def build_front
          front = Rfcxml::V3::Front.new
          front.title = build_title
          front.series_info = build_series_info
          front.author = build_authors
          front.date = build_date
          front.area = build_areas
          front.workgroup = build_workgroups
          front.keyword = build_keywords
          front.abstract = build_abstract
          front.note = build_front_notes
          front
        end

        def build_title
          title = Rfcxml::V3::Title.new
          mt = main_title
          title.content = [mt]
          title.abbrev = abbrev_title if abbrev_title
          ascii = Sterile.transliterate(mt)
          title.ascii = ascii unless ascii == mt
          title
        end

        def build_series_info
          infos = []
          if rfc?
            si = Rfcxml::V3::SeriesInfo.new
            si.name = "RFC"
            si.value = docnumber.to_s
            si.ascii_name = "RFC"
            si.status = "Published"
            si.stream = extract_submission_type
            infos << si
          else
            si = Rfcxml::V3::SeriesInfo.new
            si.name = "Internet-Draft"
            si.value = extract_doc_name.to_s
            si.ascii_name = "Internet-Draft"
            si.stream = extract_submission_type
            bibdata.series.each do |s|
              next unless s.type == "intended"
              title = ls_text(s.title)
              si.status = title&.capitalize || "Informational"
              break
            end
            si.status ||= "Informational"
            infos << si
          end

          bibdata.series.each do |s|
            next unless s.type == "intended"
            si = Rfcxml::V3::SeriesInfo.new
            si.name = ""
            si.value = ""
            si.status = ls_text(s.title)
            infos << si
          end

          infos
        end

        def build_authors
          authors = []
          author_idx = 0
          bibdata.contributor.each do |contrib|
            role_type = contrib.role.first&.type
            next unless %w[author editor].include?(role_type)

            person = contrib.person
            org = contrib.organization

            if person
              authors << build_person_author(person, org, role_type, author_idx)
            elsif org
              authors << build_org_author(org, role_type)
            end
            author_idx += 1
          end
          authors
        end

        def build_person_author(person, org_from_contrib, role, contrib_idx = 0)
          author = Rfcxml::V3::Author.new
          author.role = "editor" if role == "editor"

          name = person.name
          if name
            surname = ls_text(name.surname)
            complete = ls_text(name.complete_name)

            if surname
              author.surname = surname
              ascii_surname = Sterile.transliterate(surname)
              author.ascii_surname = ascii_surname unless ascii_surname == surname

              forenames = name.forename
              if forenames.is_a?(Array) && !forenames.empty?
                parts = forenames.map { |f| ls_text(f).to_s.strip }.reject(&:empty?)
                if parts.any?
                  author.initials = parts.map { |p| "#{p.chars.first}." }.join(" ")
                  first_name = parts.first
                  author.fullname = "#{first_name} #{surname}"
                  author.ascii_fullname = "#{Sterile.transliterate(first_name)} #{ascii_surname}"
                end
              end
            elsif complete
              author.fullname = complete
              ascii = Sterile.transliterate(complete)
              author.ascii_fullname = ascii unless ascii == complete
            end
          end

          aff_org = person.affiliation&.first&.organization || org_from_contrib
          author.organization = build_organization(aff_org) if aff_org
          author.address = build_address(person, contrib_idx)

          author
        end

        def build_org_author(org_node, _role)
          author = Rfcxml::V3::Author.new
          author.organization = build_organization(org_node)
          author
        end

        def build_organization(org_node)
          org = Rfcxml::V3::Organization.new
          name_text = org_node.name.is_a?(Array) ? ls_text(org_node.name.first) : ls_text(org_node.name)
          org.content = [name_text] if name_text

          abbrev = org_node.abbreviation
          if abbrev
            abbrev_text = abbrev.is_a?(Array) ? ls_text(abbrev.first) : ls_text(abbrev)
            org.abbrev = abbrev_text if abbrev_text
          end

          org.ascii = Sterile.transliterate(name_text) if name_text && Sterile.transliterate(name_text) != name_text
          org
        end

        def build_address(person, _contrib_idx = 0)
          address = Rfcxml::V3::Address.new

          aff = person.affiliation
          aff = [aff] unless aff.is_a?(Array)
          first_aff = aff.first
          if first_aff&.organization
            postal = build_postal(first_aff.organization)
            address.postal = postal if postal
          end

          phones = person.phone
          phones = [phones] unless phones.is_a?(Array)
          if phones.any?
            phone_obj = phones.first
            phone_text = phone_obj.content
            if phone_text && !phone_text.strip.empty?
              phone = Rfcxml::V3::Phone.new
              phone.content = phone_text.strip
              address.phone = phone
            end
          end

          emails = person.email
          emails = [emails] unless emails.is_a?(Array)
          emails.each do |email_text|
            text = email_text.to_s.strip
            next if text.empty?
            email = Rfcxml::V3::Email.new
            email.content = text
            safe_append(address, :email, email)
          end

          if person.uri
            uri_text = person.uri.content
            if uri_text && !uri_text.strip.empty?
              uri = Rfcxml::V3::Uri.new
              uri.content = uri_text.strip
              address.uri = uri
            end
          end

          address.uri = Rfcxml::V3::Uri.new unless address.uri

          address
        end

        def build_postal(org)
          addrs = org.address
          return nil unless addrs

          addr = addrs.is_a?(Array) ? addrs.first : addrs
          return nil unless addr

          formatted = addr.formatted_address
          if formatted
            lines = formatted.content
            if lines && !lines.empty?
              postal = build_postal_from_lines(lines)
              return postal if postal
            end
          end

          build_postal_from_structured(addr)
        end

        def build_postal_from_lines(lines)
          postal = Rfcxml::V3::Postal.new
          found = false
          lines.each do |line|
            next if line.to_s.strip.empty?
            pl = Rfcxml::V3::PostalLine.new
            pl.content = [line.to_s.strip]
            pl.ascii = Sterile.transliterate(line.to_s.strip)
            safe_append(postal, :postal_line, pl)
            found = true
          end
          found ? postal : nil
        end

        def build_postal_from_structured(addr)
          postal = Rfcxml::V3::Postal.new
          found = false

          streets = addr.street
          if streets.is_a?(Array) && !streets.empty?
            streets.each do |s|
              next if s.to_s.strip.empty?
              st = Rfcxml::V3::Street.new
              st.content = [s.to_s.strip]
              safe_append(postal, :street, st)
              found = true
            end
          end

          if addr.city && !addr.city.to_s.strip.empty?
            city = Rfcxml::V3::City.new
            city.content = [addr.city.to_s.strip]
            safe_append(postal, :city, city)
            found = true
          end

          if addr.state && !addr.state.to_s.strip.empty?
            region = Rfcxml::V3::Region.new
            region.content = [addr.state.to_s.strip]
            safe_append(postal, :region, region)
            found = true
          end

          if addr.postcode && !addr.postcode.to_s.strip.empty?
            code = Rfcxml::V3::Code.new
            code.content = [addr.postcode.to_s.strip]
            safe_append(postal, :code, code)
            found = true
          end

          if addr.country && !addr.country.to_s.strip.empty?
            country = Rfcxml::V3::Country.new
            country.content = [addr.country.to_s.strip]
            safe_append(postal, :country, country)
            found = true
          end

          found ? postal : nil
        end

        def build_date
          date = Rfcxml::V3::Date.new

          date_str = nil
          bibdata.date.each do |d|
            next unless %w[published circulated].include?(d.type)
            raw = d.on || d.text
            date_str = raw.to_s if raw
            break
          end

          if date_str && !date_str.empty?
            parse_date_into(date, date_str)
          else
            date.year = "2000"
            date.month = "January"
            date.day = "1"
          end

          date
        end

        def parse_date_into(date, date_str)
          case date_str
          when /^\d{4}$/
            date.year = date_str
          when /^(\d{4})-(\d{2})$/
            date.year = $1
            date.month = month_name($2.to_i)
          when /^(\d{4})-(\d{2})-(\d{2})$/
            date.year = $1
            date.month = month_name($2.to_i)
            date.day = $3.to_i.to_s
          else
            date.year = date_str[0, 4] if date_str.length >= 4
          end
        end

        def month_name(month_num)
          %w[January February March April May June July August September October November December][month_num - 1]
        end

        def build_areas
          areas = []
          area_list = ietf_ext.area
          area_list = [area_list] unless area_list.is_a?(Array)
          area_list.compact.each do |text|
            next if text.to_s.empty?
            area = Rfcxml::V3::Area.new
            area.content = [text.to_s]
            areas << area
          end
          areas
        end

        def build_workgroups
          wgs = []

          eg = ietf_ext.editorial_group
          if eg
            eg_wgs = eg.workgroup
            eg_wgs = [eg_wgs] unless eg_wgs.is_a?(Array)
            eg_wgs.compact.each do |wg_text|
              next if wg_text.nil? || wg_text.to_s.empty?
              wg = Rfcxml::V3::Workgroup.new
              wg.content = [wg_text.to_s]
              wgs << wg
            end
          end

          wgs
        end

        def build_keywords
          kws = []
          kw_list = bibdata.keyword
          kw_list = [kw_list] unless kw_list.is_a?(Array)
          kw_list.compact.each do |k|
            text = ls_text(k)
            next unless text
            kw = Rfcxml::V3::Keyword.new
            kw.content = [text]
            kws << kw
          end
          kws
        end

        def build_abstract
          preface = doc.preface
          return nil unless preface

          abstract_node = preface.abstract || preface.foreword
          return nil unless abstract_node

          abstract = Rfcxml::V3::Abstract.new
          abstract.anchor = to_ncname(abstract_node.id) if abstract_node.id

          get_paragraphs(abstract_node).each do |p|
            t = transform_paragraph(p)
            safe_append(abstract, :t, t) if t
          end

          abstract
        end

        def build_front_notes
          notes = []
          preface = doc.preface
          return notes unless preface

          container = preface.abstract || preface.foreword
          return notes unless container

          note_list = container.notes
          note_list.each do |note_node|
            note = Rfcxml::V3::Note.new
            if note_node.remove_in_rfc
              note.remove_in_rfc = note_node.remove_in_rfc
            end

            names = note_node.name
            names = [names] unless names.is_a?(Array)
            first_name = names.first
            if first_name
              name_text = ls_text(first_name)
              if name_text && !name_text.to_s.strip.empty?
                name = Rfcxml::V3::Name.new
                name.content = [name_text.to_s.strip]
                note.name = name
              end
            end

            get_paragraphs(note_node).each do |p|
              t = transform_paragraph(p)
              safe_append(note, :t, t) if t
            end
            notes << note
          end

          notes
        end
      end
    end
  end
end
