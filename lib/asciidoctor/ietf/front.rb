module Asciidoctor
  module Ietf
    class Converter < ::Asciidoctor::Standoc::Converter
      def relaton_relations
        %w(included-in described-by derived-from equivalent obsoletes updates)
      end

      def metadata_author(node, xml)
        personal_author(node, xml)
      end

      def metadata_publisher(node, xml)
        publishers = node.attr("publisher") || "IETF"
        publishers.split(/,[ ]?/).each do |p|
          xml.contributor do |c|
            c.role **{ type: "publisher" }
            c.organization { |a| organization(a, p) }
          end
        end
      end

      def metadata_copyright(node, xml)
        publishers = node.attr("publisher") || "IETF"
        publishers.split(/,[ ]?/).each do |p|
          xml.copyright do |c|
            c.from (node.attr("copyright-year") || Date.today.year)
            c.owner do |owner|
              owner.organization { |o| organization(o, p) }
            end
          end
        end
      end

      def organization(org, orgname)
        if ["IETF",
            "Internet Engineering Task Force"].include? orgname
          org.name "Internet Engineering Task Force"
          org.abbreviation "IETF"
        else
          org.name orgname
        end
      end

      def metadata_series(node, xml)
        xml.series **{ type: "stream" } do |s|
          s.title (node.attr("submission-type") || "IETF")
        end
        a = node.attr("intended-series") and
          xml.series **{ type: "intended" } do |s|
          parts = a.split(/ /)
          s.title parts[0]
          s.number parts[1..-1].join(" ") if parts.size > 1
          end
      end

      def title(node, xml)
        ["en"].each do |lang|
          at = { language: lang, format: "text/plain" }
          xml.title **attr_code(at.merge(type: "main")) do |t|
            t << ::Asciidoctor::Standoc::Utils::asciidoc_sub(
              node.attr("title") || node.attr("title-en") || node.title)
          end
          a = node.attr("abbrev") and
            xml.title a, **attr_code(at.merge(type: "abbrev"))
          a = node.attr("asciititle") and
            xml.title a, **attr_code(at.merge(type: "ascii"))
        end
      end

      def metadata_committee(node, xml)
        return unless node.attr("workgroup")
        xml.editorialgroup do |a|
          committee_component("workgroup", node, a)
        end
      end

      def metadata_ext(node, xml)
        super
        x = node.attr("area") and x.split(/,\s*/).each do |a|
          xml.area a
        end
        x = node.attr("ipr") and xml.ipr x
        x = node.attr("consensus") and xml.consensus x
        x = node.attr("index-include") and xml.indexInclude x
        x = node.attr("ipr-extract") and xml.iprExtract x
        x = node.attr("sort-refs") and xml.sortRefs x
        x = node.attr("sym-refs") and xml.symRefs x
        x = node.attr("toc-include") and xml.tocInclude x
        x = node.attr("toc-depth") and xml.tocDepth x
      end
    end
  end
end
