# frozen_string_literal: true

module Metanorma
  module Ietf
    module Transformer
      module MetadataTransformer
        SERIES2CATEGORY = {
          "standard" => "std", "std" => "std", "full-standard" => "std",
          "informational" => "info", "info" => "info", "fyi" => "info",
          "experimental" => "exp", "exp" => "exp",
          "bcp" => "bcp", "historic" => "historic",
        }.freeze

        private

        def ietf_ext
          @ietf_ext ||= bibdata.ext
        end

        def set_rfc_attributes(rfc)
          rfc.version = "3"
          rfc.submission_type = extract_submission_type
          consensus = extract_consensus
          rfc.consensus = consensus unless consensus == "false"
          rfc.category = extract_category
          rfc.ipr = ietf_ext.ipr || "trust200902"
          rfc.number = docnumber if rfc?
          rfc.doc_name = extract_doc_name unless rfc?
          rfc.obsoletes = extract_relation_ids("obsoletes")
          rfc.updates = extract_relation_ids("updates")
          rfc.lang = lang
          rfc.pi_settings = extract_pi_settings
        end

        PI_ORDER = %w[sortrefs symrefs tocdepth subcompact compact strict
                       notedraftinprogress comments].freeze

        PI_DEFAULTS = {
          "strict" => "yes",
          "compact" => "yes",
          "subcompact" => "no",
          "tocdepth" => "4",
          "symrefs" => "yes",
          "sortrefs" => "yes",
        }.freeze

        def extract_pi_settings
          pi = ietf_ext.pi

          settings = {}
          PI_ORDER.each do |key|
            val = pi ? pi.public_send(key) : nil
            val = nil if val&.empty?
            settings[key] = val if val
          end

          PI_DEFAULTS.each do |key, default|
            next if settings.key?(key)
            settings[key] = default
          end

          # Re-sort to maintain PI_ORDER sequence
          sorted = {}
          PI_ORDER.each { |k| sorted[k] = settings[k] if settings.key?(k) }
          sorted.empty? ? nil : sorted
        end

        def pi_settings
          ietf_ext.pi
        end

        def extract_submission_type
          bibdata.series.each do |s|
            next unless s.type == "stream"
            return ls_text(s.title) if ls_text(s.title)
          end
          ietf_ext.submission_type || "IETF"
        end

        def extract_consensus
          ietf_ext.consensus || "false"
        end

        def extract_category
          bibdata.series.each do |s|
            next unless s.type == "intended"
            title = ls_text(s.title)
            return SERIES2CATEGORY.fetch(title, "std") if title
          end
          "std"
        end

        def extract_doc_name
          dn = docnumber
          dn&.sub(/\Arfc-/i, "")
        end

        def extract_relation_ids(relation_type)
          ids = []
          bibdata.relation.each do |rel|
            next unless rel.type == relation_type
            next unless rel.bibitem
            doc_ids = rel.bibitem.docidentifier
            doc_ids = [doc_ids] unless doc_ids.is_a?(Array)
            doc_ids.each do |di|
              text = ls_text(di)
              ids << text if text && !text.empty?
            end
          end
          return nil if ids.empty?
          ids.join(", ")
        end

        def build_links
          links = []
          bibdata.relation.each do |rel|
            next unless rel.type == "derivedFrom"
            next unless rel.bibitem
            doc_ids = rel.bibitem.docidentifier
            doc_ids = [doc_ids] unless doc_ids.is_a?(Array)
            doc_ids.each do |di|
              target = ls_text(di)
              next if target.nil? || target.empty?
              link = Rfcxml::V3::Link.new
              link.href = "https://datatracker.ietf.org/doc/draft-#{target.sub(/\Adraft-/, '')}"
              link.rel = "convertedFrom"
              links << link
            end
          end
          links
        end
      end
    end
  end
end
