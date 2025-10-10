require "isodoc"

module IsoDoc
  module Ietf
    class Metadata < IsoDoc::Metadata
      TITLE_RFC = "//bibdata//title[@type='main' and @language='en']".freeze

      def title(isoxml, _out)
        t =  isoxml.at(ns(TITLE_RFC)) and
          set(:doctitle, t.text)
        t =  isoxml.at(ns(TITLE_RFC.sub(/main/, "abbrev"))) and
          set(:docabbrev, t.text)
        t =  isoxml.at(ns(TITLE_RFC.sub(/main/, "ascii"))) and
          set(:docascii, t.text)
      end

      def relaton_relations
        %w(included-in described-by derived-from instance-of)
        # = item describedby convertedfrom alternate
      end

      def areas(isoxml, _out)
        ret = []
        isoxml.xpath(ns("//bibdata/ext/area")).each do |kw|
          ret << kw.text
        end
        set(:areas, ret)
      end

      def docid(isoxml, _out)
        dn = isoxml.at(ns("//bibdata/docnumber"))
        set(:docnumber, dn&.text&.strip&.sub(/^rfc-/, "")
          &.sub(/\.[a-z0-9]+$/i, ""))
      end

      def author(xml, _out)
        super
        wg(xml)
      end

      def wg(xml)
        workgroups = []
        xml.xpath(ns("//bibdata/contributor[role/description = 'committee']/" \
          "organization/subdivision[@type = 'Workgroup']/name")).each do |wg|
          workgroups << wg.text
        end
        set(:wg, workgroups)
      end

      def doctype(isoxml, _out)
        super
        set(:doctype, "RFC") if get[:doctype].nil?
      end

      def initialize(lang, script, locale, i18n, fonts_options = {})
        super
        @metadata[:publisheddate] = nil
        @metadata[:circulateddate] = nil
      end
    end
  end
end
