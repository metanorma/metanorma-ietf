# frozen_string_literal: true

require "nokogiri"

module Metanorma
  module Ietf
    module Transformer
      # RFC XML output validation. The content rules and their
      # messages are a transplant of the released path's
      # IsoDoc::Ietf::RfcConvert validation.rb (RFC 7991 section
      # references retained), so downstream consumers see the same
      # warnings; schema validation uses libxml RELAX NG in place of
      # the released Jing (no Java dependency) — same v3.rng, less
      # specific messages. Callers prefix each returned string with
      # "RFC XML: " when warning.
      module ValidationTransformer
        SCHEMA_PATH = File.join(File.dirname(__FILE__), "..", "schema",
                                "v3.rng")

        def validate_rfc_xml(xml_string)
          schema_validate(xml_string) + content_validate(xml_string)
        end

        def schema_validate(xml_string)
          # the IO form keeps the schema's path, so its relative
          # include (SVG-1.2-RFC.rng) resolves; the string form fails
          schema = File.open(SCHEMA_PATH) { |f| Nokogiri::XML::RelaxNG(f) }
          doc = Nokogiri::XML(xml_string)
          schema.validate(doc).map do |error|
            "Line #{format('%06d', error.line)}: #{error.message}"
          end
        rescue StandardError => e
          ["Schema validation failed: #{e.message}"]
        end

        def content_validate(xml_string)
          xml = Nokogiri::XML(xml_string)
          errors = []
          errors += numbered_sections_check(xml)
          errors += toc_sections_check(xml)
          errors += references_check(xml)
          errors += xref_check(xml)
          errors += metadata_check(xml)
          errors
        end

        def section_label(sect)
          sect&.at("./name")&.text ||
            sect["name"] || sect["anchor"]
        end

        # 2.46.2.  "numbered" Attribute
        def numbered_sections_check(xml)
          ret = []
          xml.xpath("//section[@numbered = 'false']").each do |s1|
            ret += numbered_sections_check1(s1)
            ret += numbered_sections_check2(s1)
          end
          ret
        end

        def numbered_sections_check1(section)
          section.xpath("./section[not(@numbered) or @numbered = 'true']")
            .each_with_object([]) do |s2, m|
            m << "Numbered section #{section_label(s2)} under unnumbered " \
                 "section #{section_label(section)}"
          end
        end

        def numbered_sections_check2(section)
          section.xpath("./following-sibling::*[name() = 'section']" \
                        "[not(@numbered) or @numbered = 'true']")
            .each_with_object([]) do |s2, m|
            m << "Numbered section #{section_label(s2)} following " \
                 "unnumbered section #{section_label(section)}"
          end
        end

        # 5.2.7.  Section "toc" attribute
        def toc_sections_check(xml)
          ret = []
          xml.xpath("//section[@toc = 'exclude']").each do |s1|
            s1.xpath(".//section[@toc = 'include']").each do |s2|
              ret << "Section #{section_label(s2)} with toc=include is " \
                     "included in section #{section_label(s1)} with " \
                     "toc=exclude"
            end
          end
          ret
        end

        #  5.4.3  <reference> "target" Insertion
        #  5.4.2.4  "Table of Contents" Insertion
        def references_check(xml)
          ret = []
          xml.xpath("//reference[not(@target)]").each do |s|
            s.xpath(".//seriesInfo[@name = 'RFC' or " \
                    "@name = 'Internet-Draft' or @name = 'DOI']" \
                    "[not(@value)]").each do |s1|
              ret << "for reference #{s['anchor']}, the seriesInfo with " \
                     "name=#{s1['name']} has been given no value"
            end
          end
          xml.xpath("//references | //section").each do |s|
            s.at("./name") or
              ret << "Cannot generate table of contents entry for " \
                     "#{section_label(s)}, as it has no title"
          end
          ret
        end

        # 5.4.8.2.  "derivedContent" Insertion (without Content)
        def xref_check(xml)
          ret = []
          xml.xpath("//xref | //relref").each do |x|
            t = xml.at(".//*[@anchor = '#{x['target']}']") ||
              xml.at(".//*[@pn = '#{x['target']}']") or
              ret << "#{x.name} target #{x['target']} does not exist in " \
                     "the document"
            next unless t

            x.delete("relative") if x["relative"] && x["relative"].empty?
            x.delete("section") if x["section"] && x["section"].empty?
            ret += xref_format_check(x, t)
            ret += xref_section_check(x, t)
          end
          ret
        end

        def xref_format_check(x, t)
          ret = []
          if x["format"] == "title" && t.name == "reference"
            t.at("./front/title") or
              ret << "reference #{t['anchor']} has been referenced by " \
                     "#{x.name} with format=title, but the reference has " \
                     "no title"
          end
          if x["format"] == "counter" && !%w(section table figure li
                                             reference references t
                                             dt).include?(t.name)
            ret << "#{x.to_xml} with format=counter is only allowed for " \
                   "clauses, tables, figures, list entries, definition " \
                   "terms, paragraphs, bibliographies, and bibliographic " \
                   "entries"
          end
          if x["format"] == "counter" && t.name == "reference" &&
              !x["section"]
            ret << "reference #{t['anchor']} has been referenced by xref " \
                   "#{x.to_xml} with format=counter, which requires a " \
                   "section attribute"
          end
          if x["format"] == "counter" && t.name == "li" &&
              t.parent.name != "ol"
            ret << "#{x.to_xml} with format=counter refers to an " \
                   "unnumbered list entry"
          end
          if x["format"] == "title" && %w(u author contact).include?(t.name)
            ret << "#{x.to_xml} with format=title cannot reference a " \
                   "<#{t.name}> element"
          end
          ret
        end

        def xref_section_check(x, t)
          ret = []
          if x["relative"] && !x["section"]
            ret << "#{x.to_xml} with relative attribute requires a " \
                   "section attribute"
          end
          if x["section"] && t.name != "reference"
            ret << "#{x.to_xml} has a section attribute, but " \
                   "#{x['target']} points to a #{t.name}"
          end
          if x["relative"] && t.name != "reference"
            ret << "#{x.to_xml} has a relative attribute, but " \
                   "#{x['target']} points to a #{t.name}"
          end
          rfc_series = t.at(".//seriesInfo[@name = 'RFC' or " \
                            "@name = 'Internet-Draft']")
          if !x["relative"] && x["section"] && !rfc_series
            ret << "#{x.to_xml} must use a relative attribute, since it " \
                   "does not point to a RFC or Internet-Draft reference"
          end
          if x["relative"] && !(rfc_series || t["target"])
            ret << "need an explicit target= URL attribute in the " \
                   "reference pointed to by #{x.to_xml}"
          end
          ret
        end

        def metadata_check(xml)
          ret = []
          ret += link_check(xml)
          ret += series_info_check(xml)
          ret += ipr_check(xml)
          ret
        end

        # 5.6.3.  <link> Processing
        def link_check(xml)
          l = xml&.at("//link[@rel = 'convertedFrom']")&.text
          !l || %r{^https://datatracker\.ietf\.org/doc/draft-}.match(l) or
            return ["<link rel='convertedFrom'> (:derived-from: document " \
                    "attribute) must start with " \
                    "https://datatracker.ietf.org/doc/draft-"]
          []
        end

        # 5.2.2.  "seriesInfo" Insertion
        def series_info_check(xml)
          ret = []
          xml.root["ipr"] == "none" and return []
          rfcinfo = xml.at("//front//seriesInfo[@name = 'RFC']")
          rfcnumber = xml.root["number"]
          rfcinfo && rfcnumber && rfcnumber != rfcinfo["value"] and
            ret << "Mismatch between <rfc number='#{rfcnumber}'> " \
                   "(:docnumber: NUMBER) " \
                   "and <seriesInfo name='RFC' value='#{rfcinfo['value']}'> " \
                   "(:intended-series: TYPE NUMBER)"
          rfcinfo && !/^\d+$/.match(rfcnumber) and
            ret << "RFC identifier <rfc number='#{rfcnumber}'> " \
                   "(:docnumber: NUMBER) must be a number"
          ret
        end

        # RFC 7991 s2.45.5: the legal ipr values. The transplanted
        # /trust200902$/ test matched only the bare lowercase value —
        # every capital-T variant (pre5378Trust200902, ...) and the
        # 200811 family were rejected as unknown (released-parity
        # defect, metanorma-ietf#280; fixed both sides).
        IPR_VALUES = %w(trust200902 noModificationTrust200902
                        noDerivativesTrust200902 pre5378Trust200902
                        trust200811 noModificationTrust200811
                        noDerivativesTrust200811 none).freeze

        # 5.4.2.3.  "Copyright Notice" Insertion
        def ipr_check(xml)
          xml.root["ipr"] or
            return ["Missing ipr attribute on <rfc> element (:ipr:)"]
          IPR_VALUES.include?(xml.root["ipr"]) or
            return ["Unknown ipr attribute on <rfc> element (:ipr:): " \
                    "#{xml.root['ipr']}"]
          []
        end
      end
    end
  end
end
