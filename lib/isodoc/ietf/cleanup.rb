module IsoDoc::Ietf
  class RfcConvert < ::IsoDoc::Convert
    def cleanup(docxml)
      image_cleanup(docxml)
      figure_cleanup(docxml)
      table_cleanup(docxml)
      footnote_cleanup(docxml)
      sourcecode_cleanup(docxml)
      annotation_cleanup(docxml)
      deflist_cleanup(docxml)
      bookmark_cleanup(docxml)
      aside_cleanup(docxml)
      front_cleanup(docxml)
      docxml
    end

    # TODO: insert <u>

    def front_cleanup(xmldoc)
      xmldoc.xpath("//title").each { |s| s.children = s.text }
      xmldoc.xpath("//reference/front[not(author)]").each do |f|
        insert = f.at("./seriesInfo[last()]") || f.at("./title")
        insert.next = "<author surname='Unknown'/>"
      end
    end

    def table_footnote_cleanup(docxml)
      docxml.xpath("//table[descendant::fn]").each do |t|
        t.xpath(".//fn").each do |a|
          t << "<aside>#{a.remove.children}</aside>"
        end
      end
    end

    def figure_footnote_cleanup(docxml)
      docxml.xpath("//figure[descendant::fn]").each do |t|
        t.xpath(".//fn").each do |a|
          t << "<aside>#{a.remove.children}</aside>"
        end
      end
    end

    def table_cleanup(docxml)
      table_footnote_cleanup(docxml)
    end

    def figure_cleanup(docxml)
      figure_postamble(docxml)
      figure_unnest(docxml)
      figure_footnote_cleanup(docxml)
      figure_data_uri(docxml)
    end

    def figure_data_uri(docxml)
      docxml.xpath("//artwork").each do |a|
        next unless %r{^data:image/svg\+xml;base64}.match?(a["src"])

        f = Metanorma::Utils::save_dataimage(a["src"])
        a.delete("src")
        a.children = File.read(f).sub(%r{<\?.+\?>}, "")
      end
    end

    def figure_unnest(docxml)
      docxml.xpath("//figure[descendant::figure]").each do |f|
        insert = f
        f.xpath(".//figure").each do |a|
          title = f.at("./name") and a.children.first.previous = title.remove
          insert.next = a.remove
          insert = insert.next_element
        end
        f.remove
      end
    end

    def figure_postamble(docxml)
      make_postamble(docxml)
      move_postamble(docxml)
      move_preamble(docxml)
    end

    def make_postamble(docxml)
      docxml.xpath("//figure").each do |f|
        a = f&.at("./artwork | ./sourcecode") || next
        name = f&.at("./name")&.remove
        b = a&.xpath("./preceding-sibling::*")&.remove
        c = a&.xpath("./following-sibling::*")&.remove
        a = a.remove
        name and f << name
        b.empty? or f << "<preamble>#{b.to_xml}</preamble>"
        a and f << a
        c.empty? or f << "<postamble>#{c.to_xml}</postamble>"
      end
    end

    def move_postamble(docxml)
      docxml.xpath("//postamble").each do |p|
        insert = p.parent
        p.remove.elements.each do |e|
          insert.next = e
          insert = insert.next_element
        end
      end
    end

    def move_preamble(docxml)
      docxml.xpath("//preamble").each do |p|
        insert = p.parent
        p.remove.elements.each do |e|
          insert.previous = e
        end
      end
    end

    def footnote_cleanup(docxml)
      fn = footnote_refs_cleanup(docxml)
      endnotes = make_endnotes(docxml)
      docxml.xpath("//section[descendant::fn] | "\
                   "//abstract[descendant::fn]").each do |s|
        s.xpath(".//fn").each do |f|
          ref = f.at(".//ref") and ref.replace("[#{fn[ref.text]}] ")
          endnotes << f.remove.children
        end
      end
    end

    def footnote_refs_cleanup(docxml)
      i = 0
      fn = {}
      docxml.xpath("//fnref").each do |f|
        unless fn[f.text]
          i = i + 1
          fn[f.text] = i.to_s
        end
        f.replace(" [#{fn[f.text]}]")
      end
      fn
    end

    def make_endnotes(docxml)
      return unless docxml.at("//fn")

      unless endnotes = docxml.at("//back")
        docxml << "<back/>" and endnotes = docxml.at("//back")
      end
      endnotes << "<section><name>Endnotes</name></section>"
      docxml.at("//back/section[last()]")
    end

    def image_cleanup(docxml)
      docxml.xpath("//t[descendant::artwork]").each do |t|
        insert = t
        t.xpath(".//artwork").each_with_index do |a, i|
          insert.next = a.dup
          insert = insert.next
          a.replace("[IMAGE #{i + 1}]")
        end
      end
    end

    # for markup in pseudocode
    def sourcecode_cleanup(docxml)
      docxml.xpath("//sourcecode").each do |s|
        s.children = s.children.to_xml.gsub(%r{<br/>\n}, "\n")
          .gsub(%r{\s+(<t[ >])}, "\\1").gsub(%r{</t>\s+}, "</t>")
        sourcecode_remove_markup(s)
        s.children = "<![CDATA[#{HTMLEntities.new.decode(s
        .children.to_xml.sub(/\A\n+/, ''))}]]>"
      end
    end

    def sourcecode_remove_markup(node)
      node.traverse do |n|
        next if n.text?
        next if %w(name callout annotation note sourcecode).include? n.name

        case n.name
        when "br" then n.replace("\n")
        when "t" then n.replace("\n\n#{n.children}")
        else
          n.replace(n.children)
        end
      end
    end

    def annotation_cleanup(docxml)
      docxml.xpath("//reference").each do |r|
        next unless r&.next_element&.name == "aside"

        aside = r.next_element
        aside.name = "annotation"
        aside.traverse do |n|
          n.name == "t" and n.replace(n.children)
        end
        r << aside
      end
      docxml.xpath("//references/aside").each(&:remove)
    end

    def deflist_cleanup(docxml)
      dt_cleanup(docxml)
      dd_cleanup(docxml)
    end

    def dt_cleanup(docxml)
      docxml.xpath("//dt").each do |d|
        d&.first_element_child&.name == "bookmark" and
          d["anchor"] ||= d.first_element_child["anchor"]
        d.xpath(".//t").each do |t|
          d["anchor"] ||= t["anchor"]
          t.replace(t.children)
        end
      end
    end

    def dd_cleanup(docxml)
      docxml.xpath("//dd").each do |d|
        d&.first_element_child&.name == "bookmark" and
          d["anchor"] ||= d.first_element_child["anchor"]
      end
    end

    def bookmark_cleanup(docxml)
      docxml.xpath("//bookmark").each(&:remove)
    end

    def aside_cleanup(docxml)
      docxml.xpath("//t[descendant::aside] | //table[descendant::aside] | "\
                   "//figure[descendant::aside]").each do |p|
        insert = p
        p.xpath(".//aside").each do |a|
          insert.next = a.remove
          insert = insert.next_element
        end
      end
    end
  end
end
