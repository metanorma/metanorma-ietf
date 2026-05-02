# frozen_string_literal: true

require "nokogiri"

module Metanorma
  module Ietf
    module Transformer
      module ValidationTransformer
        SCHEMA_PATH = File.join(File.dirname(__FILE__), "..", "..", "..", "..", "isodoc", "ietf", "v3.rng")

        def validate_rfc_xml(xml_string)
          errors = schema_validate(xml_string)
          errors += content_validate(xml_string)
          errors
        end

        private

        def schema_validate(xml_string)
          schema_content = File.read(SCHEMA_PATH)
          schema = Nokogiri::XML::Schema(schema_content)
          doc = Nokogiri::XML(xml_string)

          errors = []
          schema.validate(doc).each do |error|
            errors << "Schema: Line #{error.line}: #{error.message}"
          end
          errors
        rescue StandardError => e
          ["Schema validation failed: #{e.message}"]
        end

        def content_validate(xml_string)
          doc = Nokogiri::XML(xml_string)
          errors = []
          errors += numbered_sections_check(doc)
          errors += toc_sections_check(doc)
          errors += references_check(doc)
          errors += xref_check(doc)
          errors += ipr_check(doc)
          errors
        end

        def numbered_sections_check(doc)
          errors = []
          doc.xpath("//section[@numbered = 'false']").each do |s1|
            s1.xpath("./section[not(@numbered) or @numbered = 'true']").each do |s2|
              errors << "Numbered section '#{section_label(s2)}' under unnumbered section '#{section_label(s1)}'"
            end
            s1.xpath("./following-sibling::section[not(@numbered) or @numbered = 'true']").each do |s2|
              errors << "Numbered section '#{section_label(s2)}' following unnumbered section '#{section_label(s1)}'"
            end
          end
          errors
        end

        def toc_sections_check(doc)
          errors = []
          doc.xpath("//section[@toc = 'exclude']").each do |s1|
            s1.xpath(".//section[@toc = 'include']").each do |s2|
              errors << "Section '#{section_label(s2)}' with toc=include inside '#{section_label(s1)}' with toc=exclude"
            end
          end
          errors
        end

        def references_check(doc)
          errors = []
          doc.xpath("//reference[not(@target)]").each do |s|
            s.xpath(".//seriesInfo[@name = 'RFC' or @name = 'Internet-Draft' or @name = 'DOI'][not(@value)]").each do |s1|
              errors << "Reference #{s['anchor']}: seriesInfo name=#{s1['name']} has no value"
            end
          end
          doc.xpath("//references | //section").each do |s|
            unless s.at("./name")
              errors << "Cannot generate TOC entry for #{section_label(s)}: no title"
            end
          end
          errors
        end

        def xref_check(doc)
          errors = []
          doc.xpath("//xref | //relref").each do |x|
            target = doc.at("//*[@anchor = '#{x['target']}']") || doc.at("//*[@pn = '#{x['target']}']")
            unless target
              errors << "#{x.name} target '#{x['target']}' does not exist"
              next
            end

            if x["relative"] && x["relative"].to_s.empty?
              x.delete("relative")
            end
            if x["section"] && x["section"].to_s.empty?
              x.delete("section")
            end

            if x["relative"] && !x["section"]
              errors << "#{x.name} with relative attribute requires a section attribute"
            end

            if x["section"] && target["name"] != "reference"
              errors << "#{x.name} has section attribute but target '#{x['target']}' is not a reference"
            end
          end
          errors
        end

        def ipr_check(doc)
          errors = []
          ipr = doc.root&.[]("ipr")
          if ipr.nil? || ipr.empty?
            errors << "Missing ipr attribute on <rfc> element"
          elsif !ipr.end_with?("trust200902")
            errors << "Unknown ipr attribute: #{ipr}"
          end
          errors
        end

        def section_label(sect)
          sect.at("./name")&.text || sect["anchor"] || "(unnamed)"
        end
      end
    end
  end
end
