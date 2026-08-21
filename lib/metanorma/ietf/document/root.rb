# frozen_string_literal: true

module Metanorma
  module Ietf::Document
    class Root < Lutaml::Model::Serializable
      include Metanorma::StandardDocument::RootAttributes

      def self.lutaml_default_register
        :ietf_document
      end

      attribute :bibdata,
                Metanorma::Ietf::Document::Metadata::IetfBibliographicItem
      attribute :preface,
                Metanorma::StandardDocument::Sections::Preface
      attribute :sections,
                Metanorma::Ietf::Document::Sections::IetfSections
      attribute :annex,
                Metanorma::Ietf::Document::Sections::IetfAnnexSection,
                collection: true

      xml do
        element "metanorma"
        namespace Metanorma::StandardDocument::Namespace

        Metanorma::StandardDocument::RootXmlMapping.apply(self)
      end
    end
  end
end