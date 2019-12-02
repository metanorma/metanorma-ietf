module IsoDoc::Ietf
  class RfcConvert < ::IsoDoc::Convert
    def make_table_attr(node)
      attr_code(anchor: node["id"])
    end

    def table_parse(node, out)
      @in_table = true
      out.table **make_table_attr(node) do |t|
        table_title_parse(node, out)
        thead_parse(node, t)
        tbody_parse(node, t)
        tfoot_parse(node, t)
      end
      (dl = node.at(ns("./dl"))) && parse(dl, out)
      node.xpath(ns("./note")).each { |n| parse(n, out) }
      @in_table = false
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

    def make_tr_attr(td, row, totalrows, header)
      attr_code(rowspan: td["rowspan"], colspan: td["colspan"],
                align: td["align"] )
    end
  end
end
