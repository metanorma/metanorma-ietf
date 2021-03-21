require "asciidoctor"
require "asciidoctor/standoc/converter"
require "isodoc/ietf/rfc_convert"
require_relative "./front"
require_relative "./blocks"
require_relative "./validate"

module Asciidoctor
  module Ietf
    class Converter < ::Asciidoctor::Standoc::Converter
      XML_ROOT_TAG = "ietf-standard".freeze
      XML_NAMESPACE = "https://www.metanorma.org/ns/ietf".freeze

      register_for "ietf"

      def initialize(backend, opts)
        super
        @libdir = File.dirname(__FILE__)
      end

      def makexml(node)
        @draft = node.attributes.has_key?("draft")
        @workgroups = cache_workgroup(node)
        @bcp_bold = !node.attr?("no-rfc-bold-bcp14")
        @xinclude = node.attr?("use-xinclude") 
        super
      end

      def outputs(node, ret)
        File.open(@filename + ".xml", "w:UTF-8") { |f| f.write(ret) }
        rfc_converter(node).convert(@filename + ".xml")
      end

      def doctype(node)
        ret = super
        ret = "internet-draft" if ret == "article"
        ret
      end

      def inline_quoted(node)
        noko do |xml|
          case node.type
          when :emphasis then xml.em { |s| s << node.text }
          when :strong then xml.strong { |s| s << node.text }
          when :monospaced then xml.tt { |s| s << node.text }
          when :double then xml << "\"#{node.text}\""
          when :single then xml << "'#{node.text}'"
          when :superscript then xml.sup { |s| s << node.text }
          when :subscript then xml.sub { |s| s << node.text }
          when :asciimath then stem_parse(node.text, xml, :asciimath)
          when :latexmath then stem_parse(node.text, xml, :latexmath)
          else
            case node.role
            when "bcp14" then xml.bcp14 { |s| s << node.text.upcase }
            else
              xml << node.text
            end
          end
        end.join
      end

      def inline_anchor_xref(node)
        f, c = xref_text(node)
        f1, c = eref_text(node) if f.nil?
        t, rel = xref_rel(node)
        noko do |xml|
          xml.xref **attr_code(target: t, type: "inline",
                               displayFormat: f1, format: f,
                               relative: rel ) do |x|
                                 x << c
                               end
        end.join
      end

      def table_attrs(node)
        super.merge(align: node.attr("align"))
      end

      def eref_text(node)
        matched = /^(of|comma|parens|bare),(.*+)$/.match node.text
        if matched.nil?
          f = nil
          c = node&.text&.sub(/^fn: /, "")
        else
          f = matched[1]
          c = matched[2]
        end
        [f, c]
      end

      def xref_text(node)
        matched = /^format=(counter|title|none|default)(:.*+)?$/.match node.text
        if matched.nil?
          f = nil
          c = node&.text&.sub(/^fn: /, "")
        else
          f = matched[1]
          c = matched[2]&.sub(/^:/, "")
        end
        [f, c]
      end

      def xref_rel(node)
        matched = /^([^#]+)#(.+)$/.match node.target
        if matched.nil?
          t = node.target.sub(/^#/, "")
          rel = nil
        else
          t = matched[1].sub(/\.(xml|adoc)$/, "")
          rel = matched[2]
        end
        [t, rel]
      end

      def cleanup(xmldoc)
        bcp14_cleanup(xmldoc)
        abstract_cleanup(xmldoc)
        super
        rfc_anchor_cleanup(xmldoc)
      end

      BCP_KEYWORDS = ["MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
                      "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", "OPTIONAL"].freeze

      def abstract_cleanup(xmldoc)
        xmldoc.xpath("//abstract[not(text())]").each do |x|
          x.remove
          warn "Empty abstract section removed"
        end
      end

      def bcp14_cleanup(xmldoc)
        return unless @bcp_bold
        xmldoc.xpath("//strong").each do |s|
          next unless BCP_KEYWORDS.include?(s.text)
          s.name = "bcp14"
        end
      end

      def rfc_anchor_cleanup(xmldoc)
        map = {}
        xmldoc.xpath("//bibitem[docidentifier/@type = 'rfc-anchor']").each do |b|
          next if b.at("./ancestor::bibdata")
          map[b["id"]] = b.at("./docidentifier[@type = 'rfc-anchor']").text
          b["id"] = b.at("./docidentifier[@type = 'rfc-anchor']").text
        end
        xmldoc.xpath("//eref | //origin").each do |x|
          map[x["bibitemid"]] and x["bibitemid"] = map[x["bibitemid"]]
        end
        xmldoc
      end

      def smartquotes_cleanup(xmldoc)
        xmldoc.traverse do |n|
          next unless n.text?
          n.replace(HTMLEntities.new.encode(
            n.text.gsub(/\u2019|\u2018|\u201a|\u201b/, "'").
            gsub(/\u201c|\u201d|\u201e|\u201f/, '"'), :basic))
        end
        xmldoc
      end

      def xref_to_eref(x)
        super
        x.delete("format")
      end

      def xref_cleanup(xmldoc)
        super
        xmldoc.xpath("//xref").each do |x|
          x.delete("displayFormat")
          x.delete("relative")
        end
      end

      def norm_ref_preface(f)
      end

      def clause_parse(attrs, xml, node)
        attrs[:numbered] = node.attr("numbered")
        attrs[:removeInRFC] = node.attr("removeInRFC")
        attrs[:toc] = node.attr("toc")
        super
      end

      def annex_parse(attrs, xml, node)
        attrs[:numbered] = node.attr("numbered")
        attrs[:removeInRFC] = node.attr("removeInRFC")
        attrs[:toc] = node.attr("toc")
        super
      end

      def introduction_parse(attrs, xml, node)
        clause_parse(attrs, xml, node)
      end

      def quotesource_cleanup(xmldoc)
        xmldoc.xpath("//quote/source | //terms/source").each do |x|
          if x["target"] =~ URI::DEFAULT_PARSER.make_regexp
            x["uri"] = x["target"]
            x.delete("target")
          else
            xref_to_eref(x)
          end
        end
      end

      def inline_indexterm(node)
        noko do |xml|
          node.type == :visible and xml << node.text.sub(/^primary:(?=\S)/, "")
          terms = (node.attr("terms") || [node.text]).map { |x| xml_encode(x) }
          if /^primary:\S/.match(terms[0])
            terms[0].sub!(/^primary:/, "")
            has_primary = true
          end
          xml.index **attr_code(primary: has_primary) do |i|
            i.primary { |x| x << terms[0] }
            a = terms.dig(1) and i.secondary { |x| x << a }
            a = terms.dig(2) and i.tertiary { |x| x << a }
          end
        end.join
      end

      def section_names_refs_cleanup(x)
      end

      def html_extract_attributes(node)
        super.merge(use_xinclude: node.attr("use-xinclude"))
      end

      def rfc_converter(node)
        IsoDoc::Ietf::RfcConvert.new(html_extract_attributes(node))
      end

      def isodoc(lang, script, i18nyaml = nil)
        conv = rfc_converter(EmptyAttr.new)
        i18n = conv.i18n_init(lang, script, i18nyaml)
        conv.metadata_init(lang, script, i18n)
        conv
      end
    end
  end
end
