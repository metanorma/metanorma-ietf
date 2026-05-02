# frozen_string_literal: true

require "metanorma/ietf_document"
require "rfcxml"
require "sterile"
require "htmlentities"
require_relative "transformer/ietf_to_rfc_v3"

module Metanorma
  module Ietf
    module Transformer
      class Error < StandardError; end

      def self.convert(xml_string, options = {})
        stripped = xml_string.gsub(/\sxmlns="[^"]*"/, "")
        doc = Metanorma::IetfDocument::Root.from_xml(stripped)
        transformer = IetfToRfcV3.new(doc, options)
        rfc = transformer.transform
        xml = rfc.to_xml(pretty: true, declaration: true, encoding: "utf-8")

        if options[:validate]
          errors = transformer.validate_rfc_xml(xml)
          errors.each { |e| warn "RFC XML: #{e}" }
        end

        xml
      end
    end
  end
end
