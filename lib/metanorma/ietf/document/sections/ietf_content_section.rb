# frozen_string_literal: true

module Metanorma
  module Ietf::Document
    module Sections
      class IetfContentSection < Metanorma::StandardDocument::Sections::ContentSection
        attribute :numbered, :string
        attribute :remove_in_rfc, :boolean

        # Recursive IETF sub-clauses
        attribute :subsection, IetfContentSection, collection: true

        xml do
          element "clause"
          ordered

          Metanorma::StandardDocument::SectionXmlMapping.apply_content_section_attributes(self)
          map_attribute "numbered",       to: :numbered
          map_attribute "removeInRFC",    to: :remove_in_rfc
          Metanorma::StandardDocument::SectionXmlMapping.apply_content_section_elements(self)
        end
      end
    end
  end
end