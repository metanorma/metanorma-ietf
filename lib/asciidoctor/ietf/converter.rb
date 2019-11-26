require "asciidoctor"
require "asciidoctor/standoc/converter"
require "isodoc/ietf/rfc_convert"

module Asciidoctor
  module Rsd

    # A {Converter} implementation that generates RSD output, and a document
    # schema encapsulation of the document for validation
    #
    class Converter < Standoc::Converter

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
