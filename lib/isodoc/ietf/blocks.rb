module IsoDoc
  module Ietf
    class RfcConvert < ::IsoDoc::Convert
      def para_attrs(node)
        { keepWithNext: node["keep-with-next"],
          keepWithPrevious: node["keep-with-previous"],
          anchor: node["id"] }
      end

      def para_parse(node, out)
        out.t **attr_code(para_attrs(node)) do |p|
          unless @termdomain.empty?
            p << "&lt;#{@termdomain}&gt; "
            @termdomain = ""
          end
          node.children.each { |n| parse(n, p) unless n.name == "note" }
        end
        node.xpath(ns("./note")).each { |n| parse(n, out) }
      end

      # NOTE ignoring "bare" attribute, which is tantamount to "empty"
      def ul_attrs(node)
        { anchor: node["id"], empty: node["nobullet"],
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

      def dl_attrs(node)
        attr_code(anchor: node["id"], newline: node["newline"],
                  indent: node["indent"], spacing: node["spacing"])
      end

      def dt_parse(dterm, term)
        if dterm.elements.empty? then term << dterm.text
        else dterm.children.each { |n| parse(n, term) }
        end
      end

      def note_label(node)
        n = @xrefs.get[node["id"]]
        n.nil? || n[:label].nil? || n[:label].empty? and
          return l10n("#{@i18n.note}: ")
        l10n("#{@i18n.note} #{n[:label]}: ")
      end

      def note_parse(node, out)
        first = node.first_element_child
        out.aside **attr_code(anchor: node["id"] || first["id"]) do |a|
          a.t do |p|
            p << note_label(node)
            first.name == "p" and first.children.each { |n| parse(n, p) }
          end
          (first.name == "p" and
            node.elements.drop(1).each { |n| parse(n, out) }) or
            node.children.each { |n| parse(n, out) }
        end
      end

      def example_parse(node, out)
        example_label(node, out, node.at(ns("./name")))
        node.elements.each { |n| parse(n, out) unless n.name == "name" }
      end

      def example_label(node, div, name)
        n = @xrefs.get[node["id"]]
        div.t **attr_code(anchor: node["id"], keepWithNext: "true") do |p|
          lbl = if n.nil? || n[:label].nil? || n[:label].empty?
                  @i18n.example
                else l10n("#{@i18n.example} #{n[:label]}")
                end
          p << lbl
          name and !lbl.nil? and p << ": "
          name&.children&.each { |e| parse(e, p) }
        end
      end

      def source_parse(node, out)
        termref_parse(node, out)
      end

      def sourcecode_parse(node, out)
        out.sourcecode **attr_code(
          anchor: node["id"], type: node["lang"], name: node["filename"],
          markers: node["markers"], src: node["src"]
        ) do |s|
          node.children.each do |x|
            %w(name dl).include?(x.name) and next
            parse(x, s)
          end
        end
        annotation_parse(node, out)
      end

      def pre_parse(node, out)
        out.artwork **attr_code(anchor: node["id"], align: node["align"],
                                alt: node["alt"], type: "ascii-art") do |s|
          s.cdata node.text.sub(/^\n/, "").gsub(/\t/, "    ")
        end
      end

      def annotation_parse(node, out)
        @sourcecode = false
        node.at(ns("./annotation")) or return
        out.t { |p| p << @i18n.key }
        out.dl do |dl|
          node.xpath(ns("./annotation")).each do |a|
            annotation_parse1(a, dl)
          end
        end
      end

      def annotation_parse1(ann, dlist)
        dlist.dt ann.at(ns("//callout[@target='#{ann['id']}']")).text
        dlist.dd do |dd|
          ann.children.each { |n| parse(n, dd) }
        end
      end

      def formula_where(dlist, out)
        dlist or return
        out.t { |p| p << @i18n.where }
        parse(dlist, out)
      end

      def formula_parse1(node, out)
        out.t **attr_code(anchor: node["id"]) do |p|
          parse(node.at(ns("./stem")), p)
          lbl = @xrefs.anchor(node["id"], :label, false)
          lbl.nil? or
            p << "    (#{lbl})"
        end
      end

      def formula_parse(node, out)
        formula_parse1(node, out)
        formula_where(node.at(ns("./dl")), out)
        node.children.each do |n|
          %w(stem dl).include? n.name and next
          parse(n, out)
        end
      end

      def quote_attribution(node)
        author = node.at(ns("./author"))&.text
        source = node.at(ns("./source/@uri"))&.text
        attr_code(quotedFrom: author, cite: source)
      end

      def quote_parse(node, out)
        out.blockquote **quote_attribution(node) do |p|
          node.children.each do |n|
            parse(n, p) unless ["author", "source"].include? n.name
          end
        end
      end

      def admonition_name(node, type)
        name = node&.at(ns("./name")) and return name
        name = Nokogiri::XML::Node.new("name", node.document)
        type && @i18n.admonition[type] or return
        name << @i18n.admonition[type]&.upcase
        name
      end

      def admonition_name_parse(_node, div, name)
        div.t keepWithNext: "true" do |p|
          name.children.each { |n| parse(n, p) }
        end
      end

      def admonition_parse(node, out)
        type = node["type"]
        name = admonition_name(node, type)
        out.aside anchor: node["id"] do |t|
          admonition_name_parse(node, t, name) if name
          node.children.each { |n| parse(n, t) unless n.name == "name" }
        end
      end

      def review_note_parse(node, out)
        out.cref **attr_code(anchor: node["id"], display: node["display"],
                             source: node["reviewer"]) do |c|
          if name = node.at(ns("./name"))
            name.children.each { |n| parse(n, c) }
            c << " "
          end
          node.children.each { |n| parse(n, c) unless n.name == "name" }
        end
      end

      def figure_name_parse(_node, div, name)
        name.nil? and return
        div.name do |_n|
          name.children.each { |n| parse(n, div) }
        end
      end

      def pseudocode_parse(node, out)
        sourcecode_parse(node, out)
      end

      def figure_parse(node, out)
        node["class"] == "pseudocode" || node["type"] == "pseudocode" and
            return pseudocode_parse(node, out)
        @in_figure = true
        out.figure **attr_code(anchor: node["id"]) do |div|
          figure_name_parse(node, div, node.at(ns("./name")))
          node.children.each do |n|
            parse(n, div) unless n.name == "name"
          end
        end
        @in_figure = false
      end

      def toc_parse(_node, _out); end
    end
  end
end
