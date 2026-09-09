# frozen_string_literal: true

module Metanorma
  module Ietf
    module Html
      # IETF documents render iso-style: the IETF root, sections, and
      # annex register alongside the shared standoc classes the model
      # uses (exact-class dispatch, OGC pattern).
      class Renderer < Metanorma::Iso::Html::Renderer
        register_render "Metanorma::Ietf::Document::Root", :render_document
        register_render "Metanorma::Ietf::Document::Sections::IetfSections",
                        :render_sections
        register_render "Metanorma::Ietf::Document::Sections::IetfAnnexSection",
                        :render_annex
        register_render "Metanorma::Standoc::Document::Sections::Preface",
                        :render_preface
        register_render "Metanorma::Standoc::Document::Sections::ClauseSection",
                        :render_clause
        register_render "Metanorma::Standoc::Document::Sections::AnnexSection",
                        :render_annex
        register_render "Metanorma::Standoc::Document::Sections::ContentSection",
                        :render_clause
        register_render "Metanorma::Standoc::Document::Sections::TermsSection",
                        :render_terms_section
        register_render "Metanorma::Standoc::Document::Sections::BibliographySection",
                        :render_clause
        register_render "Metanorma::Standoc::Document::Sections::DefinitionSection",
                        :render_clause
      end
    end
  end
end
