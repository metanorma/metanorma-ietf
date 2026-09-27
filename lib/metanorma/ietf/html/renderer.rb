# frozen_string_literal: true

require "metanorma/iso/html"

module Metanorma
  module Ietf
    # HTML format slice for the flavor: the renderer, registered with
    # the harness from ietf/document.rb. Renders iso-style; the IETF
    # root uses the IETF sections plus shared standoc classes.
    module Html
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

        # RFC documents carry an RFC header (stream, category, date,
        # docidentifier, authors) instead of an ISO standards cover.
        def render_coverpage(doc)
          bibdata = doc.bibdata
          return "" unless bibdata

          render_liquid("_rfc_cover.html.liquid", {
                          "stream" => "Internet Engineering Task Force (IETF)",
                          "category" => extract_doctype(bibdata).to_s,
                          "date" => rfc_date(bibdata).to_s,
                          "docid" => rfc_docid(bibdata).to_s,
                          "title" => cover_title(bibdata, "en").to_s,
                          "authors" => rfc_authors(bibdata),
                        })
        end

        private

        def rfc_docid(bibdata)
          ids = safe_attr(bibdata, :docidentifier)
          return "" unless ids.respond_to?(:each)

          primary = ids.find { |id| id.type.to_s.casecmp("rfc").zero? } ||
                    ids.first
          primary&.id.to_s
        end

        def rfc_date(bibdata)
          date = bibdata.respond_to?(:date) ? bibdata.date : nil
          date.respond_to?(:on) ? date.on.to_s : ""
        end

        def rfc_authors(bibdata)
          contributors = safe_attr(bibdata, :contributor)
          return [] unless contributors.respond_to?(:map)

          contributors.filter_map do |c|
            if c.respond_to?(:person) && c.person&.name&.respond_to?(:completename)
              c.person.name.completename.to_s
            elsif c.respond_to?(:organization) && c.organization&.name
              c.organization.name.to_s
            end
          end.reject(&:empty?)
        end
      end
    end
  end
end
