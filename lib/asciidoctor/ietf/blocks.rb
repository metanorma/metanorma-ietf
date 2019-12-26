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
                  type: node.attr("format") || olist_style(node.style),
                  group: node.attr("group"),
                  spacing: node.attr("spacing"),
                  start: node.attr("start"))
      end

      def dl_attr(node)
        attr_code(id: ::Asciidoctor::Standoc::Utils::anchor_or_uuid(node),
                  newline: node.attr("newline"),
                  indent: node.attr("indent"),
                  spacing: node.attr("spacing"))
      end

      def todo_attrs(node)
        super.merge(attr_code(display: node.attr("display")))
      end

      def note(n)
        noko do |xml|
          xml.note **attr_code(id: ::Asciidoctor::Standoc::Utils::anchor_or_uuid(n),
                               removeInRFC: n.attr("remove-in-rfc")) do |c|
            n.title.nil? or c.name { |name| name << n.title }
            wrap_in_para(n, c)
          end
        end.join("\n")
      end

      def literal(node)
        noko do |xml|
          xml.figure **literal_attrs(node) do |f|
            figure_title(node, f)
            f.pre node.lines.join("\n"),
              **attr_code(align: node.attr("align"),
                          id: ::Asciidoctor::Standoc::Utils::anchor_or_uuid(nil),
                          alt: node.attr("alt"))
          end
        end
      end

      def image_attributes(node)
        super.merge(attr_code(align: node.attr("align")))
      end

       def listing_attrs(node)
         super.merge(attr_code(markers: node.attr("markers")))
       end
    end
  end
end
