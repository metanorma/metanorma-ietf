# frozen_string_literal: true

module Metanorma
  module Ietf::Document
    module Sections
      autoload :IetfSections, "#{__dir__}/sections/ietf_sections"
      autoload :IetfContentSection, "#{__dir__}/sections/ietf_content_section"
      autoload :IetfClauseSection, "#{__dir__}/sections/ietf_clause_section"
      autoload :IetfAnnexSection, "#{__dir__}/sections/ietf_annex_section"
    end
  end
end
