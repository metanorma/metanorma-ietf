require "asciidoctor"
require "asciidoctor/standoc/converter"
require "isodoc/ietf/rfc_convert"
require_relative "./front"
require_relative "./blocks"

module Asciidoctor
  module Ietf
    class Converter < ::Asciidoctor::Standoc::Converter

      register_for "ietf"

      def initialize(backend, opts)
        super
        @libdir = File.dirname(__FILE__)
      end

      def makexml(node)
        result = ["<?xml version='1.0' encoding='UTF-8'?>\n<ietf-standard>"]
        @draft = node.attributes.has_key?("draft")
        result << noko { |ixml| front node, ixml }
        result << noko { |ixml| middle node, ixml }
        result << "</ietf-standard>"
        result = textcleanup(result)
        ret1 = cleanup(Nokogiri::XML(result))
        validate(ret1) unless @novalid
        ret1.root.add_namespace(nil, "https://open.ribose.com/standards/ietf")
        ret1
      end

      def document(node)
        init(node)
        ret1 = makexml(node)
        ret = ret1.to_xml(indent: 2)
        unless node.attr("nodoc") || !node.attr("docfile")
          filename = node.attr("docfile").gsub(/\.adoc/, ".xml").
            gsub(%r{^.*/}, "")
          File.open(filename, "w") { |f| f.write(ret) }
          rfc_converter(node).convert filename unless node.attr("nodoc")
        end
        @files_to_delete.each { |f| FileUtils.rm f }
        ret
      end

      def doctype(node)
        ret = node.attr("doctype")
        ret = "Internet-Draft" if ret == "article"
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
            when "bcp14" then xml.bcp14 { |s| s << node.text }
            else
              xml << node.text
            end
          end
        end.join
      end

      def inline_anchor_xref(node)
        f, c = xref_text(node)
        t, rel = xref_rel(node)
        noko do |xml|
          xml.xref **attr_code(target: t, type: "inline",
                               displayFormat: f,
                               relative: rel ) do |x|
                                 x << c
                               end
        end.join
      end

      def xref_text(node)
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

      def xref_to_eref(x)
        super
        x.delete("displayFormat")
        x.delete("relative")
      end

      def norm_ref_preface(f)
      end

      def clause_parse(attrs, xml, node)
        attrs[:numbered] = node.attr("numbered")
        attrs[:removeInRFC] = node.attr("removeInRFC")
        attrs[:toc] = node.attr("toc")
        super
      end

      def content_validate(doc)
        super
        image_validate(doc)
      end

      def image_validate(doc)
        doc.xpath("//image").each do |i|
          next if i["mimetype"] == "image/svg+xml"
          warn "image #{i['src'][0, 40]} is not SVG!"
        end
      end

      def validate(doc)
        content_validate(doc)
        schema_validate(formattedstr_strip(doc.dup),
                        File.join(File.dirname(__FILE__), "ietf.rng"))
      end

      def rfc_converter(node)
        IsoDoc::Ietf::RfcConvert.new(html_extract_attributes(node))
      end
    end
  end
end
