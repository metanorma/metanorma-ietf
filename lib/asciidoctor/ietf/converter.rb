require "asciidoctor"
require "metanorma-standoc"
require "asciidoctor/ietf/contributor"

module Asciidoctor
  module Ietf
    class Converter < Standoc::Converter
      include Asciidoctor::Ietf::Contributor

      register_for "ietf"

      def makexml(node)
        ietf_xml = cleanup(Nokogiri::XML(build_ieft_doc(node)))
        validate(ietf_xml) unless @novalid
        ietf_xml.root.add_namespace(nil, "http://riboseinc.com/isoxml")

        ietf_xml
      end

      alias :pass :content

      private

      def build_ieft_doc(node)
        result = ["<?xml version='1.0' encoding='UTF-8'?>\n<ietf-standard>"]
        result << noko { |ixml| front node, ixml }
        result << noko { |ixml| middle node, ixml }
        result << "</ietf-standard>"

        textcleanup(result.flatten)
      end

      def validate(document)
        content_validate(document)
        schema_validate(
          formattedstr_strip(document.dup),
          File.join(File.dirname(__FILE__), "ietf.rng"),
        )
      end
    end
  end
end
