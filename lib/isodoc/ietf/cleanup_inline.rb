module IsoDoc
  module Ietf
    class RfcConvert < ::IsoDoc::Convert
      def u_cleanup(xmldoc)
        xmldoc.traverse do |n|
          next unless n.text?
          next unless %w(t blockquote li dd preamble td th annotation)
            .include? n.parent.name

          n.replace(n.text.gsub(/[\u0080-\uffff]/, "<u>\\0</u>"))
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

      def bookmark_cleanup(docxml)
        docxml.xpath("//bookmark").each(&:remove)
      end

      def cref_cleanup(docxml)
        docxml.xpath("//cref").each do |c|
          c.xpath("./t").each do |t|
            t.replace(t.children)
          end
          next unless %w(section abstract).include? c.parent.name

          c.wrap("<t></t>")
        end
      end
    end
  end
end
