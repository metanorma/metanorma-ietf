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
      out.bpc14 do |e|
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
  end
end
