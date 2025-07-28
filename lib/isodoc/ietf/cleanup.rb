require_relative "cleanup_inline"
require_relative "cleanup_blocks"

module IsoDoc
  module Ietf
    class RfcConvert < ::IsoDoc::Convert
      def cleanup(docxml)
        image_cleanup(docxml)
        figure_cleanup(docxml)
        table_cleanup(docxml)
        footnote_cleanup(docxml)
        sourcecode_cleanup(docxml)
        li_cleanup(docxml)
        deflist_cleanup(docxml)
        cref_cleanup(docxml) # feeds bookmark
        bookmark_cleanup(docxml)
        front_cleanup(docxml)
        u_cleanup(docxml)
        biblio_cleanup(docxml) # feeds aside
        abstract_cleanup(docxml) # bleeds aside
        aside_cleanup(docxml)
        docxml
      end

      def abstract_cleanup(docxml)
        docxml.xpath("//abstract").each do |a|
          a.xpath(".//eref | .//xref").each do |node|
            crossref_remove_markup_elem(node)
          end
          a.xpath(".//aside | ./title | .//table")
            .each(&:remove)
        end
      end

      def biblio_cleanup(xmldoc)
        biblio_referencegroup_cleanup(xmldoc)
        biblio_abstract_cleanup(xmldoc)
        biblio_date_cleanup(xmldoc)
        biblio_refcontent_cleanup(xmldoc)
        biblio_format_cleanup(xmldoc)
        annotation_cleanup(xmldoc)
      end

      def biblio_referencegroup_cleanup(xmldoc)
        xmldoc.xpath("//reference[ref-included]").each do |r|
          r.name = "referencegroup"
          r.elements.each do |e|
            if e.name == "ref-included"
              e.name = "reference"
              e["anchor"] ||= "_#{UUIDTools::UUID.random_create}"
            else e.remove
            end
          end
        end
      end

      def biblio_date_cleanup(xmldoc)
        xmldoc.xpath("//date[@cleanme]").each do |a|
          a.delete("cleanme")
          d = @c.decode(a.text).gsub(/–/, "-").sub(/-\d\d\d\d.*$/, "")
          if attrs = date_attr(d)
            attrs.each { |k, v| a[k] = v }
            a.children.remove
          else a.remove end
        end
      end

      def biblio_abstract_cleanup(xmldoc)
        xmldoc.xpath("//abstract[@cleanme]").each do |a|
          a.delete("cleanme")
          ret = reparse_abstract(a)
          a.children = if a.at("./p") then ret
                       else "<t>#{ret}</t>"
                       end
        end
      end

      def biblio_refcontent_cleanup(xmldoc)
        xmldoc.xpath("//refcontent").each do |a|
          val = a.text.strip
          if val.empty? then a.remove
          else a.children = val
          end
        end
      end

      def biblio_format_cleanup(xmldoc)
        xmldoc.xpath("//reference[format]").each do |r|
          r.xpath("./format").each(&:remove)
        end
      end

      def reparse_abstract(abstract)
        a1 = Nokogiri::XML(abstract.dup.to_xml
          .sub("<abstract>", "<abstract xmlns='http://www.example.com'>")).root
        noko do |xml|
          a1.children.each { |n| parse(n, xml) }
        end.join
      end

      def front_cleanup(xmldoc)
        xmldoc.xpath("//title").each { |s| s.children = s.text }
        xmldoc.xpath("//reference/front[not(author)]").each do |f|
          insert = f.at("./seriesInfo[last()]") || f.at("./title")
          insert.next = "<author surname='Unknown'/>"
        end
      end
    end
  end
end
