# frozen_string_literal: true

require "metanorma/standoc"
module Metanorma
  module Ietf::Document
    class Root < Lutaml::Model::Serializable
      include Metanorma::Standoc::Document::RootAttributes

      def self.lutaml_default_register
        :ietf_document
      end

      attribute :bibdata,
                Metanorma::Ietf::Document::Metadata::IetfBibliographicItem
      attribute :preface,
                Metanorma::Standoc::Document::Sections::Preface
      attribute :sections,
                Metanorma::Ietf::Document::Sections::IetfSections
      attribute :annex,
                Metanorma::Ietf::Document::Sections::IetfAnnexSection,
                collection: true

      xml do
        element "metanorma"
        namespace Metanorma::Standoc::Document::Namespace

        Metanorma::Standoc::Document::RootXmlMapping.apply(self)
      end
    end
  end
end
