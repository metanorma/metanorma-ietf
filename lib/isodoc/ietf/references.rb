module IsoDoc
  module Ietf
    class RfcConvert < ::IsoDoc::Convert
      # TODO displayreference will be implemented as combination of autofetch and user-provided citations

      def bibliography(isoxml, out)
        isoxml.xpath(ns("//references/bibitem/docidentifier")).each do |i|
          i.children = docid_prefix(i["type"], i.text)
        end
        isoxml.xpath(ns("//bibliography/references | "\
                        "//bibliography/clause[.//references] | "\
                        "//annex/clause[.//references] | "\
                        "//annex/references | "\
                        "//sections/clause[.//references]")).each do |f|
          bibliography1(f, out)
        end
      end

      def bibliography1(node, out)
        out.references **attr_code(anchor: node["id"]) do |div|
          title = node.at(ns("./title")) and div.name do |name|
            title.children.each { |n| parse(n, name) }
          end
          node.elements.select do |e|
            %w(references clause).include? e.name
          end.each { |e| bibliography1(e, out) }
          node.elements.reject do |e|
            %w(references title bibitem note).include? e.name
          end.each { |e| parse(e, div) }
          biblio_list(node, div, true)
        end
      end

      def biblio_list(node, div, biblio)
        i = 0
        node.xpath(ns("./bibitem | ./note")).each do |b|
          next if implicit_reference(b)

          i += 1 if b.name == "bibitem"
          if b.name == "note" then note_parse(b, div)
          elsif ietf?(b) then ietf_bibitem_entry(div, b, i)
          else
            nonstd_bibitem(div, b, i, biblio)
          end
        end
      end

      def nonstd_bibitem(list, bib, _ordinal, _bibliography)
        uris = bib.xpath(ns("./uri"))
        target = nil
        uris&.each { |u| target = u.text if u["type"] == "src" }
        list.reference **attr_code(target: target,
                                   anchor: bib["id"]) do |r|
          nonstd_bibitem_front(r, bib)
          uris&.each do |u|
            r.format nil, **attr_code(target: u.text, type: u["type"])
          end
          docidentifier_render(bib, r)
        end
      end

      def docidentifier_render(bib, out)
        docidentifiers = bib.xpath(ns("./docidentifier"))
        id = render_identifier(bibitem_ref_code(bib))
        !id[:sdo].nil? && id[:sdo] != "(NO ID)" and out.refcontent id[:sdo]
        docidentifiers&.each do |u|
          u["type"] == "DOI" and
            out.seriesInfo nil, **attr_code(value: u.text.sub(/^DOI /, ""),
                                            name: "DOI")
          %w(IETF RFC).include?(u["type"]) and docidentifier_ietf(u, out)
        end
      end

      def docidentifier_ietf(ident, out)
        if /^RFC /.match?(ident.text)
          out.seriesInfo nil, **attr_code(value: ident.text.sub(/^RFC 0*/, ""),
                                          name: "RFC")
        elsif /^I-D\./.match?(ident.text)
          out.seriesInfo nil, **attr_code(value: ident.text.sub(/^I-D\./, ""),
                                          name: "Internet-Draft")
        end
      end

      def nonstd_bibitem_front(ref, bib)
        ref.front do |f|
          relaton_to_title(bib, f)
          relaton_to_author(bib, f)
          relaton_to_date(bib, f)
          relaton_to_keyword(bib, f)
          relaton_to_abstract(bib, f)
        end
      end

      def relaton_to_title(bib, node)
        title = bib&.at(ns("./title")) || bib&.at(ns("./formattedref")) or
          return
        node.title do |t|
          title.children.each { |n| parse(n, t) }
        end
      end

      def relaton_to_author(bib, node)
        auths = bib.xpath(ns("./contributor[xmlns:role/@type = 'author' or "\
                             "xmlns:role/@type = 'editor']"))
        auths.empty? and
          auths = bib.xpath(ns("./contributor[xmlns:role/@type = "\
                               "'publisher']"))
        auths.each do |a|
          role = a.at(ns("./role[@type = 'editor']")) ? "editor" : nil
          p = a&.at(ns("./person/name")) and
            relaton_person_to_author(p, role, node) or
            relaton_org_to_author(a&.at(ns("./organization")), role, node)
        end
      end

      def relaton_person_to_author(pers, role, node)
        full = pers&.at(ns("./completename"))&.text
        surname = pers&.at(ns("./surname"))&.text
        initials = pers&.xpath(ns("./initial"))&.map do |i|
                     i.text
                   end&.join(" ") ||
          pers&.xpath(ns("./forename"))&.map { |i| i.text[0] }&.join(" ")
        initials = nil if initials.empty?
        node.author nil, **attr_code(
          fullname: full,
          asciiFullname: full&.transliterate,
          role: role, surname: surname,
          initials: initials,
          asciiSurname: full ? surname&.transliterate : nil,
          asciiInitials: full ? initials&.transliterate : nil
        )
      end

      def relaton_org_to_author(org, _role, node)
        name = org&.at(ns("./name"))&.text
        abbrev = org&.at(ns("./abbreviation"))&.text
        node.author do |_a|
          node.organization name, **attr_code(ascii: name&.transliterate,
                                              abbrev: abbrev)
        end
      end

      def relaton_to_date(bib, node)
        date = bib.at(ns("./date[@type = 'published']")) ||
          bib.at(ns("./date[@type = 'issued']")) ||
          bib.at(ns("./date[@type = 'circulated']"))
        return unless date

        attr = date_attr(date&.at(ns("./on | ./from"))&.text) || return
        node.date **attr_code(attr)
      end

      def relaton_to_keyword(bib, node)
        bib.xpath(ns("./keyword")).each do |k|
          node.keyword do |keyword|
            k.children.each { |n| parse(n, keyword) }
          end
        end
      end

      def relaton_to_abstract(bib, node)
        bib.xpath(ns("./abstract")).each do |k|
          node.abstract do |abstract|
            if k.at(ns("./p"))
              k.children.each { |n| parse(n, abstract) }
            else
              abstract.t do |t|
                k.children.each { |n| parse(n, t) }
              end
            end
          end
        end
      end

      def ietf_bibitem_entry(div, bib, _idx)
        url = bib&.at(ns("./uri[@type = 'xml']"))&.text
        div << "<xi:include href='#{url}'/>"
      end

      def ietf?(bib)
        return false if !@xinclude

        url = bib.at(ns("./uri[@type = 'xml']")) or return false
        /xml2rfc\.tools\.ietf\.org/.match(url)
      end
    end
  end
end
