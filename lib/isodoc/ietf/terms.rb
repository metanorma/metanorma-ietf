module IsoDoc
  module Ietf
    class RfcConvert < ::IsoDoc::Convert
      def definition_parse(node, out)
        node.children.each { |n| parse(n, out) }
      end

      def modification_parse(node, out)
        para = node.at(ns("./p"))
        out << " -- "
        para.children.each { |n| parse(n, out) }
      end

      def deprecated_term_parse(node, out)
        name = node.at(ns(".//name"))
        out.t do |p|
          p << l10n("#{@i18n.deprecated}: ")
          name.children.each { |c| parse(c, p) }
        end
      end

      def admitted_term_parse(node, out)
        name = node.at(ns(".//name"))
        out.t do |p|
          name.children.each { |c| parse(c, p) }
        end
      end

      def term_parse(node, out)
        name = node.at(ns(".//name"))
        out.name do |p|
          name.children.each { |n| parse(n, p) }
        end
      end

      def termnote_parse(node, out)
        note_parse(node, out)
      end

      def termref_parse(node, out)
        out.t do |p|
          p << "SOURCE: "
          node.children.each { |n| parse(n, p) }
        end
      end

      def termdef_parse(node, out)
        set_termdomain("")
        node.xpath(ns("./definition")).size > 1 and
          IsoDoc::PresentationXMLConvert.new({}).multidef(node)
        clause_parse(node, out)
      end

      def termdocsource_parse(_node, _out); end

      def concept_parse(node, out)
        if d = node.at(ns("./renderterm"))
          out.em do |em|
            d.children.each { |n| parse(n, em) }
          end
          out << " "
        end
        out << "[term defined in "
        r = node.at(ns("./xref | ./eref | ./termref"))
        parse(r, out)
        out << "]"
      end
    end
  end
end
