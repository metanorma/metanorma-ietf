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

      # Forward: Metanorma XML → RFC XML v3. The pipeline's first stage
      # is the genuine shared presentation converter (architecture B,
      # #233): Semantic XML → IsoDoc::Ietf::PresentationXMLConvert →
      # from_xml → transform. ON by default; presentation: false skips
      # it (input already presented, or presentation-free debugging).
      # Reverse-produced MN XML re-presents like any other semantic
      # input — settled by probe evidence 2026-07-24, see qa-plan.
      def self.convert_forward(xml_string, options = {})
        if options.fetch(:presentation, true)
          xml_string = presentation(xml_string, options)
        end
        doc = parse_semantic(xml_string)
        transformer = IetfToRfcV3.new(doc, options)
        rfc = transformer.transform
        xml = rfc.to_xml(pretty: true, declaration: true, encoding: "utf-8")
        xml = escape_bare_ampersands(xml)
        xml = u_cleanup(xml)

        if options[:validate]
          errors = transformer.validate_rfc_xml(xml)
          errors.each { |e| warn "RFC XML: #{e}" }
        end

        xml
      end

      # Text carrying literal HTML entity references ("&para;",
      # "&mdash;") is serialised with the ampersand UNESCAPED,
      # producing unparseable RFC XML (F2; the model stack emits some
      # mixed-content text raw). Escapes every "&" that does not
      # already start a predefined XML entity or a character
      # reference, leaving CDATA sections untouched. Must run before
      # u_cleanup, whose Nokogiri parse chokes on the bare entities.
      def self.escape_bare_ampersands(xml)
        xml.split(/(<!\[CDATA\[.*?\]\]>)/m).map do |part|
          next part if part.start_with?("<![CDATA[")

          part.gsub(/&(?!(?:amp|lt|gt|apos|quot|#\d+|#x\h+);)/, "&amp;")
        end.join
      end

      # Text-run parents whose non-ASCII content the released path
      # wraps in <u> (RfcConvert#u_cleanup)
      UNICODE_WRAP_PARENTS = %w(t blockquote li dd preamble td th
                                annotation).freeze

      # RFC XML declares non-ASCII characters with <u>, which xml2rfc
      # renders as "x (NAME, U+XXXX)"; the released path wraps
      # U+0080..U+FFFF in the same text-run parents (N11).
      def self.u_cleanup(xml)
        doc = Nokogiri::XML(xml)
        coder = HTMLEntities.new
        doc.traverse do |n|
          n.text? or next
          UNICODE_WRAP_PARENTS.include?(n.parent&.name) or next
          /[\u0080-\uffff]/.match?(n.text) or next
          n.replace(coder.encode(n.text, :basic)
            .gsub(/[\u0080-\uffff]/, "<u>\\0</u>"))
        end
        doc.to_xml(encoding: "utf-8")
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

      # Metanorma XML string → document model. Strips only the
      # Metanorma default namespace: a blanket strip also denamespaces
      # embedded MathML/SVG, whose models then parse empty (campaign
      # finding N13).
      def self.parse_semantic(xml_string)
        stripped = xml_string
          .gsub(%r{\sxmlns="https?://www\.metanorma\.org/ns/[^"]*"}, "")
        root = Metanorma::IetfDocument::Root.from_xml(stripped)
        recover_rfc_attributes(root, stripped)
        root
      end

      # bibdata/ext symRefs|tocInclude|sortRefs — the v3 <rfc> ROOT
      # ATTRIBUTE channel the released path reads (section.rb) — are
      # parse ghosts on the model (0.2.9 and 0.5.1 alike; upstream
      # ticket). xml2rfc v3 ignores the <?rfc?> PI channel, so without
      # the root attributes the author's toc/symrefs settings are
      # silently overridden by xml2rfc defaults (F5). Recovered here
      # from the raw XML as a side-channel on the root object;
      # self-retiring — remove once the model maps them.
      def self.recover_rfc_attributes(root, stripped_xml)
        doc = Nokogiri::XML(stripped_xml)
        vals = {}
        %w[symRefs tocInclude sortRefs].each do |k|
          v = doc.at("//bibdata/ext/#{k}")&.text
          vals[k] = v if v && !v.empty?
        end
        root.define_singleton_method(:recovered_rfc_attributes) { vals }
      end

      # Reader for the processor's document-model output leg (#233
      # architecture B): the presentation stage runs first, then the
      # model parse with the narrow namespace strip. Declared as the
      # :rfc reader in Processor#document_transformers with
      # strip_default_namespace left OFF — metanorma-core's own strip
      # is blanket and would reintroduce N13 on this path.
      module PresentationReader
        def self.from_xml(xml_string)
          Transformer.parse_semantic(Transformer.presentation(xml_string))
        end
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
