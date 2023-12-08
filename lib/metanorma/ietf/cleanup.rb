module Metanorma
  module Ietf
    class Converter < ::Metanorma::Standoc::Converter
      def cleanup(xmldoc)
        bcp14_cleanup(xmldoc)
        abstract_cleanup(xmldoc)
        super
        cref_cleanup(xmldoc)
        xmldoc
      end

      def abstract_cleanup(xmldoc)
        xmldoc.xpath("//abstract[not(text())]").each do |x|
          x.remove
          warn "Empty abstract section removed"
        end
      end

      def cref_cleanup(xmldoc)
        xmldoc.xpath("//crefref").each do |r|
          if c = xmldoc.at("//review[@id = '#{r.text}']")
            r.replace(c.remove)
          else
            @log.add("Crossrefences", r,
                     "No matching review for cref:[#{r.text}]", severity: 1)
          end
        end
      end

      BCP_KEYWORDS = ["MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
                      "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY",
                      "NOT RECOMMENDED", "OPTIONAL"].freeze

      def bcp14_cleanup(xmldoc)
        return unless @bcp_bold

        xmldoc.xpath("//strong").each do |s|
          next unless BCP_KEYWORDS.include?(s.text)

          s.name = "bcp14"
        end
      end

      def smartquotes_cleanup(xmldoc)
        xmldoc.traverse do |n|
          next unless n.text?

          n.replace(HTMLEntities.new.encode(
                      n.text.gsub(/\u2019|\u2018|\u201a|\u201b/, "'")
                      .gsub(/\u201c|\u201d|\u201e|\u201f/, '"')
                      .gsub(/[\u2010-\u2015]/, "-")
                      .gsub(/\u2026/, "...")
                      .gsub(/[\u200b-\u200c]/, "")
                      .gsub(/[\u2000-\u200a]|\u202f|\u205f/, " "),
                      :basic,
                    ))
        end
        xmldoc
      end

      def xref_to_eref(xref, name)
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
            xref_to_eref(x, "source")
          end
        end
      end

      def section_names_refs_cleanup(xml); end

      def note_cleanup(xmldoc); end
    end
  end
end
