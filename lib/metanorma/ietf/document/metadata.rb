# frozen_string_literal: true

module Metanorma
  module Ietf::Document
    module Metadata
      autoload :IetfBibDataExtensionType,
               "metanorma/ietf/document/metadata/ietf_bib_data_extension_type"
      autoload :IetfBibliographicItem,
               "metanorma/ietf/document/metadata/ietf_bibliographic_item"
      autoload :IetfEditorialGroup,
               "metanorma/ietf/document/metadata/ietf_editorial_group"
      autoload :PiSettings,
               "metanorma/ietf/document/metadata/pi_settings"
    end
  end
end
