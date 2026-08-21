# frozen_string_literal: true

module Metanorma
  module Ietf::Document
    module Metadata
      # IETF editorial group containing workgroup names.
      class IetfEditorialGroup < Lutaml::Model::Serializable
        attribute :workgroup, :string, collection: true

        xml do
          element "editorialgroup"
          map_element "workgroup", to: :workgroup
        end
      end
    end
  end
end