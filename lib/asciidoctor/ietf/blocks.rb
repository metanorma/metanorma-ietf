module Asciidoctor
  module Ietf
    class Converter < ::Asciidoctor::Standoc::Converter
      def para_attrs(node)
        attr_code( keepWithNext: node.attr("keepWithNext"),
                  keepWithPrevious: node.attr("keepWithPrevious"),
                  id: ::Asciidoctor::Standoc::Utils::anchor_or_uuid(node))
      end

      def ul_attr(node)
        attr_code(id: ::Asciidoctor::Standoc::Utils::anchor_or_uuid(node),
                  nobullet: node.attr("nobullet"),
                  spacing: node.attr("spacing"))
      end

      def ol_attr(node)
        attr_code(id: ::Asciidoctor::Standoc::Utils::anchor_or_uuid(node),
                  type: node.attr("rfc_label") || olist_style(node.style),
                  group: node.attr("group"),
                  spacing: node.attr("spacing"),
                  start: node.attr("start"))
      end
    end
  end
end
