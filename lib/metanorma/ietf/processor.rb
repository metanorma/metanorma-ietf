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

      def use_presentation_xml(ext)
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

        when :txt, :pdf, :html
          unless xml2rfc_present?
            raise "[metanorma-ietf] Fatal: unable to generate #{format}," \
                  " the command `xml2rfc` is not found in path."
          end

          rfcname = inname.sub(/\.xml$/, ".rfc.xml")
          unless @done_rfc && File.exist?(rfcname)
            output(isodoc_node, inname, rfcname, :rfc, options)
          end

          outext = case format
            when :txt then ".txt"
            when :pdf then ".pdf"
            when :html then ".html"
          end

          outflag = case format
            when :txt then "--text"
            when :pdf then "--pdf"
            when :html then "--html"
          end

          outname ||= inname.sub(/\.xml$/, outext)
          system("xml2rfc #{outflag} #{rfcname} -o #{outname}")
        else
          super
        end
      end
    end
  end
end
