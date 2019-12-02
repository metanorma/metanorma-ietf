require "isodoc"

module IsoDoc
  module Ietf
    class  Metadata < IsoDoc::Metadata
      def title(isoxml, _out)
        t =  isoxml.at(ns("//bibdata//title[@type='main' and @language='en']")) and
          set(:doctitle, t.text)
        t =  isoxml.at(ns("//bibdata//title[@type='abbrev' and @language='en']")) and
          set(:docabbrev, t.text)
        t =  isoxml.at(ns("//bibdata//title[@type='ascii' and @language='en']")) and
          set(:docascii, t.text)
      end

      def relaton_relations
        %w(included-in described-by derived-from equivalent)
        # = item describedby convertedfrom alternate
      end

      def keywords(isoxml, _out)
        ret = []
        isoxml.xpath(ns("//bibdata/keyword")).each do |kw|
          ret << kw.text
        end
        set(:keywords, ret)
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
        set(:docnumber, dn&.text&.sub(/^rfc-/, "")&.sub(/\.[a-z0-9]+$/i, ""))
      end

      def author(xml, _out)
        super
        wg(xml)
      end

       def wg(xml)
         workgroups = []
         xml.xpath(ns("//bibdata/ext/editorialgroup/workgroup")).each do |wg|
           workgroups << wg.text
        end
         set(:wg, workgroups)
      end
    end
  end
end
