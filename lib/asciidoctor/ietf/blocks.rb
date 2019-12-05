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

      def dl_attr(node)
        attr_code(id: ::Asciidoctor::Standoc::Utils::anchor_or_uuid(node),
                  hanging: node.attr("hanging"),
                  spacing: node.attr("spacing"))
      end

      def todo_attrs(node)
        super.merge(attr_code(display: node.attr("display")))
      end

      def note(n)
        noko do |xml|
          xml.note **attr_code(id: ::Asciidoctor::Standoc::Utils::anchor_or_uuid(n),
                               removeInRFC: n.attr("removeInRFC")) do |c|
            n.title.nil? or c.name { |name| name << n.title }
            wrap_in_para(n, c)
          end
        end.join("\n")
      end
    end
  end
end
