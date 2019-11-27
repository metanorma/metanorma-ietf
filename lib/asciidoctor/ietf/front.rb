module Asciidoctor
  module Ietf
    class Converter < ::Asciidoctor::Standoc::Converter
      def relaton_relations
        %w(included-in described-by derived-from equivalent obsoletes updates)
      end

      def metadata_author(node, xml)
        personal_author(node, xml)
      end

      def metadata_series(node, xml)
        xml.series **{ type: "stream" } do |s|
          s.title (node.attr("submission-type") || "IETF")
        end
      end

      def metadata_ext(node, xml)
        x = node.attr("ipr") and xml.ipr x
        x = node.attr("index-include") and xml.indexInclude x
        x = node.attr("ipr-extract") and xml.iprExtract x
        x = node.attr("sort-refs") and xml.sortRefs x
        x = node.attr("sym-refs") and xml.symRefs x
        x = node.attr("toc-include") and xml.tocInclude x
        x = node.attr("toc-depth") and xml.tocDepth x
        x = node.attr("toc-depth") and xml.tocDepth x
      end
    end
  end
end
