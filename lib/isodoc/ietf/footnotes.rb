module IsoDoc::Ietf
  class RfcConvert < ::IsoDoc::Convert
    def footnote_parse(node, out)
      return table_footnote_parse(node, out) if @in_table || @in_figure
      fn = node["reference"]
      out.fnref fn
      make_local_footnote(node, fn, out)
    end

    def make_local_footnote(node, fn, out)
      return if @seen_footnote.include?(fn)
      @in_footnote = true
      out << make_generic_footnote_text(node, fn)
      @in_footnote = false
      @seen_footnote << fn
    end

    def make_generic_footnote_text(node, fnref)
      first = node.first_element_child
      noko do |xml|
        xml.fn do |div|
          xml.t **attr_code(anchor: first ? first["id"] : nil) do |div|
            div.ref fnref
            first.name == "p" and first.children.each { |n| parse(n, div) }
          end
          first.name == "p" and
            node.elements.drop(1).each { |n| parse(n, xml) } or
            node.children.each { |n| parse(n, xml) }
        end
      end.join("\n")
    end

    def table_footnote_parse(node, out)
      fn = node["reference"]
      tid = get_table_ancestor_id(node)
      make_table_footnote_link(out, tid + fn, fn)
      # do not output footnote text if we have already seen it for this table
      return if @seen_footnote.include?(tid + fn)
      @in_footnote = true
      out.fn do |a|
        a << make_table_footnote_text(node, tid + fn, fn)
      end
      @in_footnote = false
      @seen_footnote << (tid + fn)
    end

    def make_table_footnote_link(out, fnid, fnref)
      out << " [#{fnref}]"
    end

    def make_table_footnote_text(node, fnid, fnref)
      first = node.first_element_child
      noko do |xml|
        xml.t **attr_code(anchor: first ? first["id"] : nil) do |div|
          div << "[#{fnref}]  "
          first.name == "p" and first.children.each { |n| parse(n, div) }
        end
        first.name == "p" and
          node.elements.drop(1).each { |n| parse(n, xml) } or
          node.children.each { |n| parse(n, xml) }
      end.join("\n")
    end

    def get_table_ancestor_id(node)
      table = node.ancestors("table") || node.ancestors("figure")
      return UUIDTools::UUID.random_create.to_s if table.empty?
      table.last["id"]
    end
  end
end
