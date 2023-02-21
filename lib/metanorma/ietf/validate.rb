require "metanorma/ietf/data/workgroups"
require "metanorma-utils"

module Metanorma
  module Ietf
    class Converter < ::Metanorma::Standoc::Converter
      def content_validate(doc)
        super
        image_validate(doc)
        workgroup_validate(doc)
        submission_validate(doc)
      end

      def ns(path)
        ::Metanorma::Utils::ns(path)
      end

      def submission_validate(doc)
        stream = doc.at(ns("//bibdata/series[@type = 'stream']/title"))&.text
        status = doc.at(ns("//bibdata/status/stage"))&.text
        stream == "editorial" && status != "information" and
          @log.add("Document Attributes",
                   "Editorial stream must have Informational status")
      end

      def image_validate(doc)
        doc.xpath("//image").each do |i|
          next if i["mimetype"] == "image/svg+xml"

          @log.add("MIME", i, "image #{i['src'][0, 40]} is not SVG!")
        end
      end

      def workgroup_validate(doc)
        return if @workgroups.empty?

        doc.xpath("//bibdata/ext/editorialgroup/workgroup").each do |wg|
          wg_norm = wg.text.sub(/ (Working|Research) Group$/, "")
          next if @workgroups.include?(wg_norm)

          @log.add("Document Attributes", nil,
                   "IETF: unrecognised working group #{wg.text}")
        end
      end

      def validate(doc)
        content_validate(doc)
        schema_validate(formattedstr_strip(doc.dup),
                        File.join(File.dirname(__FILE__), "ietf.rng"))
      end

      def cache_workgroup(_node)
        Metanorma::Ietf::Data::WORKGROUPS
      end
    end
  end
end
