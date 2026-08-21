# frozen_string_literal: true

module Metanorma
  module Ietf::Document
    module Sections
      # IETF sections container.
      # Corresponds to ietf.rnc:
      #   sections = element sections {
      #     ( clause | terms | term-clause | definitions | floating-title )+
      #   }
      #
      # Extends StandardDocument sections with loose bibitem references
      # and paragraph elements directly inside sections.
      class IetfSections < Metanorma::StandardDocument::Sections::Sections
        attribute :bibitem,
                  Metanorma::BasicDocument::BibData::BibliographicItem,
                  collection: true
        attribute :p,
                  Metanorma::Document::Components::Paragraphs::ParagraphBlock,
                  collection: true

        xml do
          element "sections"
          ordered

          Metanorma::StandardDocument::SectionXmlMapping.apply_sections_elements(self)
          map_element "bibitem",        to: :bibitem
          map_element "p",              to: :p

          Metanorma::StandardDocument::SectionXmlMapping.apply_sections_attributes(self)
        end
      end
    end
  end
end