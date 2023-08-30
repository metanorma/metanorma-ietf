module IsoDoc
  module Ietf
    class RfcConvert < ::IsoDoc::Convert
      def common_rfc_pis(node)
        rfc_pis = {
          artworkdelimiter: node&.at(ns("//pi/artworkdelimiter"))&.text,
          artworklines: node&.at(ns("//pi/artworklines"))&.text,
          authorship: node&.at(ns("//pi/authorship"))&.text,
          autobreaks: node&.at(ns("//pi/autobreaks"))&.text,
          background: node&.at(ns("//pi/background"))&.text,
          colonspace: node&.at(ns("//pi/colonspace"))&.text,
          comments: node&.at(ns("//pi/comments"))&.text,
          docmapping: node&.at(ns("//pi/docmapping"))&.text,
          editing: node&.at(ns("//pi/editing"))&.text,
          emoticonic: node&.at(ns("//pi/emoticonic"))&.text,
          footer: node&.at(ns("//pi/footer"))&.text,
          header: node&.at(ns("//pi/header"))&.text,
          inline: node&.at(ns("//pi/inline"))&.text,
          iprnotified: node&.at(ns("//pi/iprnotified"))&.text,
          linkmailto: node&.at(ns("//pi/linkmailto"))&.text,
          linefile: node&.at(ns("//pi/linefile"))&.text,
          notedraftinprogress: node&.at(ns("//pi/notedraftinprogress"))&.text,
          private: node&.at(ns("//pi/private"))&.text,
          refparent: node&.at(ns("//pi/refparent"))&.text,
          rfcedstyle: node&.at(ns("//pi/rfcedstyle"))&.text,
          slides: node&.at(ns("//pi/slides"))&.text,
          "text-list-symbols": node&.at(ns("//pi/text-list-symbols"))&.text,
          tocappendix: node&.at(ns("//pi/tocappendix"))&.text,
          tocindent: node&.at(ns("//pi/tocindent"))&.text,
          tocnarrow: node&.at(ns("//pi/tocnarrow"))&.text,
          tocompact: node&.at(ns("//pi/tocompact"))&.text,
          topblock: node&.at(ns("//pi/topblock"))&.text,
          useobject: node&.at(ns("//pi/useobject"))&.text,
          strict: node&.at(ns("//pi/strict"))&.text || "yes",
          compact: node&.at(ns("//pi/compact"))&.text || "yes",
          subcompact: node&.at(ns("//pi/subcompact"))&.text || "no",
          toc: node&.at(ns("//pi/tocinclude"))&.text,
          tocdepth: node&.at(ns("//pi/toc-depth"))&.text || "4",
          symrefs: node&.at(ns("//pi/sym-refs"))&.text || "yes",
          sortrefs: node&.at(ns("//pi/sort-refs"))&.text || "yes",
        }
        attr_code(rfc_pis)
      end

      def set_pis(node, doc)
        rfc_pis = common_rfc_pis(node)
        rfc_pis.each_pair do |k, v|
          pi = Nokogiri::XML::ProcessingInstruction.new(doc, "rfc",
                                                        "#{k}=\"#{v}\"")
          doc.root.add_previous_sibling(pi)
        end
        doc.to_xml
      end

      def rfc_attributes(docxml)
        # t = Time.now.getutc
        obs = xpath_comma(docxml
          .xpath(ns("//bibdata/relation[@type = 'obsoletes']/bibitem/docidentifier")))
        upd = xpath_comma(docxml
          .xpath(ns("//bibdata/relation[@type = 'updates']/bibitem/docidentifier")))
        {
          docName: @meta.get[:doctype] == "Internet Draft" ? @meta.get[:docnumber] : nil,
          number: @meta.get[:doctype].casecmp?("rfc") ? @meta.get[:docnumber] : nil,
          category: series2category(
            docxml&.at(ns("//bibdata/series[@type = 'intended']/title"))&.text,
          ),
          ipr: docxml&.at(ns("//bibdata/ext/ipr"))&.text,
          consensus: docxml&.at(ns("//bibdata/ext/consensus"))&.text,
          obsoletes: obs,
          updates: upd,
          indexInclude: docxml&.at(ns("//bibdata/ext/indexInclude"))&.text,
          iprExtract: docxml&.at(ns("//bibdata/ext/iprExtract"))&.text,
          sortRefs: docxml&.at(ns("//bibdata/ext/sortRefs"))&.text,
          symRefs: docxml&.at(ns("//bibdata/ext/symRefs"))&.text,
          tocInclude: docxml&.at(ns("//bibdata/ext/tocInclude"))&.text,
          tocDepth: docxml&.at(ns("//bibdata/ext/tocDepth"))&.text,
          submissionType: docxml&.at(ns(
            "//bibdata/series[@type = 'stream']/title",
          ))&.text || "IETF",
          "xml:lang": docxml&.at(ns("//bibdata/language"))&.text,
          version: "3",
          "xmlns:xi": "http://www.w3.org/2001/XInclude",
        }
      end

      def series2category(series)
        case series&.downcase
        when "standard", "std", "full-standard" then "std"
        when "informational", "info", "fyi" then "info"
        when "experimental", "exp" then "exp"
        when "bcp" then "bcp"
        when "historic" then "historic"
        else
          "std"
        end
      end

      def xpath_comma(xpath)
        return nil if xpath.empty?

        xpath.map(&:text).join(", ")
      end

      def make_link(out, isoxml)
        links = isoxml
          .xpath(ns("//bibdata/relation[@type = 'includedIn' or " \
                    "@type = 'describedBy' or @type = 'derivedFrom' or " \
                    "@type = 'instanceOf']")) || return
        links.each do |l|
          out.link href: l&.at(ns("./bibitem/docidentifier"))&.text,
                   rel: rel2iana(l["type"])
        end
      end

      def rel2iana(type)
        case type
        when "includedIn" then "item"
        when "describedBy" then "describedby"
        when "derivedFrom" then "convertedfrom"
        when "instanceOf" then "alternate"
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
          bibliography isoxml, back
          annex isoxml, back
        end
      end

      def clause_parse_title(_node, div, clause, _out, _heading_attrs = {})
        return unless clause

        div.name do |n|
          clause&.children&.each { |c2| parse(c2, n) }
        end
      end

      def clause_parse(node, out)
        return if node.at(ns(".//references"))

        out.section **attr_code(
          anchor: node["id"], numbered: node["numbered"],
          removeInRFC: node["removeInRFC"], toc: node["toc"]
        ) do |div|
          clause_parse_title(node, div, node.at(ns("./title")), out)
          node.children.reject { |c1| c1.name == "title" }.each do |c1|
            parse(c1, div)
          end
        end
      end

      def clause(isoxml, out)
        isoxml.xpath("//xmlns:preface/child::*" \
                     "[not(name() = 'abstract' or name() = 'foreword')] " \
                     "| //xmlns:sections/child::*").each do |c|
          # cdup = c.dup
          # cdup.xpath(ns(".//references")).each { |r| r.remove }
          # cdup.at("./*[local-name() != 'title'][normalize-space(text()) != '']") or next
          clause_parse(c, out)
        end
      end

      def annex(isoxml, out)
        isoxml.xpath(ns("//annex")).each do |c|
          clause_parse(c, out)
        end
      end
    end
  end
end
