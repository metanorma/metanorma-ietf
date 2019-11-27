require "asciidoctor"
require "asciidoctor/standoc/converter"
require "isodoc/ietf/rfc_convert"
require_relative "./front"

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

      def paragraph(node)
        return termsource(node) if node.role == "source"
        attrs = { keepWithNext: node.attr("keepWithNext"),
                  keepWithPrevious: node.attr("keepWithPrevious"),
                  id: ::Asciidoctor::Standoc::Utils::anchor_or_uuid(node) }
        noko do |xml|
          xml.p **attr_code(attrs) do |xml_t|
            xml_t << node.content
          end
        end.join("\n")
      end

      def clause_parse(attrs, xml, node)
        attrs[:numbered] = node.attr("numbered")
        attrs[:removeInRFC] = node.attr("removeInRFC")
        attrs[:toc] = node.attr("toc")
        super
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
