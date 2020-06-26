require_relative "./terms"
require_relative "./blocks"
require_relative "./metadata"
require_relative "./front"
require_relative "./table"
require_relative "./inline"
require_relative "./reqt"
require_relative "./cleanup"
require_relative "./footnotes"
require_relative "./references"
require_relative "./section"
require_relative "./xref"

module IsoDoc::Ietf
  class RfcConvert < ::IsoDoc::Convert
    def convert1(docxml, filename, dir)
      @xrefs.parse docxml
      info docxml, nil
      xml = noko do |xml|
        xml.rfc **attr_code(rfc_attributes(docxml)) do |html|
          make_link(html, docxml)
          make_front(html, docxml)
          make_middle(html, docxml)
          make_back(html, docxml)
        end
      end.join("\n").sub(/<!DOCTYPE[^>]+>\n/, "")
          set_pis(docxml, Nokogiri::XML(xml))
    end

    def metadata_init(lang, script, labels)
      @meta = Metadata.new(lang, script, labels)
    end

    def xref_init(lang, script, klass, labels, options)
        @xrefs = Xref.new(lang, script, klass, labels, options)
      end

    def extract_delims(text)
      @openmathdelim = "$$"
      @closemathdelim = "$$"
      while %r{#{Regexp.escape(@openmathdelim)}}m.match(text) ||
          %r{#{Regexp.escape(@closemathdelim)}}m.match(text)
        @openmathdelim += "$"
        @closemathdelim += "$"
      end
      [@openmathdelim, @closemathdelim]
    end

    def error_parse(node, out)
      case node.name
      when "bcp14" then bcp14_parse(node, out)
      else
        text = node.to_xml.gsub(/</, "&lt;").gsub(/>/, "&gt;")
        out.t { |p| p << text }
      end
    end

     def textcleanup(docxml)
      passthrough_cleanup(docxml)
     end

    def postprocess(result, filename, dir)
      result = from_xhtml(cleanup(to_xhtml(textcleanup(result)))).
        sub(/<!DOCTYPE[^>]+>\n/, "").
        sub(/(<rfc[^<]+? )lang="[^"]+"/, "\\1")
      File.open(filename, "w:UTF-8") { |f| f.write(result) }
      @files_to_delete.each { |f| FileUtils.rm_rf f }
    end

    def init_file(filename, debug)
      filename = filename.sub(/\.rfc\.xml$/, ".rfc")
      super
    end

    def initialize(options)
      super
      @xinclude = options[:use_xinclude] == "true"
      @format = :rfc
      @suffix = "rfc.xml"
    end
  end
end
