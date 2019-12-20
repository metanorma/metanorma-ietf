require "mathml2asciimath"

module IsoDoc::Ietf
  class RfcConvert < ::IsoDoc::Convert
    def em_parse(node, out)
      out.em do |e|
        node.children.each { |n| parse(n, e) }
      end
    end

    def sup_parse(node, out)
      out.sup do |e|
        node.children.each { |n| parse(n, e) }
      end
    end

    def sub_parse(node, out)
      out.sub do |e|
        node.children.each { |n| parse(n, e) }
      end
    end

    def tt_parse(node, out)
      out.tt do |e|
        node.children.each { |n| parse(n, e) }
      end
    end

    def strong_parse(node, out)
      out.strong do |e|
        node.children.each { |n| parse(n, e) }
      end
    end

    def bcp14_parse(node, out)
      out.bcp14 do |e|
        node.children.each { |n| parse(n, e) }
      end
    end

    def strike_parse(node, out)
      node.children.each { |n| parse(n, out) }
    end

    def smallcap_parse(node, out)
      node.children.each { |n| parse(n, out) }
    end

    def keyword_parse(node, out)
      node.children.each { |n| parse(n, out) }
    end

    def text_parse(node, out)
      return if node.nil? || node.text.nil?
      text = node.to_s
      out << text
    end

    def stem_parse(node, out)
      stem = case node["type"]
             when "MathML" then MathML2AsciiMath.m2a(node.children.to_xml)
             else
               HTMLEntities.new.encode(node.text)
             end
      out << "#{@openmathdelim} #{stem} #{@closemathdelim}"
    end

    def page_break(_out)
    end

    def br_parse(node, out)
      if @sourcecode
        out.br
      end
    end

    def hr_parse(node, out)
    end

    def link_parse(node, out)
      out.eref **attr_code(target: node["target"]) do |l|
        node.children.each { |n| parse(n, l) }
      end
    end

    def image_parse(node, out, caption)
      attrs = { src: node["src"],
                title: node["title"],
                align: node["align"],
                name: node["filename"],
                anchor: node["id"],
                type: "svg",
                alt: node["alt"]  }
      out.artwork **attr_code(attrs)
      image_title_parse(out, caption)
    end

     def image_title_parse(out, caption)
      unless caption.nil?
        out.t **{ align: "center", keepWithPrevious: "true" } do |p|
          p << caption.to_s
        end
      end
    end

     def xref_parse(node, out)
       out.xref **attr_code(target: node["target"], format: "default",
                            format: node["format"],
                            relative: node["relative"]) do |l|
                              l << get_linkend(node)
                            end
     end

     def eref_parse(node, out)
       linkend = node.children.select { |c| c.name != "locality" }
       section = eref_clause(node.xpath(ns("./locality")), nil) || ""
       out.relref **attr_code(target: node["bibitemid"], section: section,
                             displayFormat: node["displayFormat"]) do |l|
         linkend.each { |n| parse(n, l) }
       end
     end

     def eref_clause(refs, target)
       refs.each do |l|
         next unless %w(clause section).include? l["type"]
         return l&.at(ns("./referenceFrom"))&.text
       end
       return nil
     end

     def index_parse(node, out)
       out.iref nil, **attr_code(item: node["primary"],
                                 subitem: node["secondary"])
     end
  end
end
