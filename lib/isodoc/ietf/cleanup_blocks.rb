module IsoDoc
  module Ietf
    class RfcConvert < ::IsoDoc::Convert
      def li_cleanup(xmldoc)
        xmldoc.xpath("//li[t]").each do |li|
          li.elements.size == 1 or next
          li.children = li.elements[0].children
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
          %r{^data:image/svg\+xml;base64}.match?(a["src"]) or next
          f = Vectory::Utils::save_dataimage(a["src"])
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
          a = f.at("./artwork | ./sourcecode") || next
          name = f.at("./name")&.remove
          b = a.xpath("./preceding-sibling::*")&.remove
          c = a.xpath("./following-sibling::*")&.remove
          a = a.remove
          name and f << name
          b.empty? or f << "<preamble>#{to_xml(b)}</preamble>"
          a and f << a
          c.empty? or f << "<postamble>#{to_xml(c)}</postamble>"
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

      # for markup in pseudocode
      def sourcecode_cleanup(docxml)
        docxml.xpath("//sourcecode").each do |s|
          s.children = to_xml(s.children).gsub(%r{<br/>\n}, "\n")
            .gsub(%r{\s+(<t[ >])}, "\\1").gsub(%r{</t>\s+}, "</t>")
          sourcecode_remove_markup(s)
          s.children = "<![CDATA[#{@c.decode(to_xml(s.children)
            .sub(/\A\n+/, ''))}]]>"
        end
      end

      def sourcecode_remove_markup(node)
        node.traverse do |n|
          n.text? and next
          %w(name callout annotation note sourcecode).include? n.name and next
          case n.name
          when "br" then n.replace("\n")
          when "t" then n.replace("\n\n#{n.children}")
          when "eref" then n.replace(n.children.empty? ? n["target"] : n.children)
          when "xref"
            if n.children.empty?
              sourcecode_xref(n)
            else
              n.replace(n.children)
            end
          #when "relref" then n.replace(n.children.empty? ? n["target"] : n.children)
          else n.replace(n.children)
          end
        end
      end

      def sourcecode_xref(node)
        id = node.document.at("//*[@id = '#{node["target"]}']")
              ret = case node.name
                    when "bibitem"
                     d = id.at("./docidentifier[@primary = 'true']")
                     d ||= id.at("./docidentifier")
                     d.text
                    end
              s = node["section"] and ret += ", Section #{s}"
              ret
      end

      def annotation_cleanup(docxml)
        docxml.xpath("//reference").each do |r|
          while r.next_element&.name == "aside"
            annotation_cleanup1(r)
          end
        end
        docxml.xpath("//references/aside").each(&:remove)
      end

      def annotation_cleanup1(ref)
        aside = ref.next_element
        aside.name = "annotation"
        aside.traverse do |n|
          n.name == "t" and n.replace(n.children)
        end
        ref << aside
      end

      def deflist_cleanup(docxml)
        dt_cleanup(docxml)
        dd_cleanup(docxml)
      end

      def dt_cleanup(docxml)
        docxml.xpath("//dt").each do |d|
          d.first_element_child&.name == "bookmark" and
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

      def aside_cleanup(docxml)
        docxml.xpath("//*[aside]").each do |p|
          %w(section).include?(p.name) and next
          insert = p
          p.xpath("./aside").each do |a|
            insert.next = a.remove
            insert = insert.next_element
          end
        end
      end
    end
  end
end
