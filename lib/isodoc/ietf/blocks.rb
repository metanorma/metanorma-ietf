module IsoDoc::Ietf
  class RfcConvert < ::IsoDoc::Convert
    def para_attrs(node)
      { keepWithNext: node["keepWithNext"],
        keepWithPrevious: node["keepWithPrevious"],
        anchor: node["id"] }
    end

    def para_parse(node, out)
      out.t **attr_code(para_attrs(node)) do |p|
        node.children.each { |n| parse(n, p) }
      end
    end

    def ul_attrs(node)
      { id: node["id"] }
    end

    def ul_parse(node, out)
      out.ul **ul_attrs(node) do |ul|
        node.children.each { |n| parse(n, ul) }
      end
    end
  end
end
