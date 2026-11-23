require "metanorma/ietf/data/workgroups"
require "metanorma-utils"

module Metanorma
  module Ietf
    class Validate < ::Metanorma::Standoc::Validate
      def copied_instance_variables
        super + %i[workgroups]
      end

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
          @log.add("IETF_2", nil)
      end

      def image_validate(doc)
        doc.xpath("//image").each do |i|
          i["mimetype"] == "image/svg+xml" and next
          @log.add("IETF_3", i, params: [i["src"][0, 40]])
        end
      end

      def workgroup_validate(doc)
        @workgroups.empty? and return
        doc.xpath("//bibdata/contributor[role/description = 'committee']/" \
          "organization/subdivision[@type = 'Workgroup']/name").each do |wg|
          wg_norm = wg.text.sub(/ (Working|Research) Group$/, "")
          @workgroups.include?(wg_norm) and next
          @log.add("IETF_4", nil, params: [wg.text])
        end
      end

      def schema_file
        "ietf.rng"
      end
    end

    # RFC XML emission validation for the processor's document-model
    # leg, in the Metanorma::Standoc::Validate shape: findings are
    # recorded through Metanorma::Utils::Log against the flavor
    # catalog (severity 0 aborts the compile), the full report is
    # rendered to the standard .err.html artifact, and the submitted
    # filename hint is logged as info.
    class RfcValidate
      def initialize
        @log = Metanorma::Utils::Log.new(Converter::IETF_LOG_MESSAGES)
      end

      # Returns the abort entries (clean_abort wording). doc is the
      # input metanorma-document model, for findings that need the
      # authored value (the Rfcxml model default is indistinguishable
      # from an authored one through the plain accessor)
      def content_validate(rfc, doc = nil)
        Transformer::ModelValidation.validate(rfc, doc)
          .each do |id, params|
          @log.add(id, nil, params: params)
        end
        @log.abort_messages
      end

      def content_warnings(rfc)
        Transformer::ModelValidation.warnings(rfc).each do |id, params|
          @log.add(id, nil, params: params)
        end
      end

      # idnits3 FILENAME_DOCNAME_MISMATCH / FILENAME_TOO_MANY_DOTS
      # apply to the submitted file, which Datatracker requires to be
      # named after the draft; our build artifact keeps the source
      # base name
      def record_filename_hint(doc_name)
        doc_name or return
        @log.add("IETF_21", nil, params: [doc_name])
      end

      def fatal?
        !@log.abort_messages.empty?
      end

      def entries?
        !@log.messages.empty?
      end

      def write(filename)
        @log.save_to(filename)
        @log.write
        # the same name save_to computes for the report
        File.join(File.dirname(filename),
                  "#{File.basename(filename, '.*')}.err.html")
      end
    end
  end
end
