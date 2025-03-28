module Metanorma
  module Ietf
    class Converter < ::Metanorma::Standoc::Converter
      def relaton_relations
        %w(included-in described-by derived-from instance-of obsoletes updates)
      end

      def metadata_author(node, xml)
        personal_author(node, xml)
      end

      def default_publisher
        "IETF"
      end

      def org_abbrev
        { "Internet Engineering Task Force" => "IETF" }
      end

      def metadata_series(node, xml)
        xml.series **{ type: "stream" } do |s|
          s.title (node.attr("submission-type") || "IETF")
        end
        a = node.attr("intended-series") and
          xml.series **{ type: "intended" } do |s|
            parts = a.split(/ /)
            s.title parts[0]
            s.number parts[1..-1].join(" ") if parts.size > 1
          end
      end

      def title(node, xml)
        ["en"].each do |lang|
          at = { language: lang, format: "text/plain" }
          xml.title **attr_code(at.merge(type: "main")) do |t|
            t << (::Metanorma::Utils::asciidoc_sub(node.attr("title")) ||
              ::Metanorma::Utils::asciidoc_sub(node.attr("title-en")) ||
              ::Metanorma::Utils::asciidoc_sub(node.attr("doctitle")))
          end
          a = node.attr("abbrev") and
            xml.title a, **attr_code(at.merge(type: "abbrev"))
          a = node.attr("asciititle") and
            xml.title a, **attr_code(at.merge(type: "ascii"))
        end
      end

      def metadata_committee(node, xml)
        node.attr("workgroup") or return
        xml.editorialgroup do |a|
          committee_component("workgroup", node, a)
        end
      end

      def metadata_ext(node, xml)
        super
        x = node.attr("area") and x.split(/,\s*/).each do |a|
          xml.area a
        end
        xml.ipr (node.attr("ipr") || "trust200902")
        x = node.attr("consensus") and xml.consensus (x != "false")
        x = node.attr("index-include") and xml.indexInclude (x != "false")
        x = node.attr("ipr-extract") and xml.iprExtract x
        x = node.attr("sort-refs") and xml.sortRefs (x != "false")
        x = node.attr("sym-refs") and xml.symRefs (x != "false")
        x = node.attr("toc-include") and xml.tocInclude (x != "false")
        x = node.attr("toc-depth") and xml.tocDepth x
        x = node.attr("show-on-front-page") and xml.showOnFrontPage (x != "false")
        xml.pi { |pi| set_pi(node, pi) }
      end

      def set_pi(node, pi)
        rfc_pis = {
          artworkdelimiter: node.attr("artworkdelimiter"),
          artworklines: node.attr("artworklines"),
          authorship: node.attr("authorship"),
          autobreaks: node.attr("autobreaks"),
          background: node.attr("background"),
          colonspace: node.attr("colonspace"),
          comments: node.attr("comments"),
          docmapping: node.attr("docmapping"),
          editing: node.attr("editing"),
          emoticonic: node.attr("emoticonic"),
          footer: node.attr("footer"),
          header: node.attr("header"),
          inline: node.attr("inline"),
          iprnotified: node.attr("iprnotified"),
          linkmailto: node.attr("linkmailto"),
          linefile: node.attr("linefile"),
          notedraftinprogress: node.attr("notedraftinprogress"),
          private: node.attr("private"),
          refparent: node.attr("refparent"),
          rfcedstyle: node.attr("rfcedstyle"),
          slides: node.attr("slides"),
          "text-list-symbols": node.attr("text-list-symbols"),
          tocappendix: node.attr("tocappendix"),
          tocindent: node.attr("tocindent"),
          tocnarrow: node.attr("tocnarrow"),
          tocompact: node.attr("tocompact"),
          topblock: node.attr("topblock"),
          useobject: node.attr("useobject"),
          strict: node.attr("strict"),
          compact: node.attr("compact"),
          subcompact: node.attr("subcompact"),
          tocinclude: node.attr("toc-include") == "false" ? "no" : "yes",
          tocdepth: node.attr("toc-depth"),
          symrefs: node.attr("sym-refs"),
          sortrefs: node.attr("sort-refs"),
        }
        pi_code(rfc_pis, pi)
      end

      def pi_code(rfc_pis, pi)
        rfc_pis.each_pair do |k, v|
          v.nil? and next
          pi.send k.to_s, v
        end
      end
    end
  end
end
