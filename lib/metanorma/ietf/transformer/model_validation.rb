# frozen_string_literal: true

module Metanorma
  module Ietf
    module Transformer
      # RFC XML content checks on the Rfcxml::V3 model. The
      # transformer law is model-driven: content rules walk the model
      # objects, never the serialised XML (only the RelaxNG schema
      # check and the released-path content transplant remain on the
      # XML side). All rules here port idnits3 submission-check
      # findings; they are returned as catalog-id/params pairs for
      # Validate to record through the metanorma log.
      module ModelValidation
        RFC7841_STREAMS = %w(IETF IAB IRTF independent editorial).freeze

        # RFC 7841 s2: the category each stream may carry; source of
        # truth is the xml2rfc boilerplate_rfc_7841.py
        # boilerplate_rfc_status_of_memo table
        RFC7841_STREAM_CATEGORIES = {
          "IETF" => %w(std bcp exp historic info),
          "IAB" => %w(info historic),
          "IRTF" => %w(exp historic info),
          "independent" => %w(exp historic info),
          "editorial" => %w(info),
        }.freeze

        module_function

        def validate(rfc, doc = nil)
          submission_type_findings(rfc, doc) + abstract_findings(rfc)
        end

        def submission_type_findings(rfc, doc = nil)
          ret = []
          ret += submission_type_enum_findings(rfc)
          ret += stream_category_findings(rfc)
          ret += series_info_stream_findings(rfc)
          ret += consensus_findings(rfc, doc)
          ret += ipr_stream_findings(rfc)
          ret += docname_stream_findings(rfc)
          ret
        end

        # idnits3 SUBMISSION_TYPE_INVALID
        def submission_type_enum_findings(rfc)
          st = rfc.submission_type or return []
          RFC7841_STREAMS.include?(st) or
            return [["IETF_5", [st, RFC7841_STREAMS.join(", ")]]]
          []
        end

        def stream_category_findings(rfc)
          st = rfc.submission_type || "IETF"
          cat = rfc.category or return []
          legal = RFC7841_STREAM_CATEGORIES[st] or return []
          legal.include?(cat) or
            return [["IETF_6",
                     [st, legal.join(", "), cat]]]
          []
        end

        # xml2rfc preptool 5.4.2.1: the front seriesInfo stream and
        # the rfc submissionType agree
        def series_info_stream_findings(rfc)
          st = rfc.submission_type || "IETF"
          rfc.front&.series_info.to_a.each do |si|
            si.stream && si.stream != st and
              return [["IETF_7", [si.stream, st]]]
          end
          []
        end

        # xml2rfc preptool 5.4.2.2: the independent and editorial
        # streams take no consensus setting, and the IRTF stream only
        # when the document names a workgroup. The authored consensus
        # comes from the input model's bibdata ext: the Rfcxml model
        # default ("false") is indistinguishable from an authored
        # false through the plain accessor
        def consensus_findings(rfc, doc = nil)
          st = rfc.submission_type || "IETF"
          c = doc ? authored_consensus(doc) : authored_fallback(rfc)
          return [] unless c
          if %w(independent editorial).include?(st)
            return [["IETF_8", [st, c]]]
          end
          if st == "IRTF" && rfc.front&.workgroup.to_a.empty?
            return [["IETF_9", [c]]]
          end
          []
        end

        # the same source the emission reads: bibdata ext consensus
        def authored_consensus(doc)
          ext = doc&.bibdata&.ext and return ext.consensus
          nil
        end

        # without the input model the Rfcxml accessor cannot
        # distinguish an authored false from the model default: only a
        # non-default value counts as authored
        def authored_fallback(rfc)
          c = rfc.consensus
          c == "false" ? nil : c
        end

        # idnits3 FORBIDDEN_IPR_VALUE_FOR_STREAM (RFC 5378 s3.3)
        RESTRICTED_IPR_VALUES = %w(noModificationTrust200902
                                   noDerivativesTrust200902).freeze

        def ipr_stream_findings(rfc)
          return [] if rfc.ipr == "none"
          return [] unless RESTRICTED_IPR_VALUES.include?(rfc.ipr)
          return [] unless stream_of(rfc) == "ietf"

          [["IETF_10", [rfc.ipr]]]
        end

        # idnits3 SUBMISSION_TYPE_MISMATCH: draft-iab-... and
        # draft-irtf-... names imply their stream
        def docname_stream_findings(rfc)
          name = rfc.doc_name or return []
          prefix = name.downcase.match(/\Adraft-([a-z0-9]+)-/)&.captures&.first
          return [] unless %w(iab irtf).include?(prefix)
          return [] if stream_of(rfc) == prefix

          [["IETF_11",
            [name, "#{prefix.upcase}", rfc.submission_type.to_s]]]
        end

        def stream_of(rfc)
          rfc.submission_type&.downcase || "ietf"
        end

        # idnits3 MISSING_ABSTRACT_SECTION: the abstract is required
        # at submission (https://authors.ietf.org/required-content)
        def abstract_findings(rfc)
          a = rfc.front&.abstract or return [["IETF_12", []]]
          a.t.to_a.empty? && a.ol.to_a.empty? && a.ul.to_a.empty? &&
            a.dl.to_a.empty? or return []
          [["IETF_13", []]]
        end

        # idnits3 ARTWORK_TOO_WIDE: xml2rfc's text output is 72
        # columns; <sourcecode> is indented by 3 of them
        TEXT_LINE_WIDTH = 72
        SOURCECODE_INDENT = 3

        def artwork_width_findings(rfc)
          walk(rfc).each_with_object([]) do |node, ret|
            case node
            when Rfcxml::V3::Artwork
              width_findings(node, node.content.to_s, TEXT_LINE_WIDTH, ret)
            when Rfcxml::V3::Sourcecode
              width_findings(node, node.content.to_a.join("\n"),
                             TEXT_LINE_WIDTH - SOURCECODE_INDENT, ret)
            end
          end
        end

        def width_findings(node, content, budget, ret)
          widest = content.to_s.lines.map(&:chomp).map(&:length).max || 0
          widest > budget and
            ret << ["IETF_14", [element_name_of(node), widest.to_s]]
        end

        # idnits3 REFERENCE_NOT_USED. Divergence from idnits3: it
        # counts <xref> targets only, while our flavor renders
        # eref-style citations as <relref>, so both count as uses
        def references_used_findings(rfc)
          anchors = walk(rfc).select { |n| n.is_a?(Rfcxml::V3::Reference) }
            .map(&:anchor).compact.uniq
          return [] if anchors.empty?
          used = walk(rfc)
            .select { |n| n.is_a?(Rfcxml::V3::Xref) || n.is_a?(Rfcxml::V3::Relref) }
            .map(&:target).compact
          anchors.uniq.reject { |a| used.include?(a) }
            .map { |a| ["IETF_15", [a]] }
        end

        # The idnits3 deprecated-attribute/element tables (xml2rfc
        # base.py deprecated_attributes / RFC 7991), keyed by the XML
        # names the mappings emit: emission must never set them
        DEPRECATED_ATTRIBUTES = {
          "artwork" => %w(height width xml:space),
          "figure" => %w(align alt height src suppress-title title width),
          "note" => %w(title),
          "references" => %w(title),
          "section" => %w(title),
          "seriesInfo" => %w(status stream),
          "t" => %w(hangText),
          "texttable" => %w(title),
          "xref" => %w(pageno),
        }.freeze
        DEPRECATED_ELEMENTS = %w(spanx texttable ttcol vspace).freeze

        def deprecated_findings(rfc)
          ret = []
          walk(rfc).each do |node|
            tag = element_name_of(node)
            DEPRECATED_ELEMENTS.include?(tag) and
              ret << ["IETF_17", [tag]]
            dep = DEPRECATED_ATTRIBUTES[tag] or next
            node.class.mappings[:xml].attributes.each do |xml_name, rule|
              next unless dep.include?(xml_name)
              val = node.public_send(rule.to)
              next if val.nil? || val.to_s.empty?
              ret << ["IETF_16",
                      [xml_name, tag, xml_name, val.to_s]]
            end
          end
          ret
        end

        # idnits3 MISSING_AUTHOR_FULLNAME / TOO_MANY_AUTHORS
        def author_findings(rfc)
          ret = []
          authors = rfc.front&.author.to_a
          authors.each do |a|
            a.fullname.to_s.strip.empty? and
              ret << ["IETF_18", []]
          end
          authors.size > 5 and
            ret << ["IETF_19", []]
          ret
        end

        # idnits3 TABS_IN_CODE: tabs break xml2rfc's text alignment
        def tabs_findings(rfc)
          walk(rfc).each_with_object([]) do |node, ret|
            next unless node.is_a?(Rfcxml::V3::Artwork) ||
                        node.is_a?(Rfcxml::V3::Sourcecode)
            content = node.is_a?(Rfcxml::V3::Sourcecode) ? node.content.to_a.join("\n") : node.content.to_s
            content.include?("\t") and
              ret << ["IETF_20", [element_name_of(node)]]
          end
        end

        # Author-content findings that do not abort the compile
        def warnings(rfc)
          artwork_width_findings(rfc) + references_used_findings(rfc) +
            deprecated_findings(rfc) + author_findings(rfc) +
            tabs_findings(rfc)
        end

        # Depth-first walk over every model node, including models
        # nested in collections
        def walk(node, seen = {}.compare_by_identity, &block)
          return to_enum(__method__, node) unless block
          return unless node.is_a?(Lutaml::Model::Serializable)
          return if seen.key?(node)
          seen[node] = true
          block.call(node)
          node.class.attributes.each_value do |attr|
            value = node.public_send(attr.name)
            case value
            when Array then value.each { |v| walk(v, seen, &block) }
            when Lutaml::Model::Serializable then walk(value, seen, &block)
            end
          end
        end

        # The XML element name the mappings emit for this node
        def element_name_of(node)
          node.class.mappings[:xml].element_name
        end
      end
    end
  end
end
