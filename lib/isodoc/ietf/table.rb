module IsoDoc
  module Ietf
    class RfcConvert < ::IsoDoc::Convert
      def table_attrs(node)
        attr_code(anchor: node["id"], align: node["align"])
      end

      def table_parse(node, out)
        @in_table = true
        out.table **table_attrs(node) do |t|
          table_title_parse(node, t)
          thead_parse(node, t)
          tbody_parse(node, t)
          tfoot_parse(node, t)
        end
        table_parse_tail(node, out)
        @in_table = false
      end

      def table_parse_tail(node, out)
        (dl = node.at(ns("./dl"))) && parse(dl, out)
        node.xpath(ns("./source")).each { |n| parse(n, out) }
        node.xpath(ns("./note")).each { |n| parse(n, out) }
      end

      def table_title_parse(node, out)
        name = node.at(ns("./name")) || return
        out.name do |p|
          name.children.each { |n| parse(n, p) }
        end
      end

      def tr_parse(node, out, ord, totalrows, header)
        out.tr do |r|
          node.elements.each do |td|
            attrs = make_tr_attr(td, ord, totalrows - 1, header)
            r.send td.name, **attrs do |entry|
              td.children.each { |n| parse(n, entry) }
            end
          end
        end
      end

      def make_tr_attr(cell, _row, _totalrows, _header)
        attr_code(rowspan: cell["rowspan"], colspan: cell["colspan"],
                  align: cell["align"])
      end
    end
  end
end
