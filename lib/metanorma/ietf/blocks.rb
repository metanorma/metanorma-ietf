module Metanorma
  module Ietf
    class Converter < ::Metanorma::Standoc::Converter
      def para_attrs(node)
        attr_code("keep-with-next": node.attr("keepWithNext") ||
                  node.attr("keep-with-next"),
                  "keep-with-previous": node.attr("keepWithPrevious") ||
                 node.attr("keep-with-previous"),
                  indent: node.attr("indent"),
                  id: ::Metanorma::Utils::anchor_or_uuid(node))
      end

      def ul_attrs(node)
        attr_code(id: ::Metanorma::Utils::anchor_or_uuid(node),
                  nobullet: node.attr("nobullet") || node.attr("empty"),
                  indent: node.attr("indent"),
                  bare: node.attr("bare"),
                  spacing: node.attr("spacing"))
      end

      def ol_attrs(node)
        attr_code(id: ::Metanorma::Utils::anchor_or_uuid(node),
                  type: node.attr("format") || olist_style(node.style),
                  group: node.attr("group"),
                  spacing: node.attr("spacing"),
                  indent: node.attr("indent"),
                  start: node.attr("start"))
      end

      def dl_attrs(node)
        attr_code(id: ::Metanorma::Utils::anchor_or_uuid(node),
                  newline: node.attr("newline"),
                  indent: node.attr("indent"),
                  spacing: node.attr("spacing"))
      end

      def todo_attrs(node)
        super.merge(attr_code(display: node.attr("display")))
      end

      def sidebar(node)
        return unless draft?

        noko do |xml|
          xml.review **sidebar_attrs(node) do |r|
            node.title.nil? or r.name { |name| name << node.title }
            wrap_in_para(node, r)
          end
        end
      end

      def note(node)
        noko do |xml|
          xml.note **attr_code(id: ::Metanorma::Utils::anchor_or_uuid(nil),
                               removeInRFC: node.attr("remove-in-rfc")) do |c|
            node.title.nil? or c.name { |name| name << node.title }
            wrap_in_para(node, c)
          end
        end
      end

      def literal(node)
        noko do |xml|
          xml.figure **literal_attrs(node) do |f|
            figure_title(node, f)
            f.pre node.lines.join("\n"),
                  **attr_code(align: node.attr("align"),
                              id: ::Metanorma::Utils::anchor_or_uuid(nil),
                              alt: node.attr("alt"))
          end
        end
      end

      def image_attributes(node)
        super.merge(attr_code(align: node.attr("align")))
      end

      def listing_attrs(node)
        super.merge(attr_code(markers: node.attr("markers"),
                              src: node.attr("src")))
      end
    end
  end
end
