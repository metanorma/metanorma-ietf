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
          rxl: "rxl",
          xml: "xml",
          rfc: "rfc.xml",
          html: "html",
          txt: "txt",
          pdf: "pdf"
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

      def uses_presentation_xml
        false
      end

      def xml2rfc_present?
        !which("xml2rfc").nil?
      end

      def output(isodoc_node, inname, outname, format, options={})
        case format
        when :rfc
          outname ||= inname.sub(/\.xml$/, ".rfc.xml")
          IsoDoc::Ietf::RfcConvert.new(options).convert(inname, isodoc_node, nil, outname)
          @done_rfc = true

        when :txt
          unless xml2rfc_present?
            warn "[metanorma-ietf] Error: unable to generate #{format}, the command `xml2rfc` is not found in path."
            return
          end

          rfcname = inname.sub(/\.xml$/, ".rfc.xml")
          output(isodoc_node, inname, rfcname, :rfc, options) unless @done_rfc

          outname ||= inname.sub(/\.xml$/, ".txt")
          system("xml2rfc --text #{rfcname} -o #{outname}")

        when :pdf
          unless xml2rfc_present?
            warn "[metanorma-ietf] Error: unable to generate #{format}, the command `xml2rfc` is not found in path."
            return
          end

          rfcname = inname.sub(/\.xml$/, ".rfc.xml")
          output(isodoc_node, inname, rfcname, :rfc, options) unless @done_rfc

          outname ||= inname.sub(/\.xml$/, ".pdf")
          system("xml2rfc --pdf #{rfcname} -o #{outname}")

        when :html
          unless xml2rfc_present?
            warn "[metanorma-ietf] Error: unable to generate #{format}, the command `xml2rfc` is not found in path."
            return
          end

          rfcname = inname.sub(/\.xml$/, ".rfc.xml")
          output(isodoc_node, inname, rfcname, :rfc, options) unless @done_rfc

          outname ||= inname.sub(/\.xml$/, ".html")
          system("xml2rfc --html #{rfcname} -o #{outname}")

        else
          super
        end
      end
    end
  end
end
