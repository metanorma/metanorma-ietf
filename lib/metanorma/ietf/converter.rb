require "asciidoctor"
require "metanorma/standoc/converter"
require "isodoc/ietf/rfc_convert"
require_relative "./front"
require_relative "./blocks"
require_relative "./validate"
require_relative "./cleanup"
require_relative "./macros"

module Metanorma
  module Ietf
    class Converter < ::Metanorma::Standoc::Converter
      Asciidoctor::Extensions.register do
        inline_macro Metanorma::Ietf::InlineCrefMacro
      end

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
        File.open("#{@filename}.xml", "w:UTF-8") { |f| f.write(ret) }
        rfc_converter(node).convert("#{@filename}.xml")
      end

      def init_misc(node)
        super
        @default_doctype = "internet-draft"
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
          when :asciimath then stem_parse(node.text, xml, :asciimath, node)
          when :latexmath then stem_parse(node.text, xml, :latexmath, node)
          else
            case node.role
            when "bcp14" then xml.bcp14 { |s| s << node.text.upcase }
            else
              xml << node.text
            end
          end
        end
      end

      def inline_anchor_xref(node)
        f, c = xref_text(node)
        f1, c = eref_text(node) if f.nil?
        t, rel = xref_rel(node)
        attrs = { target: t, type: "inline", displayFormat: f1, format: f,
                  relative: rel }
        noko do |xml|
          xml.xref **attr_code(attrs) do |x|
            x << c
          end
        end
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

      def norm_ref_preface(sect); end

      def clause_attrs_preprocess(attrs, node)
        attrs[:numbered] = node.attr("numbered")
        attrs[:removeInRFC] = node.attr("removeInRFC")
        attrs[:toc] = node.attr("toc")
        super
      end

      def annex_attrs_preprocess(attrs, node)
        attrs[:numbered] = node.attr("numbered")
        attrs[:removeInRFC] = node.attr("removeInRFC")
        attrs[:toc] = node.attr("toc")
        super
      end

      def introduction_parse(attrs, xml, node)
        clause_parse(attrs, xml, node)
      end

      def inline_indexterm(node)
        noko do |xml|
          node.type == :visible and xml << node.text.sub(/^primary:(?=\S)/, "")
          terms = (node.attr("terms") || [node.text]).map { |x| xml_encode(x) }
          if /^primary:\S/.match?(terms[0])
            terms[0].sub!(/^primary:/, "")
            has_primary = true
          end
          inline_indexterm1(has_primary, terms, xml)
        end
      end

      def inline_indexterm1(has_primary, terms, xml)
        xml.index **attr_code(primary: has_primary) do |i|
          i.primary { |x| x << terms[0] }
          a = terms[1] and i.secondary { |x| x << a }
          a = terms[2] and i.tertiary { |x| x << a }
        end
      end

      def html_extract_attributes(node)
        super.merge(usexinclude: node.attr("use-xinclude"))
      end

      def rfc_converter(node)
        IsoDoc::Ietf::RfcConvert.new(html_extract_attributes(node))
      end

      def isodoc(lang, script, locale, i18nyaml = nil)
        conv = rfc_converter(EmptyAttr.new)
        i18n = conv.i18n_init(lang, script, locale, i18nyaml)
        conv.metadata_init(lang, script, locale, i18n)
        conv
      end
    end
  end
end
