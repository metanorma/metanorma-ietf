# frozen_string_literal: true

module Metanorma
  module Ietf::Document
    module Metadata
      class IetfBibDataExtensionType < Lutaml::Model::Serializable
        attribute :doctype, :string
        attribute :flavor, :string
        attribute :ipr, :string
        attribute :consensus, :string
        attribute :area, :string, collection: true
        attribute :submission_type, :string
        # RFC attribute channel (metanorma-document#43): the camelCase
        # attributes stand beside the legacy <pi> block
        attribute :sym_refs, :string
        attribute :toc_include, :string
        attribute :sort_refs, :string
        attribute :editorial_group, IetfEditorialGroup
        attribute :pi, PiSettings

        xml do
          element "ext"
          map_element "doctype", to: :doctype
          map_element "flavor", to: :flavor
          map_element "ipr", to: :ipr
          map_element "consensus", to: :consensus
          map_element "area", to: :area
          map_element "submissionType", to: :submission_type
          map_element "symRefs", to: :sym_refs
          map_element "tocInclude", to: :toc_include
          map_element "sortRefs", to: :sort_refs
          map_element "editorial-group", to: :editorial_group
          map_element "editorialgroup", to: :editorial_group
          map_element "pi", to: :pi
        end
      end
    end
  end
end
