# frozen_string_literal: true

module Metanorma
  module Ietf::Document
    module Metadata
      class IetfBibliographicItem < Metanorma::Document::Components::BibData::BibliographicItem
        attribute :ext, Metanorma::Ietf::Document::Metadata::IetfBibDataExtensionType

        xml do
          element "bibdata"
          map_attribute "type", to: :type_attr
          map_attribute "schema-version", to: :schema_version
          map_element "fetched", to: :fetched
          map_element "title", to: :title
          map_element "formattedref", to: :formatted_ref
          map_element "uri", to: :link
          map_element "docidentifier", to: :docidentifier
          map_element "docnumber", to: :docnumber
          map_element "date", to: :date
          map_element "contributor", to: :contributor
          map_element "edition", to: :edition
          map_element "version", to: :version
          map_element "note", to: :note
          map_element "language", to: :language
          map_element "script", to: :script
          map_element "abstract", to: :abstract
          map_element "status", to: :status
          map_element "copyright", to: :copyright
          map_element "relation", to: :relation
          map_element "series", to: :series
          map_element "medium", to: :medium
          map_element "place", to: :place
          map_element "price", to: :price
          map_element "extent", to: :extent
          map_element "size", to: :size
          map_element "accessLocation", to: :access_location
          map_element "license", to: :license
          map_element "classification", to: :classification
          map_element "keyword", to: :keyword
          map_element "validity", to: :validity
          map_element "ext", to: :ext
          map_attribute "id", to: :id
          map_attribute "anchor", to: :anchor
          map_attribute "semx-id", to: :semx_id
          map_attribute "schema-version", to: :schema_version
          map_element "biblio-tag", to: :biblio_tag
        end
      end
    end
  end
end