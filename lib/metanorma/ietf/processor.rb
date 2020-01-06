require "metanorma/processor"
require "tempfile"

module Metanorma
  module Ietf
    class Processor < Metanorma::Processor

      def initialize
        @short = :ietf
        @input_format = :asciidoc
        @asciidoctor_backend = :ietf
      end

      def output_formats
        {
          xml: "xml",
          rfc: "rfc.xml",
          html: "html",
          txt: "txt"
        }
      end

      def version
        "Metanorma::Ietf #{::Metanorma::Ietf::VERSION}"
      end

      def input_to_isodoc(file, filename)
        # This is XML RFC v3 output in text
        Metanorma::Input::Asciidoc.new.process(file, filename, @asciidoctor_backend)
      end

      def extract_options(isodocxml)
        {}
      end

      # From mislav: https://stackoverflow.com/questions/2108727
      #        /which-in-ruby-checking-if-program-exists-in-path-from-ruby
      def which(cmd)
        exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
        ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
          exts.each do |ext|
            exe = File.join(path, "#{cmd}#{ext}")
            return exe if File.executable?(exe) && !File.directory?(exe)
          end
        end
        nil
      end

      def output(isodoc_node, outname, format, options={})
        case format
        when :rfc
          IsoDoc::Ietf::RfcConvert.new(options).convert(outname, isodoc_node)
          @done_rfc = true

        when :txt, :html
          rfcname = outname.sub(/\.(html|txt)$/, ".rfc.xml")
          output(isodoc_node, outname, :rfc, options) unless @done_rfc
          unless which("xml2rfc")
            warn "[metanorma-ietf] Error: unable to generate #{format}, the command `xml2rfc` is not found in path."
            return
          end
          # In xml2rfc, --text and --html are used
          format = :text if format == :txt
          system("xml2rfc --#{format} #{rfcname} -o #{outname}")
        else
          super
        end
      end
    end
  end
end
