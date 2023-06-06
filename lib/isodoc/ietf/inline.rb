require "mathml2asciimath"

module IsoDoc
  module Ietf
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
               else HTMLEntities.new.encode(node.text)
               end
        out << "#{@openmathdelim} #{stem} #{@closemathdelim}"
      end

      def page_break(_out); end

      def pagebreak_parse(_node, _out); end

      def br_parse(_node, out)
        out.br
      end

      def hr_parse(node, out); end

      def link_parse(node, out)
        out.eref **attr_code(target: node["target"]) do |l|
          node.children.each { |n| parse(n, l) }
        end
      end

      def image_parse(node, out, caption)
        attrs = { src: node["src"], title: node["title"],
                  align: node["align"], name: node["filename"],
                  anchor: node["id"], type: "svg",
                  alt: node["alt"] }
        out.artwork **attr_code(attrs)
        image_title_parse(out, caption)
      end

      def image_title_parse(out, caption)
        unless caption.nil?
          out.t align: "center", keepWithPrevious: "true" do |p|
            p << caption.to_s
          end
        end
      end

      def svg_parse(node, out)
        if node.parent.name == "image" then super
        else
          attrs = { src: node["src"], title: node["title"],
                  align: node["align"], name: node["filename"],
                  anchor: node["id"], type: "svg",
                  alt: node["alt"] }
        out.artwork **attr_code(attrs) do |x|
          out = x
          super
        end
        end
      end

      def xref_parse(node, out)
        out.xref **attr_code(target: node["target"], format: node["format"],
                             relative: node["relative"]) do |l|
                               l << get_linkend(node)
                             end
      end

      def get_linkend(node)
        no_loc_contents = node.children.reject do |c|
          %w{locality localityStack location}.include? c.name
        end
        contents = no_loc_contents.select { |c| !c.text? || /\S/.match(c) }
        !contents.empty? and
          return to_xml(Nokogiri::XML::NodeSet.new(node.document, contents))
        ""
      end

      def eref_parse(node, out)
        linkend = node.children.reject do |c|
          %w{locality localityStack}.include? c.name
        end
        # section = "" unless relative.empty?
        out.relref **attr_code(target: node["bibitemid"],
                               section: eref_section(node),
                               relative: eref_relative(node),
                               displayFormat: node["displayFormat"]) do |l|
                                 linkend.each { |n| parse(n, l) }
                               end
      end

      def eref_relative(node)
        node["relative"] ||
          node.at(ns(".//locality[@type = 'anchor']/referenceFrom"))&.text || ""
      end

      def eref_section(node)
        @isodoc.eref_localities(
          node.xpath(ns("./locality | ./localityStack")), nil, node
        )&.sub(/^,/, "")&.sub(/^\s*(Sections?|Clauses?)/, "")&.strip
          &.sub(/,$/, "") || ""
      end

      def origin_parse(node, out)
        if t = node.at(ns("./termref"))
          termrefelem_parse(t, out)
        else
          eref_parse(node, out)
        end
      end

      def index_parse(node, out)
        out.iref nil, **attr_code(item: node.at(ns("./primary")).text,
                                  primary: node["primary"],
                                  subitem: node&.at(ns("./secondary"))&.text)
      end

      def bookmark_parse(node, out)
        out.bookmark nil, **attr_code(anchor: node["id"])
      end
    end
  end
end
