require_relative "../../relaton/render/general"

module IsoDoc
  module Ietf
    class RfcConvert < ::IsoDoc::Convert
      def bibliography(docxml, out)
        bibliography_prep(docxml)
        docxml.xpath(ns("//bibliography/references | " \
                        "//bibliography/clause[.//references] | " \
                        "//annex/clause[.//references] | " \
                        "//annex/references | " \
                        "//sections/clause[.//references]")).each do |f|
          bibliography1(f, out)
        end
      end

      def bibliography_prep(docxml)
        docxml.xpath(ns("//references/bibitem/docidentifier")).each do |i|
          i.children = docid_prefix(i["type"], i.text)
        end
        @bibrenderer =
          ::Relaton::Render::Ietf::General.new(language: @lang,
                                               i18nhash: @i18n.get)
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

      def biblio_list(node, div, _biblio)
        i = 0
        node.xpath(ns("./bibitem | ./note")).each do |b|
          next if implicit_reference(b)

          i += 1 if b.name == "bibitem"
          if b.name == "note" then note_parse(b, div)
          else
            ietf_bibitem(div, b, i)
          end
        end
      end

      def ietf_bibitem(list, bib, _ordinal)
        uris = bib.xpath(ns("./uri"))
        target = nil
        uris&.each { |u| target = u.text if %w(src HTML).include?(u["type"]) }
        list.reference **attr_code(target: target,
                                   anchor: bib["id"]) do |r|
                                     bibitem_render(r, bib)
                                   end
      end

      def bibitem_render(ref, bib)
        bib1 = bib.clone
        @isodoc.prep_for_rendering(bib1)
        bib1.namespace = nil
        ret = @bibrenderer.render(bib1.to_xml, embedded: true)
        ref << if bib1.at(ns("./formattedref")) && !bib1.at(ns("./title"))
                 "<front><title>#{ret}</title></front>"
               else
                 ret
               end
      end
    end
  end
end
