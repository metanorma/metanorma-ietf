require "asciidoctor"
require "metanorma-standoc"

module Asciidoctor
  module Ietf
    class Converter < Standoc::Converter
      register_for "ietf"

      def makexml(node)
        ietf_xml = cleanup(Nokogiri::XML(build_ieft_doc(node)))
        ietf_xml.root.add_namespace(nil, "http://riboseinc.com/isoxml")
        validate(ietf_xml) unless @novalid

        ietf_xml
      end

      private

      def build_ieft_doc(node)
        result = ["<?xml version='1.0' encoding='UTF-8'?>\n<ietf-standard>"]
        result << noko { |ixml| front node, ixml }
        result << noko { |ixml| middle node, ixml }
        result << "</ietf-standard>"

        textcleanup(result.flatten * "\n")
      end
    end
  end
end
