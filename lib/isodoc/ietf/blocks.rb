module IsoDoc
  module Ietf
    class RfcConvert < ::IsoDoc::Convert
      def para_attrs(node)
        { keepWithNext: node["keep-with-next"],
          keepWithPrevious: node["keep-with-previous"],
          indent: node["indent"],
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

      def semx_source_parse(node, out)
        termref_parse(node, out)
      end

      def sourcecode_parse(node, out)
        b = node.at(ns("./body"))
        out.sourcecode **attr_code(
          anchor: node["id"], type: node["lang"], name: node["filename"],
          markers: node["markers"], src: node["src"]
        ) do |s|
          b&.children&.each do |x|
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
        node.at(ns("./callout-annotation")) or return
        out.t { |p| p << @i18n.key }
        out.dl do |dl|
          node.xpath(ns("./callout-annotation")).each do |a|
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
          if lbl = @xrefs.anchor(node["id"], :label, false)
            lbl.gsub!(%r{</?span[^>]*>}, "")
            /^\(.+?\)$/.match?(lbl) or lbl = "(#{lbl})"
            p << "    #{lbl}"
          end
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

      def render_annotations?(node)
        node.at(ns("//presentation-metadata/render-document-annotations"))
          &.text == "true" ||
          node.at(ns("//bibdata/ext/notedraftinprogress"))
      end

      def review_note_parse(node, out)
        render_annotations?(node) or return
        out.cref **attr_code(anchor: node["id"], display: node["display"],
                             source: node["reviewer"], from: node["from"]) do |c|
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
        out.sourcecode **attr_code(
          anchor: node["id"], type: node["lang"], name: node["filename"],
          markers: node["markers"], src: node["src"]
        ) do |s|
          node.children.each do |x|
            %w(name dl).include?(x.name) and next
            parse(x, s)
          end
        end
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
