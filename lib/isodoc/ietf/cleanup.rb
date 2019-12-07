module IsoDoc::Ietf
  class RfcConvert < ::IsoDoc::Convert
    def cleanup(docxml)
      figure_cleanup(docxml)
      table_cleanup(docxml)
      footnote_cleanup(docxml)
      docxml
    end

    def table_footnote_cleanup(docxml)
      docxml.xpath("//table[descendant::fn]").each do |t|
        t.xpath(".//fn").each do |a|
          t << a.remove.children
        end
      end
    end

    def figure_footnote_cleanup(docxml)
      docxml.xpath("//figure[descendant::fn]").each do |t|
        t.xpath(".//fn").each do |a|
          t << a.remove.children
        end
      end
    end

    def table_cleanup(docxml)
      table_footnote_cleanup(docxml)
    end

    def figure_cleanup(docxml)
      figure_footnote_cleanup(docxml)
      figure_postamble(docxml)
    end

    def figure_postamble(docxml)
      docxml.xpath("//figure").each do |f|
        name = f&.at("./name")&.remove
        a = f&.at("./artwork | ./sourcework")
        b = a&.xpath("./preceding-sibling::*")&.remove
        c = a&.xpath("./following-sibling::*")&.remove
        a = a.remove
        name and f << name
        b.empty? or f << "<preamble>#{b.to_xml}</preamble>"
        a and f << a
        c.empty? or f << "<postamble>#{c.to_xml}</postamble>"
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
      endnotes = docxml.at("//back") or
      docxml << "<back/>" and endnotes = docxml.at("//back")
      endnotes << "<section><name>Endnotes</name></section>"
      endnotes = docxml.at("//back/section[last()]")
    end
  end
end
