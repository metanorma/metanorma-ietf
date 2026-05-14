# frozen_string_literal: true

module Metanorma
  module Ietf
    module Transformer
      module RfcV3ToIetf
        # Post-processing cleanup for the reverse transformer.
        # Walks the built Metanorma model tree to fix structural issues
        # and normalize content.
        module CleanupTransformer
          private

          def cleanup_reverse(root)
            normalize_empty_collections(root)
            connect_contributors(root)
            root
          end

          # Ensure all collection attributes are proper arrays, not nil
          def normalize_empty_collections(root)
            normalize_bibdata(root.bibdata) if root.bibdata
            normalize_sections(root.sections) if root.sections
            normalize_preface(root.preface) if root.preface
          end

          def normalize_bibdata(bibdata)
            bibdata.docidentifier = [] unless bibdata.docidentifier.is_a?(Array)
            bibdata.title = [] unless bibdata.title.is_a?(Array)
            bibdata.date = [] unless bibdata.date.is_a?(Array)
            bibdata.relation = [] unless bibdata.relation.is_a?(Array)
            bibdata.contributor = [] unless bibdata.contributor.is_a?(Array)
          end

          def normalize_sections(sections)
            return unless sections

            to_array(sections.clause).each do |clause|
              normalize_clause(clause)
            end
          end

          def normalize_clause(clause)
            return unless clause

            normalize_clause_collections(clause)
            to_array(clause.clause).each { |c| normalize_clause(c) }
          end

          def normalize_clause_collections(clause)
            %i[
              paragraphs unordered_lists ordered_lists tables figures
              notes sourcecode_blocks quote_blocks definition_lists
            ].each do |attr|
              val = clause.public_send(attr)
              clause.public_send(:"#{attr}=", []) unless val.is_a?(Array)
            end
          end

          def normalize_preface(preface)
            return unless preface

            preface.clause = [] unless preface.clause.is_a?(Array)
          end

          # Wire contributors from RFC front into bibdata
          def connect_contributors(root)
            return unless root.bibdata && rfc.front

            contributors = build_contributors_from_front(rfc.front)
            root.bibdata.contributor = contributors unless contributors.empty?
          end
        end
      end
    end
  end
end
