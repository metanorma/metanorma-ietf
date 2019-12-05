require_relative "./terms"
require_relative "./blocks"
require_relative "./metadata"
require_relative "./front"
require_relative "./table"
require_relative "./inline"
require_relative "./reqt"

module IsoDoc::Ietf
  class RfcConvert < ::IsoDoc::Convert
    def convert1(docxml, filename, dir)
      anchor_names docxml
      noko do |xml|
        xml.rfc **attr_code(rfc_attributes(docxml)) do |html|
          info docxml, nil
          make_link(html, docxml)
          make_front(html, docxml)
          make_middle(html, docxml)
          make_back(html, docxml)
        end
      end.join("\n")
    end

    def metadata_init(lang, script, labels)
        @meta = Metadata.new(lang, script, labels)
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

    def rfc_attributes(docxml)
      t = Time.now.getutc
      obs = xpath_comma(docxml.xpath(ns(
        "//bibdata/relation[@type = 'obsoletes']/bibitem/docidentifier")))
      upd = xpath_comma(docxml.xpath(ns(
        "//bibdata/relation[@type = 'updates']/bibitem/docidentifier")))
      {
        ipr:            docxml&.at(ns("//bibdata/ext/ipr"))&.text,
        obsoletes:      obs,
        updates:        upd,
        indexInclude:   docxml&.at(ns("//bibdata/ext/indexInclude"))&.text,
        iprExtract:     docxml&.at(ns("//bibdata/ext/iprExtract"))&.text,
        sortRefs:       docxml&.at(ns("//bibdata/ext/sortRefs"))&.text,
        symRefs:        docxml&.at(ns("//bibdata/ext/symRefs"))&.text,
        tocInclude:     docxml&.at(ns("//bibdata/ext/tocInclude"))&.text,
        tocDepth:       docxml&.at(ns("//bibdata/ext/tocDepth"))&.text,
        submissionType: docxml&.at(ns(
          "//bibdata/series[@type = 'stream']/title"))&.text,
        'xml:lang':     docxml&.at(ns("//bibdata/language"))&.text,
        version:        "3",
        'xmlns:xi':        "http://www.w3.org/2001/XInclude",
        prepTime:       sprintf("%04d-%02d-%02dT%02d:%02d:%02dZ",
                                t.year, t.month, t.day, t.hour, t.min, t.sec),
      }
    end

    def xpath_comma(xpath)
      return nil if xpath.empty?
      xpath.map { |x| x.text }.join(", ")
    end

    def make_link(out, isoxml)
      links = isoxml.xpath(ns(
        "//bibdata/relation[@type = 'includedIn' or @type = 'describedBy' or "\
        "@type = 'derivedFrom' or @type = 'equivalent']")) || return
        links.each do |l|
          out.link **{ href: l&.at(ns("./bibitem/docidentifier"))&.text,
                       rel: rel2iana(l["type"]) }
        end
    end

    def rel2iana(type)
      case type
      when "includedIn" then "item"
      when "describedBy" then "describedby"
      when "derivedFrom" then "convertedfrom"
      when "equivalent" then "alternate"
      else 
        "alternate"
      end
    end

    def make_middle(out, isoxml)
      out.middle do |middle|
        clause isoxml, middle
      end
    end

    def make_back(out, isoxml)
      out.back do |back|
        annex isoxml, back
        bibliography isoxml, back
      end
    end

    def clause_parse_title(node, div, c1, out)
      return unless c1
      div.name **attr_code( anchor: node["id"], numbered: node["numbered"],
                           removeInRFC: node["removeInRFC"], toc: node["toc"]) do |n|
        c1&.children&.each { |c2| parse(c2, n) }
      end
    end

    def clause_parse(node, out)
      out.section **attr_code( anchor: node["id"], numbered: node["numbered"],
                              removeInRFC: node["removeInRFC"], toc: node["toc"]) do |div|
        clause_parse_title(node, div, node.at(ns("./title")), out)
        node.children.reject { |c1| c1.name == "title" }.each do |c1|
          parse(c1, div)
        end
      end
    end

    def clause(isoxml, out)
      isoxml.xpath("//xmlns:sections/child::*").each do |c|
        out.section **attr_code( anchor: c["id"], numbered: c["numbered"],
                                removeInRFC: c["removeInRFC"], toc: c["toc"]) do |div|
          clause_parse_title(c, div, c.at(ns("./title")), out)
          c.elements.reject { |c1| c1.name == "title" }.each do |c1|
            parse(c1, div)
          end
        end
      end
    end

    def footnote_parse(node, out)
    end

    def error_parse(node, out)
      case node.name
      when "bcp14" then bcp14_parse(node, out)
      else
        text = node.to_xml.gsub(/</, "&lt;").gsub(/>/, "&gt;")
        out.t { |p| p << text }
      end
    end

    def  postprocess(result, filename, dir)
      File.open("#{filename}.rfc.xml", "w:UTF-8") { |f| f.write(result) }
      @files_to_delete.each { |f| FileUtils.rm_rf f }
    end
  end
end
