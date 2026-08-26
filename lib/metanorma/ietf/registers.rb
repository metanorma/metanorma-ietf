# frozen_string_literal: true

require "lutaml/model"

module Metanorma
  module Ietf
    # ietf's lutaml-model register: type substitutions from standoc.
    # Formerly Metanorma::Registers::Setup.setup_ietf_register in metanorma-document.
    module Registers
      module_function

      def setup
          sd = Metanorma::StandardDocument
          reg = Lutaml::Model::Register.new(:ietf_document)
          Lutaml::Model::GlobalRegister.register(reg)

          reg.register_global_type_substitution(
            from_type: sd::Sections::Sections,
            to_type: Metanorma::Ietf::Document::Sections::IetfSections,
          )
          reg.register_global_type_substitution(
            from_type: sd::Sections::ContentSection,
            to_type: Metanorma::Ietf::Document::Sections::IetfContentSection,
          )
          reg.register_global_type_substitution(
            from_type: sd::Sections::ClauseSection,
            to_type: Metanorma::Ietf::Document::Sections::IetfClauseSection,
          )
          reg.register_global_type_substitution(
            from_type: sd::Sections::AnnexSection,
            to_type: Metanorma::Ietf::Document::Sections::IetfAnnexSection,
          )
      end
    end
  end
end
