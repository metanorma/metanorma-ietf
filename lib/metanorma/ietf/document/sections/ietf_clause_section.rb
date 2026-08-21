# frozen_string_literal: true

module Metanorma
  module Ietf::Document
    module Sections
      class IetfClauseSection < Metanorma::StandardDocument::Sections::ClauseSection
        # IETF-specific attributes
        attribute :numbered, :string
        attribute :remove_in_rfc, :boolean

        # Recursive IETF sub-clauses
        attribute :clause, IetfClauseSection, collection: true

        xml do
          element "clause"
          ordered

          Metanorma::StandardDocument::SectionXmlMapping.apply_clause_attributes(self)
          map_attribute "numbered",    to: :numbered
          map_attribute "removeInRFC", to: :remove_in_rfc
          Metanorma::StandardDocument::SectionXmlMapping.apply_clause_elements(self)
        end
      end
    end
  end
end