# frozen_string_literal: true

module Metanorma
  module Ietf::Document
    module Metadata
      class PiSettings < Lutaml::Model::Serializable
        attribute :toc, :string
        attribute :tocdepth, :string
        attribute :symrefs, :string
        attribute :sortrefs, :string
        attribute :compact, :string
        attribute :subcompact, :string
        attribute :strict, :string
        attribute :comments, :string
        attribute :notedraftinprogress, :string

        xml do
          element "pi"
          map_element "toc", to: :toc
          map_element "tocdepth", to: :tocdepth
          map_element "symrefs", to: :symrefs
          map_element "sortrefs", to: :sortrefs
          map_element "compact", to: :compact
          map_element "subcompact", to: :subcompact
          map_element "strict", to: :strict
          map_element "comments", to: :comments
          map_element "notedraftinprogress", to: :notedraftinprogress
        end
      end
    end
  end
end
