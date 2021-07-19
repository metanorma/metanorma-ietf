module Asciidoctor
  module Ietf
    class Converter < ::Asciidoctor::Standoc::Converter
      def cleanup(xmldoc)
        bcp14_cleanup(xmldoc)
        abstract_cleanup(xmldoc)
        super
        rfc_anchor_cleanup(xmldoc)
      end

      BCP_KEYWORDS =
        ["MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
         "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", "OPTIONAL"].freeze

      def abstract_cleanup(xmldoc)
        xmldoc.xpath("//abstract[not(text())]").each do |x|
          x.remove
          warn "Empty abstract section removed"
        end
      end

      def bcp14_cleanup(xmldoc)
        return unless @bcp_bold

        xmldoc.xpath("//strong").each do |s|
          next unless BCP_KEYWORDS.include?(s.text)

          s.name = "bcp14"
        end
      end

      def rfc_anchor_cleanup(xmldoc)
        map = {}
        xmldoc.xpath("//bibitem[docidentifier/@type = 'rfc-anchor']").each do |b|
          next if b.at("./ancestor::bibdata")

          map[b["id"]] = b.at("./docidentifier[@type = 'rfc-anchor']").text
          b["id"] = b.at("./docidentifier[@type = 'rfc-anchor']").text
        end
        xmldoc.xpath("//eref | //origin").each do |x|
          map[x["bibitemid"]] and x["bibitemid"] = map[x["bibitemid"]]
        end
        xmldoc
      end

      def smartquotes_cleanup(xmldoc)
        xmldoc.traverse do |n|
          next unless n.text?

          n.replace(HTMLEntities.new.encode(
                      n.text.gsub(/\u2019|\u2018|\u201a|\u201b/, "'")
                      .gsub(/\u201c|\u201d|\u201e|\u201f/, '"'), :basic
                    ))
        end
        xmldoc
      end

      def xref_to_eref(xref)
        super
        xref.delete("format")
      end

      def xref_cleanup(xmldoc)
        super
        xmldoc.xpath("//xref").each do |x|
          x.delete("displayFormat")
          x.delete("relative")
        end
      end

      def quotesource_cleanup(xmldoc)
        xmldoc.xpath("//quote/source | //terms/source").each do |x|
          if x["target"]&.match?(URI::DEFAULT_PARSER.make_regexp)
            x["uri"] = x["target"]
            x.delete("target")
          else
            xref_to_eref(x)
          end
        end
      end

      def section_names_refs_cleanup(xml); end
    end
  end
end
