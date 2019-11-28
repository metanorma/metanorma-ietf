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
      { anchor: node["id"],
        empty: node["nobullet"],
        spacing: node["spacing"] }
    end

    def ul_parse(node, out)
      out.ul **attr_code(ul_attrs(node)) do |ul|
        node.children.each { |n| parse(n, ul) }
      end
    end

    OL_STYLE = {
      arabic: "1",
      roman: "i",
      alphabet: "a",
      roman_upper: "I",
      alphabet_upper: "A",
    }.freeze

    def ol_style(type)
      OL_STYLE[type.to_sym] || type
    end

    def ol_attrs(node)
      { anchor: node["id"], 
        spacing: node["spacing"],
        type: ol_style(node["type"]),
        group: node["group"],
        start: node["start"] }
    end

    def ol_parse(node, out)
      out.ol **attr_code(ol_attrs(node)) do |ol|
        node.children.each { |n| parse(n, ol) }
      end
    end

    def dl_attr(node)
      attr_code(anchor: node["id"],
                hanging: node["hanging"],
                spacing: node["spacing"])
    end
  end
end
