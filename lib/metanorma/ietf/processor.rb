require "metanorma/processor"
require "tempfile"

require "isodoc/ietf/rfc_convert"

module Metanorma
  module Ietf
    RfcConvert = ::IsoDoc::Ietf::RfcConvert

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
          raise "[metanorma-ietf] Fatal: unable to generate #{format}," \
                " the command `xml2rfc` is not found in path."
        end
      end

      def output(isodoc_node, inname, outname, format, options = {})
        options_preprocess(options)
        case format
        when :rfc
          outname ||= inname.sub(/\.xml$/, ".rfc.xml")
          RfcConvert.new(options).convert(inname, isodoc_node, nil, outname)
          @done_rfc = true
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

        outext = { txt: ".txt", pdf: ".pdf", html: ".html" }[format]
        outflag = { txt: "--text", pdf: "--pdf", html: "--html" }[format]

        outname ||= inname.sub(/\.xml$/, outext)
        system("xml2rfc", outflag, rfcname, "-o", outname)
      end
    end
  end
end
