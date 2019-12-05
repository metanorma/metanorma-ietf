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

    def note_label(node)
      l10n("#{super}: ")
    end

    def note_parse(node, out)
      first = node.first_element_child
      out.t **attr_code(anchor: node["id"] || first["id"]) do |p|
        p << note_label(node)
        first.name == "p" and first.children.each { |n| parse(n, p) }
      end
      first.name == "p" and
        node.elements.drop(1).each { |n| parse(n, out) } or
        node.elements.each { |n| parse(n, out) }
    end

    def example_parse(node, out)
      example_label(node, out, node.at(ns("./name")))
      node.elements.each { |n| parse(n, out) unless n.name == "name" }
    end

    def example_label(node, div, name)
      n = get_anchors[node["id"]]
      div.t **attr_code(anchor: node["id"], keepWithNext: "true") do |p|
        lbl = (n.nil? || n[:label].nil? || n[:label].empty?) ? @example_lbl :
          l10n("#{@example_lbl} #{n[:label]}")
        p << lbl
        name and !lbl.nil? and p << ": "
        name and name.children.each { |n| parse(n, p) }
      end
    end

    # TODO no src attribute
    def sourcecode_parse(node, out)
      out.figure **attr_code(anchor: node["id"]) do |div|
        name = node&.at(ns("./name"))&.remove and div.name do |n| 
          name.children.each { |nn| parse(nn, n) }
        end
        div.container do |c|
          node.children.each { |x| parse(x, c) }
        end
        text = div.parent.at("./container").remove.children.to_s
        div.sourcecode **attr_code(type: node["lang"], name: node["filename"]) do |s|
          s.cdata text.sub(/^\n/, "")
        end
      end
    end

    def annotation_parse(node, out)
      @sourcecode = false
      @annotation = true
      node.at("./preceding-sibling::*[local-name() = 'annotation']") or
        out << "\n\n"
      callout = node.at(ns("//callout[@target='#{node['id']}']"))
      out << "\n&lt;#{callout.text}&gt; "
      out << node&.children&.text&.strip
      @annotation = false
    end

    def formula_where(dl, out)
      return unless dl
      out.t { |p| p << @where_lbl }
      parse(dl, out)
    end

    def formula_parse1(node, out)
      out.t **attr_code(id: node["id"]) do |p|
        parse(node.at(ns("./stem")), p)
        lbl = anchor(node['id'], :label, false)
        unless lbl.nil?
          p << "   (#{lbl})"
        end
      end
    end
  end
end
