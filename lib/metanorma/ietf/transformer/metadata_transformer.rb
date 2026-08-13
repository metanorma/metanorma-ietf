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


        def ietf_ext
          @ietf_ext ||= bibdata.ext || NullObjects::NullExt.new
        end

        def set_rfc_attributes(rfc)
          rfc.version = "3"
          rfc.submission_type = extract_submission_type
          # emitted verbatim, including "false" (WS3, metadata_spec) —
          # EXCEPT for the independent stream, where xml2rfc rejects
          # any consensus setting ("Expected no consensus setting for
          # independent stream"); the released path emits it there too
          # and collects the error (WS2 antioch old-path nit)
          if ietf_ext.consensus &&
              !extract_submission_type.to_s.casecmp?("independent")
            rfc.consensus = ietf_ext.consensus
          end
          rfc.category = extract_category
          rfc.ipr = ietf_ext.ipr || "trust200902"
          rfc.number = docnumber if rfc?
          rfc.doc_name = extract_doc_name unless rfc?
          rfc.obsoletes = extract_relation_ids("obsoletes")
          rfc.updates = extract_relation_ids("updates")
          rfc.lang = lang
          rfc.pi_settings = extract_pi_settings
          set_rfc_attribute_channel(rfc)
        end

        # The v3 root-attribute channel (F5): values recovered from
        # bibdata/ext by Transformer.recover_rfc_attributes — the
        # model ghosts them. Emitted only when the author set them,
        # like the released section.rb.
        def set_rfc_attribute_channel(rfc)
          doc.respond_to?(:recovered_rfc_attributes) or return
          vals = doc.recovered_rfc_attributes
          rfc.sym_refs = vals["symRefs"] if vals["symRefs"]
          rfc.toc_include = vals["tocInclude"] if vals["tocInclude"]
          rfc.sort_refs = vals["sortRefs"] if vals["sortRefs"]
          # #299: the F5 trio's siblings (xml2rfc v3 ignores the PI
          # channel, so these root attributes are the only carriers)
          rfc.toc_depth = vals["tocDepth"] if vals["tocDepth"]
          rfc.index_include = vals["indexInclude"] if vals["indexInclude"]
          rfc.ipr_extract = vals["iprExtract"] if vals["iprExtract"]
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
          series_list = bibdata.series
          if series_list
            series_list = [series_list] unless series_list.is_a?(Array)
            series_list.each do |s|
              next unless s.type == "stream"
              return ls_text(s.title) if ls_text(s.title)
            end
          end
          ietf_ext.submission_type || "IETF"
        end

        def extract_consensus
          ietf_ext.consensus || "false"
        end

        def extract_category
          series_list = bibdata.series
          if series_list
            series_list = [series_list] unless series_list.is_a?(Array)
            series_list.each do |s|
              next unless s.type == "intended"
              title = ls_text(s.title)
              return SERIES2CATEGORY.fetch(title.downcase, "std") if title
            end
          end
          "std"
        end

        def extract_doc_name
          docnumber
        end

        def extract_relation_ids(relation_type)
          ids = []
          relations = bibdata.relation
          return nil unless relations
          relations = [relations] unless relations.is_a?(Array)
          relations.each do |rel|
            next unless rel.type == relation_type
            next unless rel.bibitem
            to_array(rel.bibitem.docidentifier).each do |di|
              # presentation adds scoped display forms (scope="biblio-tag");
              # the rendered attribute takes unscoped docids only, as the
              # released path does (docidentifier[not(@scope)])
              next if di.respond_to?(:scope) && di.scope
              text = ls_text(di)
              ids << text if text && !text.empty?
            end
          end
          return nil if ids.empty?
          ids.join(", ")
        end

        # the released path's relation → <link> mapping
        # (section.rb#make_link/rel2iana): raw first-docidentifier
        # href, IANA rel values (WS3, metadata_spec — the previous
        # derivedFrom-only datatracker-prefixed form emitted one link
        # per docidentifier form)
        REL2IANA = {
          "includedIn" => "item",
          "included-in" => "item",
          "describedBy" => "describedby",
          "described-by" => "describedby",
          "derivedFrom" => "convertedfrom",
          "derived-from" => "convertedfrom",
          "instanceOf" => "alternate",
          "instance-of" => "alternate",
        }.freeze

        def build_links
          links = []
          to_array(bibdata.relation).each do |rel|
            iana = REL2IANA[rel.type] or next
            next unless rel.bibitem

            di = to_array(rel.bibitem.docidentifier).find do |d|
              !d.respond_to?(:scope) || d.scope.to_s != "biblio-tag"
            end
            target = di && ls_text(di)
            next if target.nil? || target.empty?

            link = Rfcxml::V3::Link.new
            link.href = target
            link.rel = iana
            links << link
          end
          links
        end
      end
    end
  end
end
