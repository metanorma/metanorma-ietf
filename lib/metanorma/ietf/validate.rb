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
        stream = doc.at("//bibdata/series[@type = 'stream']/title")&.text
        status = doc.at("//bibdata/status/stage")&.text
        stream == "editorial" && status != "informational" and
          @log.add("Document Attributes", nil,
                   "Editorial stream must have Informational status")
      end

      def image_validate(doc)
        doc.xpath("//image").each do |i|
          i["mimetype"] == "image/svg+xml" and next
          @log.add("Images", i, "image #{i['src'][0, 40]} is not SVG!",
                   severity: 1)
        end
      end

      def workgroup_validate(doc)
        @workgroups.empty? and return
        doc.xpath("//bibdata/contributor[role/description = 'committee']/" \
          "organization/subdivision[@type = 'Workgroup']/name").each do |wg|
          wg_norm = wg.text.sub(/ (Working|Research) Group$/, "")
          @workgroups.include?(wg_norm) and next
          @log.add("Document Attributes", nil,
                   "IETF: unrecognised working group #{wg.text}",
                   severity: 1)
        end
      end

      def schema_file
        "ietf.rng"
      end

      def cache_workgroup(_node)
        Metanorma::Ietf::Data::WORKGROUPS
      end
    end
  end
end
