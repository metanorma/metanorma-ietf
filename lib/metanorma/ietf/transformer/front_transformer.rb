# frozen_string_literal: true

module Metanorma
  module Ietf
    module Transformer
      module FrontTransformer

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
          if ascii_title
            title.ascii = ascii_title
          else
            ascii = Sterile.transliterate(mt)
            title.ascii = ascii unless ascii == mt
          end
          title
        end

        def build_series_info
          infos = []
          if rfc?
            si = Rfcxml::V3::SeriesInfo.new
            si.name = "RFC"
            si.value = docnumber.to_s
            si.ascii_name = "RFC"
            # the released path passes the metadata stage through
            # (capitalised text; numeric stages stay as-is), defaulting
            # to Published (WS3, metadata_spec)
            stage = model_attr(bibdata, :status)
            stage_text = stage && ls_text(model_attr(stage, :stage) || stage)
            si.status = if stage_text && !stage_text.strip.empty?
                          stage_text.strip.capitalize
                        else
                          "Published"
                        end
            si.stream = extract_submission_type
            infos << si
          else
            si = Rfcxml::V3::SeriesInfo.new
            si.name = "Internet-Draft"
            si.value = extract_doc_name.to_s
            si.ascii_name = "Internet-Draft"
            si.stream = extract_submission_type
            # status = metadata stage, as on the RFC branch (the
            # released path uses the stage for both); intended-series
            # title only as fallback (WS3, metadata_spec)
            stage = model_attr(bibdata, :status)
            stage_text = stage && ls_text(model_attr(stage, :stage) || stage)
            if stage_text && !stage_text.strip.empty?
              si.status = stage_text.strip.capitalize
            else
              series_list = to_array(bibdata.series)
              series_list.each do |s|
                next unless s.type == "intended"
                title = ls_text(s.title)
                si.status = title&.capitalize || "Informational"
                break
              end
            end
            si.status ||= "Informational"
            infos << si
          end

          series_list = bibdata.series
          if series_list
            series_list = [series_list] unless series_list.is_a?(Array)
            series_list.each do |s|
              next unless s.type == "intended"
              si = Rfcxml::V3::SeriesInfo.new
              si.name = ""
              si.value = ""
              si.status = ls_text(s.title)
              infos << si
            end
          end

          infos
        end

        def build_authors
          authors = []
          author_idx = 0
          contributors = bibdata.contributor
          return authors unless contributors
          contributors = [contributors] unless contributors.is_a?(Array)
          contributors.each do |contrib|
            role_type = contrib.role.first&.type
            next unless %w[author editor].include?(role_type)

            person = contrib.person
            org = contrib.organization

            # WS2 A-2 (N5): the committee contributor — an organization
            # carrying a Workgroup subdivision — is the workgroup
            # carrier, not a front author; the released path skips it
            # (front.rb#author)
            next if org && workgroup_carrier?(org)

            if person
              authors << build_person_author(person, org, role_type, author_idx)
            elsif org
              authors << build_org_author(org, role_type)
            end
            author_idx += 1
          end
          authors
        end

        def workgroup_carrier?(org)
          return false unless org.respond_to?(:subdivision)

          to_array(org.subdivision).compact.any? do |sub|
            sub.respond_to?(:type) && sub.type.to_s.casecmp?("workgroup")
          end
        end

        def build_person_author(person, org_from_contrib, role, contrib_idx = 0)
          author = Rfcxml::V3::Author.new
          author.role = "editor" if role == "editor"

          populate_author_name(author, person.name) if person.name

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

        def build_address(person, _contrib_idx = 0)
          address = Rfcxml::V3::Address.new

          aff = to_array(person.affiliation)
          first_aff = aff.first
          if first_aff&.organization
            postal = build_postal(first_aff.organization)
            address.postal = postal if postal
          end

          # voice phone → <phone>; fax phones are DROPPED — RFC 7991
          # removed <facsimile> from the v3 vocabulary (the old spec
          # expectation carrying it was DEBUG-only output). WS3,
          # metadata_spec.
          phones = to_array(person.phone)
          voice = phones.find { |ph| !ph.respond_to?(:type) || ph.type.to_s != "fax" }
          if voice && voice.content && !voice.content.strip.empty?
            phone = Rfcxml::V3::Phone.new
            phone.content = voice.content.strip
            address.phone = phone
          end

          to_array(person.email).each do |email_text|
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

          # no empty <uri/> placeholder — the released path emits uri
          # only when present (WS3, metadata_spec)
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
            ascii_val = Sterile.transliterate(line.to_s.strip)
            pl.ascii = ascii_val unless ascii_val == line.to_s.strip
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
          dates = bibdata.date
          if dates
            dates = [dates] unless dates.is_a?(Array)
            dates.each do |d|
              next unless %w[published circulated].include?(d.type)
              raw = d.on
              if raw
                date_str = raw.is_a?(String) ? raw : extract_date_text(raw)
              end
              date_str ||= d.text if d.text
              break if date_str && !date_str.to_s.empty?
            end
          end

          if date_str && !date_str.empty?
            parse_date_into(date, date_str)
          else
            today = Date.today
            date.year = today.year.to_s
            date.month = month_name(today.month)
            date.day = today.day.to_s
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

        def extract_date_text(date_obj)
          return date_obj.to_s unless date_obj

          if date_obj.content && !date_obj.content.to_s.empty?
            date_obj.content.to_s
          elsif date_obj.text && !date_obj.text.to_s.empty?
            date_obj.text.to_s
          else
            date_obj.to_s
          end
        end

        def build_areas
          areas = []
          to_array(ietf_ext.area).compact.each do |text|
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
            to_array(eg.workgroup).compact.each do |wg_text|
              next if wg_text.nil? || wg_text.to_s.empty?
              wg = Rfcxml::V3::Workgroup.new
              wg.content = [wg_text.to_s]
              wgs << wg
            end
          end

          # Relaton 2.0: the workgroup arrives as an organization
          # subdivision of type "workgroup" on a contributor (the
          # committee contributor spells it "Workgroup" — match
          # case-insensitively, WS2 A-2)
          if wgs.empty? && bibdata.respond_to?(:contributor)
            to_array(bibdata.contributor).compact.each do |c|
              org = c.respond_to?(:organization) ? c.organization : nil
              next unless org && org.respond_to?(:subdivision)

              to_array(org.subdivision).compact.each do |sub|
                next unless sub.respond_to?(:type) &&
                  sub.type.to_s.casecmp?("workgroup")

                name = to_array(sub.name).compact
                  .map { |n| ls_text(n) }.compact
                  .reject(&:empty?).first
                next unless name

                wg = Rfcxml::V3::Workgroup.new
                wg.content = [name]
                wgs << wg
              end
            end
          end

          wgs
        end

        def build_keywords
          kws = []
          to_array(bibdata.keyword).compact.each do |k|
            text = ls_text(k)
            # Relaton 2.0: keyword text nests in keyword/vocab
            if (text.nil? || text.to_s.empty?) &&
                k.respond_to?(:vocab) && k.vocab
              text = ls_text(k.vocab)
            end
            next if text.nil? || text.to_s.empty?

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

          # cross-references flatten to text inside the abstract
          # (standalone metadata — see build_eref_xref); the flag
          # scopes that behaviour to this walk
          @abstract_flatten = true

          # RFC 7991 abstract content model is (dl|ol|t|ul)+ — carry
          # that legal subset in source order (WS3, lists_spec: the
          # paragraph-only walk dropped foreword lists). Illegal
          # content (tables, notes, sourcecode) has no representable
          # home here and is left out; see the qa-plan model-gap and
          # table_spec notes.
          src_order = abstract_node.respond_to?(:element_order) ? abstract_node.element_order : nil
          carriers = {
            "p" => [:paragraphs, method(:transform_paragraph), :t],
            "ul" => [:unordered_lists, method(:transform_unordered_list), :ul],
            "ol" => [:ordered_lists, method(:transform_ordered_list), :ol],
            "dl" => [:definition_lists, method(:transform_definition_list), :dl],
          }
          if src_order && src_order.any? { |e| !e.text? && carriers.key?(e.element_tag) }
            counters = Hash.new(0)
            example_counter = 0
            src_order.each do |e|
              next if e.text?
              if e.element_tag == "example"
                exs = to_array(model_attr(abstract_node, :examples) ||
                               model_attr(abstract_node, :example))
                append_abstract_example(abstract, exs[example_counter])
                example_counter += 1
                next
              end
              spec = carriers[e.element_tag] or next
              accessor, xform, target = spec
              idx = counters[e.element_tag]
              counters[e.element_tag] += 1
              next unless abstract_node.respond_to?(accessor)
              node = to_array(abstract_node.public_send(accessor))[idx] or next
              built = xform.call(node)
              safe_append(abstract, target, built) if built
              # a dl-attached note cannot become an <aside> here
              # (abstract admits (dl|ol|t|ul)+ only); render it as an
              # unnumbered NOTE paragraph after the list
              next unless e.element_tag == "dl"

              dl_notes = to_array(node.respond_to?(:notes) ? node.notes : nil)
              if dl_notes.empty? && node.respond_to?(:note)
                dl_notes = to_array(node.note)
              end
              dl_notes.each do |nt|
                aside = transform_note(nt, nil)
                next unless aside
                to_array(aside.t).each { |t| safe_append(abstract, :t, t) }
              end
            end
          else
            get_paragraphs(abstract_node).each do |p|
              t = transform_paragraph(p)
              safe_append(abstract, :t, t) if t
            end
          end

          abstract
        ensure
          @abstract_flatten = false
        end

        # an example in the abstract renders as a keepWithNext EXAMPLE
        # label paragraph followed by its content paragraphs (the
        # blocks_spec label pattern; asides are not admitted in the
        # abstract)
        def append_abstract_example(abstract, example)
          return unless example

          label = Rfcxml::V3::Text.new
          label.keep_with_next = "true"
          label.content = ["EXAMPLE"]
          safe_append(abstract, :t, label)
          get_paragraphs(example).each do |p|
            t = transform_paragraph(p)
            safe_append(abstract, :t, t) if t
          end
        end

        def build_front_notes
          notes = []
          preface = doc.preface
          return notes unless preface

          # Collect notes from abstract/foreword (vintages carry them
          # on the singular :note — prefer whichever is populated)
          container = preface.abstract || preface.foreword
          if container
            container_notes = to_array(container.respond_to?(:notes) ? container.notes : nil)
            if container_notes.empty? && container.respond_to?(:note)
              container_notes = to_array(container.note)
            end
            container_notes.each do |note_node|
              note = build_front_note(note_node)
              notes << note if note
            end
          end

          # Collect notes from preface content sections (e.g. reverse transformer puts them there)
          to_array(preface.content).each do |clause_node|
            to_array(clause_node.notes).each do |note_node|
              note = build_front_note_from_clause(clause_node, note_node)
              notes << note if note
            end
          end

          notes
        end

        def build_front_note(note_node)
          note = Rfcxml::V3::Note.new
          note.remove_in_rfc = note_node.remove_in_rfc.to_s unless note_node.remove_in_rfc.nil?

          names = to_array(note_node.name)
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
          note
        end

        def build_front_note_from_clause(clause_node, note_node)
          note = Rfcxml::V3::Note.new
          note.remove_in_rfc = note_node.remove_in_rfc.to_s unless note_node.remove_in_rfc.nil?

          title_node = clause_node.title
          if title_node
            title_text = ls_text(title_node)
            if title_text && !title_text.to_s.strip.empty?
              name = Rfcxml::V3::Name.new
              name.content = [title_text.to_s.strip]
              note.name = name
            end
          end

          get_paragraphs(note_node).each do |p|
            t = transform_paragraph(p)
            safe_append(note, :t, t) if t
          end
          note
        end
      end
    end
  end
end
