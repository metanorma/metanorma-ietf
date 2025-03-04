module IsoDoc
  module Ietf
    class RfcConvert < ::IsoDoc::Convert
      def ul_attrs(node)
        { anchor: node["id"], empty: node["nobullet"],
          indent: node["indent"], bare: node["bare"],
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
        OL_STYLE[type&.to_sym] || type
      end

      def ol_attrs(node)
        { anchor: node["id"],
          spacing: node["spacing"], indent: node["indent"],
          type: ol_style(node["type"]),
          group: node["group"], start: node["start"] }
      end

      def ol_parse(node, out)
        out.ol **attr_code(ol_attrs(node)) do |ol|
          node.children.each { |n| parse(n, ol) }
        end
      end

      def dl_attrs(node)
        attr_code(anchor: node["id"], newline: node["newline"],
                  indent: node["indent"], spacing: node["spacing"])
      end

      def dl_parse(node, out)
        list_title_parse(node, out)
        out.dl **dl_attrs(node) do |v|
          node.elements.select { |n| dt_dd? n }.each_slice(2) do |dt, dd|
            dl_parse1(v, dt, dd)
          end
        end
        dl_parse_notes(node, out)
      end

      def dt_parse(dterm, term)
        if dterm.elements.empty? then term << dterm.text
        else dterm.children.each { |n| parse(n, term) }
        end
      end

      def dl_parse1(dlist, dterm, ddef)
        dlist.dt **attr_code(anchor: dterm["id"]) do |term|
          dt_parse(dterm, term)
        end
        dlist.dd **attr_code(anchor: ddef["id"]) do |listitem|
          ddef.children.each { |n| parse(n, listitem) }
        end
      end

      def li_parse(node, out)
        out.li **attr_code(anchor: node["id"]) do |li|
          if node["uncheckedcheckbox"] == "true"
            li << '<span class="zzMoveToFollowing">' \
                  '<input type="checkbox" checked="checked"/></span>'
          elsif node["checkedcheckbox"] == "true"
            li << '<span class="zzMoveToFollowing">' \
                  '<input type="checkbox"/></span>'
          end
          node.children.each { |n| parse(n, li) }
        end
      end
    end
  end
end
