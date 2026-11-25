require "metanorma/processor"
require "open3"
require "tempfile"
require "fileutils"
require_relative "transformer"

module Metanorma
  module Ietf

    class Processor < Metanorma::Processor
      def initialize # rubocop:disable Lint/MissingSuper
        @short = :ietf
        @input_format = :asciidoc
        @asciidoctor_backend = :ietf
      end

      def output_formats
        {
          rxl: "rxl",
          xml: "xml",
          rfc: "rfc.xml",
          html: "html",
          txt: "txt",
          pdf: "pdf",
        }
      end

      def version
        "Metanorma::Ietf #{::Metanorma::Ietf::VERSION}"
      end

      def extract_options(_isodocxml)
        {}
      end

      # From mislav: https://stackoverflow.com/questions/2108727
      #        /which-in-ruby-checking-if-program-exists-in-path-from-ruby
      def which(cmd)
        exts = ENV["PATHEXT"] ? ENV["PATHEXT"].split(";") : [""]
        ENV["PATH"].split(File::PATH_SEPARATOR).each do |path|
          exts.each do |ext|
            exe = File.join(path, "#{cmd}#{ext}")
            return exe if File.executable?(exe) && !File.directory?(exe)
          end
        end
        nil
      end

      def use_presentation_xml(_ext)
        false
      end

      def check_xml2rfc_present?(format)
        if which("xml2rfc").nil?
          raise "[metanorma-ietf] Fatal: unable to generate #{format}, " \
                "the command `xml2rfc` is not found in path."
        end
      end

      # The :rfc leg runs architecture B (#233): presentation stage,
      # then model parse, via Transformer::PresentationReader. Core's
      # strip_default_namespace stays OFF: its strip is blanket and
      # denamespaces embedded MathML/SVG (campaign finding N13); the
      # reader applies the narrow Metanorma-namespace strip itself.
      def document_transformers
        {
          rfc: {
            reader: Transformer::PresentationReader,
            transformer: Transformer::IetfToRfcV3,
            to_xml_options: { pretty: true, declaration: true,
                              encoding: "utf-8" },
            post_process: method(:rfc_post_process),
          },
        }
      end

      # Mirror convert_forward's serialisation tail: bare-ampersand
      # escaping (#302: was present on the library API path only),
      # non-ASCII <u> wrapping (N11), then validation. Findings are
      # recorded in the flavor log catalog through Metanorma::Utils::Log
      # (the Metanorma::Standoc::Validate shape); abort-severity
      # entries are stashed so the output stage can quarantine (#302:
      # the released leg moved invalid output to .err and halted; the
      # port had reduced that to warnings)
      def rfc_post_process(xml, transformer, options)
        xml = Transformer.escape_bare_ampersands(xml)
        xml = Transformer.u_cleanup(xml)
        @rfc_content_errors = []
        @rfc_validator = nil
        if options[:validate]
          rfc = transformer.rfc
          @rfc_validator = RfcValidate.new
          @fatal_rfc_errors = @rfc_validator.content_validate(rfc, transformer.doc)
          @rfc_validator.content_warnings(rfc)
          @rfc_validator.record_filename_hint(rfc.doc_name)
          @rfc_content_errors = @fatal_rfc_errors +
            transformer.content_validate(xml)
          transformer.schema_validate(xml)
            .each { |e| warn "RFC XML: #{e}" }
        end
        xml
      end

      def output(isodoc_node, inname, outname, format, options = {})
        options_preprocess(options)
        case format
        when :rfc
          outname ||= inname.sub(/\.xml$/, ".rfc.xml")
          super(isodoc_node, inname, outname, format,
                options.merge(validate: true))
          if @rfc_content_errors&.any?
            @rfc_validator&.write(outname)
            FileUtils.mv(outname, "#{outname}.err", force: true)
            warn "FATAL ERRORS:\n\n#{@fatal_rfc_errors.join("\n\n")}" if @fatal_rfc_errors.any?
            warn "Cannot continue processing"
          else
            @rfc_validator&.entries? and @rfc_validator.write(outname)
            @done_rfc = true
          end
        when :txt, :pdf, :html
          xml2rfc(isodoc_node, inname, outname, format, options)
        else
          super
        end
      end

      def xml2rfc(isodoc_node, inname, outname, format, options)
        check_xml2rfc_present?(format)

        rfcname = inname.sub(/\.xml$/, ".rfc.xml")
        unless @done_rfc && File.exist?(rfcname)
          output(isodoc_node, inname, rfcname, :rfc, options)
        end
        unless File.exist?(rfcname)
          warn "Cannot continue processing"
          return nil
        end

        outext = { txt: ".txt", pdf: ".pdf", html: ".html" }[format]
        outflag = { txt: "--text", pdf: "--pdf", html: "--html" }[format]

        outname ||= inname.sub(/\.xml$/, outext)
        _out, err, status = Open3.capture3("xml2rfc", outflag, rfcname,
                                           "-o", outname)
        warn err unless err.empty?
        record_preptool_warnings(err, rfcname)
        status.success?
      end

      # xml2rfc's preptool runs its 5.4.x submission checklist on every
      # txt/pdf/html rendering and prints warnings; the raw pass-through
      # stays on stderr, and the findings also land in the flavor log so
      # the validation report stops being silent about the reference
      # toolchain's opinion (metanorma-ietf#366)
      def record_preptool_warnings(err, rfcname)
        return unless @rfc_validator
        err.each_line do |line|
          next unless (m = line.match(/warning:(.+)/i))

          @rfc_validator.record_preptool_warning(m[1].strip)
        end
        @rfc_validator.write(rfcname) if @rfc_validator.entries?
      end
    end
  end
end
