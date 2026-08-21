# frozen_string_literal: true

module Metanorma
  module Ietf::Document
    module Sections
      class IetfAnnexSection < Metanorma::StandardDocument::Sections::AnnexSection
        # IETF-specific attributes
        attribute :numbered, :string
        attribute :remove_in_rfc, :boolean

        # Sub-clauses within IETF annex use IetfClauseSection
        attribute :clause, IetfClauseSection, collection: true

        xml do
          element "annex"
          ordered

          Metanorma::StandardDocument::SectionXmlMapping.apply_annex_attributes(self)
          map_attribute "numbered",    to: :numbered
          map_attribute "removeInRFC", to: :remove_in_rfc
          Metanorma::StandardDocument::SectionXmlMapping.apply_annex_elements(self)
        end
      end
    end
  end
end