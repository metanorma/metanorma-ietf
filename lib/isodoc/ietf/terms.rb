module IsoDoc::Ietf
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
      out.t do |p|
        p << l10n("#{@deprecated_lbl}: ")
        node.children.each { |c| parse(c, p) }
      end
    end

    def admitted_term_parse(node, out)
      out.t do |p|
        node.children.each { |c| parse(c, p) }
      end
    end

    def term_parse(node, out)
      out.name do |p|
        node.children.each { |n| parse(n, p) }
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
      clause_parse(node, out)
    end

    def termdocsource_parse(_node, _out)
    end
  end
end
