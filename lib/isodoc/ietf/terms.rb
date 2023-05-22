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

      def termdef_parse(node, out)
        set_termdomain("")
        node.xpath(ns("./definition")).size > 1 and
          @isodoc.multidef(node)
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

      def termsource_status(status)
        case status
        when "modified" then @i18n.modified
        when "adapted" then @i18n.adapted
        end
      end

      def termsource_add_modification_text(mod)
        mod or return
        mod.text.strip.empty? or mod.previous = " &#x2013; "
        mod.elements.size == 1 and
          mod.elements[0].replace(mod.elements[0].children)
        mod.replace(mod.children)
      end

      def preprocess_termref(elem)
        origin = elem.at(ns("./origin"))
        s = termsource_status(elem["status"]) and origin.next = l10n(", #{s}")
        termsource_add_modification_text(elem.at(ns("./modification")))
        while elem&.next_element&.name == "termsource"
          elem << "; #{to_xml(elem.next_element.remove.children)}"
        end
      end

      def termref_parse(elem, out)
        preprocess_termref(elem)
        elem.children = l10n("[#{@i18n.source}: #{to_xml(elem.children).strip}]")
        out.t do |p|
          elem.children.each { |n| parse(n, p) }
        end
      end
    end
  end
end
