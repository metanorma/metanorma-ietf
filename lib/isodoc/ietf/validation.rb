require "jing"
require "fileutils"

module IsoDoc
  module Ietf
    class RfcConvert < ::IsoDoc::Convert
      def schema_validate(filename)
        errors = Jing.new(File.join(File.dirname(__FILE__), "v3.rng"))
          .validate(filename)
        errors.each do |error|
          warn "RFC XML: Line #{'%06d' % error[:line]}:#{error[:column]} "\
               "#{error[:message]}"
        end
      rescue Jing::Error => e
        abort "Jing failed with error: #{e}"
      end

      def content_validate(xml, filename)
        err = []
        err += numbered_sections_check(xml)
        err += toc_sections_check(xml)
        err += references_check(xml)
        err += xref_check(xml)
        err += metadata_check(xml)
        return if err.empty?

        FileUtils.mv(filename, "#{filename}.err")
        err.each { |e| warn "RFC XML: #{e}" }
        warn "Cannot continue processing"
      end

      def label(sect)
        sect&.at("./name")&.text ||
          sect["name"] || sect["anchor"]
      end

      # 2.46.2.  "numbered" Attribute
      def numbered_sections_check(xml)
        ret = []
        xml.xpath("//section[@numbered = 'false']").each do |s1|
          s1.xpath("./section[not(@numbered) or @numbered = 'true']")
            .each do |s2|
            ret << "Numbered section #{label(s2)} under unnumbered section "\
                   "#{label(s1)}"
          end
          s1.xpath("./following-sibling::*[name() = 'section']"\
                   "[not(@numbered) or @numbered = 'true']").each do |s2|
            ret << "Numbered section #{label(s2)} following unnumbered "\
                   "section #{label(s1)}"
          end
        end
        ret
      end

      # 5.2.7.  Section "toc" attribute
      def toc_sections_check(xml)
        ret = []
        xml.xpath("//section[@toc = 'exclude']").each do |s1|
          s1.xpath(".//section[@toc = 'include']").each do |s2|
            ret << "Section #{label(s2)} with toc=include is included in "\
                   "section #{label(s1)} with toc=exclude"
          end
        end
        ret
      end

      #  5.4.3  <reference> "target" Insertion
      #  5.4.2.4  "Table of Contents" Insertion
      def references_check(xml)
        ret = []
        xml.xpath("//reference[not(@target)]").each do |s|
          s.xpath(".//seriesInfo[@name = 'RFC' or @name = 'Internet-Draft' "\
                  "or @name = 'DOI'][not(@value)]").each do |s1|
            ret << "for reference #{s['anchor']}, the seriesInfo with "\
                   "name=#{s1['name']} has been given no value"
          end
        end
        xml.xpath("//references | //section").each do |s|
          s.at("./name") or ret << "Cannot generate table of contents entry "\
                                   "for #{label(s)}, as it has no title"
        end
        ret
      end

      # 5.4.8.2.  "derivedContent" Insertion (without Content)
      def xref_check(xml)
        ret = []
        xml.xpath("//xref | //relref").each do |x|
          t = xml.at(".//*[@anchor = '#{x['target']}']") ||
            xml.at(".//*[@pn = '#{x['target']}']") or
            ret << "#{x.name} target #{x['target']} does not exist in the document"
          next unless t

          x.delete("relative") if x["relative"] && x["relative"].empty?
          x.delete("section") if x["section"] && x["section"].empty?
          if x["format"] == "title" && t.name == "reference"
            t.at("./front/title") or
              ret << "reference #{t['anchor']} has been referenced by #{x.name} "\
                     "with format=title, but the reference has no title"
          end
          if x["format"] == "counter" && !%w(section table figure li
                                             reference references t dt).include?(t.name)
            ret << "#{x.to_xml} with format=counter is only allowed for "\
                   "clauses, tables, figures, list entries, definition terms, "\
                   "paragraphs, bibliographies, and bibliographic entries"
          end
          if x["format"] == "counter" && t.name == "reference" && !x["section"]
            ret << "reference #{t['anchor']} has been referenced by xref "\
                   "#{x.to_xml} with format=counter, which requires a "\
                   "section attribute"
          end
          if x["format"] == "counter" && t.name == "li" && t.parent.name != "ol"
            ret << "#{x.to_xml} with format=counter refers to an unnumbered "\
                   "list entry"
          end
          if x["format"] == "title" && %w(u author contact).include?(t.name)
            ret << "#{x.to_xml} with format=title cannot reference a "\
                   "<#{t.name}> element"
          end
          if x["relative"] && !x["section"]
            ret << "#{x.to_xml} with relative attribute requires a section "\
                   "attribute"
          end
          if (x["section"]) && t.name != "reference"
            ret << "#{x.to_xml} has a section attribute, but #{x['target']} "\
                   "points to a #{t.name}"
          end
          if (x["relative"]) && t.name != "reference"
            ret << "#{x.to_xml} has a relative attribute, but #{x['target']} "\
                   "points to a #{t.name}"
          end
          if !x["relative"] && x["section"] && !t.at(".//seriesInfo[@name = 'RFC' or @name = "\
                                                     "'Internet-Draft']")
            ret << "#{x.to_xml} must use a relative attribute, "\
                   "since it does not point to a RFC or Internet-Draft reference"
          end
          if x["relative"] && !(t.at(".//seriesInfo[@name = 'RFC' or @name = "\
                                     "'Internet-Draft']") || t["target"])
            ret << "need an explicit target= URL attribute in the reference "\
                   "pointed to by #{x.to_xml}"
          end
        end
        ret
      end

      def metadata_check(xml)
        ret = []
        ret += link_check(xml)
        ret += seriesInfo_check(xml)
        ret += ipr_check(xml)
        ret
      end

      # 5.6.3.  <link> Processing
      def link_check(xml)
        l = xml&.at("//link[@rel = 'convertedFrom']")&.text
        !l || %r{^https://datatracker\.ietf\.org/doc/draft-}.match(l) or
          return ["<link rel='convertedFrom'> (:derived-from: document "\
                  "attribute) must start with "\
                  "https://datatracker.ietf.org/doc/draft-"]
        []
      end

      # 5.2.2.  "seriesInfo" Insertion
      def seriesInfo_check(xml)
        ret = []
        xml.root["ipr"] == "none" and return []
        rfcinfo = xml.at("//front//seriesInfo[@name = 'RFC']")
        rfcnumber = xml.root["number"]
        rfcinfo && rfcnumber && rfcnumber != rfcinfo["value"] and
          ret << "Mismatch between <rfc number='#{rfcnumber}'> "\
                 "(:docnumber: NUMBER) "\
                 "and <seriesInfo name='RFC' value='#{rfcinfo['value']}'> "\
                 "(:intended-series: TYPE NUMBER)"
        rfcinfo && !/^\d+$/.match(rfcnumber) and
          ret << "RFC identifier <rfc number='#{rfcnumber}'> "\
                 "(:docnumber: NUMBER) must be a number"
        ret
      end

      # 5.4.2.3.  "Copyright Notice" Insertion
      def ipr_check(xml)
        xml.root["ipr"] or
          return ["Missing ipr attribute on <rfc> element (:ipr:)"]
        /trust200902$/.match(xml.root["ipr"]) or
          return ["Unknown ipr attribute on <rfc> element (:ipr:): "\
                  "#{xml.root['ipr']}"]
        []
      end
    end
  end
end
