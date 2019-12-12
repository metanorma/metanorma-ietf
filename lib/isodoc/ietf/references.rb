module IsoDoc::Ietf
  class RfcConvert < ::IsoDoc::Convert
    # TODO displayreference will be implemented as combination of autofetch and user-provided citations

    def bibliography(isoxml, out)
      require "byebug"; byebug
      isoxml.xpath(ns("//references")) do |f|
        out.references **attr_code(anchor: f["id"]) do |div|
          name = f.at(ns("./title")) and div.name do |name|
            name.children.each { |n| parse(n, name) }
          end
          f.elements.reject do |e|
            %w(reference title bibitem note).include? e.name
          end.each { |e| parse(e, div) }
          biblio_list(f, div, true)
        end
      end
    end

    def biblio_list(f, div, biblio)
      i = 0
      f.xpath(ns("./bibitem | ./note")).each do |b|
        next if implicit_reference(b)
        i += 1 if b.name == "bibitem"
        if b.name == "note" then annotation_parse(b, div)
        elsif(is_ietf(b)) then ietf_bibitem_entry(div, b, i)
        else
          nonstd_bibitem(div, b, i, biblio)
        end
      end
    end

    def nonstd_bibitem(list, b, ordinal, bibliography)
      list.reference **attr_code(anchor: b["id"],
                                 target: b&.at(ns("./uri"))&.text) do |r|
        r.front do |f|
          relaton_to_title(b, f)
          relaton_to_author(b, f)
          relaton_to_date(b, f)
          relaton_to_keyword(b, f)
          relaton_to_abstract(b, f)
        end
      end
    end

    def relaton_to_title(b, f)
      id = bibitem_ref_code(b)
      identifier = render_identifier(id)
      title = b&.at(ns("./title")) or return
      f.title do |t|
        title << "#{identifier}, "
        title.children.each { |n| parse (n, t) }
      end
    end

    def relaton_to_author(b, f)
      b.xpath(ns("./contributor[xmlns:role/@type = 'author'] or "\
                 "./contributor[xmlns:role/@type = 'editor']")).each do |a|
        role = a.at(ns("./role[@type = 'editor']")) ? "editor" : nil
       p = a&.at(ns("./person/name")) and 
         relaton_person_to_author(p, role, f) or
         relaton_org_to_author(a&.at(ns("./organization")), role, f)
      end
    end

    def relaton_person_to_author(p, role, f)
      fullname = p&.at(ns("./completename"))&.text
      surname = p&.at(ns("./surname"))&.text
      initials = p&.xpath(ns("./initial"))&.map { |i| i.text }&.join(" ") ||
        p&.xpath(ns("./forename"))&.map { |i| i.text[0] }&.join(" ")
      f.author nil,
        **attr_code(fullname: fullname, asciiFullname: fullname.transliterate,
                    role: role, surname: surname,
                    asciiSurname: fullname ? surname.transliterate : nil,
                    initials: initials,
                    asciiInitials: fullname ? initials.transliterate : nil)
    end

    def relaton_org_to_author(o, role, f)
      name = o&.at(ns("./name"))&.text
      abbrev = o&.at(ns("./abbreviation"))&.text
      f.author do |a|
        f.organization name, **attr_code(asciiName: name.transliterate, 
                                         abbrev: abbrev)
      end
    end

    def relaton_to_date(b, f)
      date = b.xpath(ns("./date[@type = 'published'")) ||
        b.xpath(ns("./date[@type = 'issued'")) ||
        b.xpath(ns("./date[@type = 'circulated'"))
      return unless date
      attr = date_attr(data.text) || return
      f.date **attr_code(attr)
    end

    def relaton_to_keyword(b, f)
      b.xpath(ns("./keyword")).each do |k|
        f.keyword do |keyword|
          k.children.each { |n| parse (n, keyword) }
        end
      end
    end

    def relaton_to_keyword(b, f)
      b.xpath(ns("./abstract")).each do |k|
        f.abstract do |abstract|
          k.children.each { |n| parse (n, abstract) }
        end
      end
    end

    def ietf_bibitem_entry(div, b, i)
      url = b.at(ns("./uri[@type = 'xml']"))
      div << "<xi:include href='#{url}'/>"
    end

    def is_ietf(b)
      url = b.at(ns("./uri[@type = 'xml']")) || return false
      /xml2rfc\.tools\.ietf\.org/.match(url)
    end
  end
end
