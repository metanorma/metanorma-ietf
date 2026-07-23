# frozen_string_literal: true

require "metanorma/document"
require "rfcxml"
require "sterile"
require "htmlentities"

module Metanorma
  module Ietf
    module Transformer
      autoload :Base, "metanorma/ietf/transformer/base"
      autoload :NullObjects, "metanorma/ietf/transformer/null_objects"
      autoload :OrderTracker, "metanorma/ietf/transformer/order_tracker"
      autoload :IetfToRfcV3, "metanorma/ietf/transformer/ietf_to_rfc_v3"
      autoload :RfcV3ToIetf, "metanorma/ietf/transformer/rfc_v3_to_ietf"

      class Error < StandardError; end

      # Transform between Metanorma XML and RFC XML v3.
      #
      # @param xml_string [String] input XML
      # @param direction [Symbol] :forward (MN→RFC) or :reverse (RFC→MN)
      # @param options [Hash] transformation options
      # @return [String] transformed XML string
      def self.convert(xml_string, direction: :forward, **options)
        case direction
        when :forward
          convert_forward(xml_string, options)
        when :reverse
          convert_reverse(xml_string, options)
        else
          raise Error, "Unknown direction: #{direction}. Use :forward or :reverse"
        end
      end

      # Forward: Metanorma XML → RFC XML v3. The pipeline's intended
      # first stage is the genuine shared presentation converter
      # (architecture B, #233): Semantic XML →
      # IsoDoc::Ietf::PresentationXMLConvert → from_xml → transform.
      # Currently OPT-IN (presentation: true); the default flip rides
      # the pending expectation migration and the round-trip design
      # question (whether reverse-produced MN XML re-presents on the
      # forward leg) — see qa-plan.
      def self.convert_forward(xml_string, options = {})
        if options[:presentation]
          xml_string = presentation(xml_string, options)
        end
        # strip only the Metanorma default namespace: a blanket strip also
        # denamespaces embedded MathML/SVG, whose models then parse empty
        stripped = xml_string.gsub(%r{\sxmlns="https?://www\.metanorma\.org/ns/[^"]*"}, "")
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

      # Semantic XML → presentation XML via the shared converter
      # (lazy-required: the reverse path does not need isodoc)
      def self.presentation(xml_string, options = {})
        require "isodoc/ietf/presentation_xml_convert"
        IsoDoc::Ietf::PresentationXMLConvert
          .new(language: options[:language] || "en",
               script: options[:script] || "Latn")
          .convert("presentation", xml_string, true)
      end

      # Reverse: RFC XML v3 → Metanorma XML
      def self.convert_reverse(xml_string, options = {})
        rfc = Rfcxml::V3::Rfc.from_xml(xml_string)
        transformer = RfcV3ToIetf::Transformer.new(rfc, options)
        root = transformer.transform
        root.to_xml
      end
    end
  end
end
