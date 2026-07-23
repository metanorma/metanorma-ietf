# frozen_string_literal: true

require "isodoc"
require_relative "i18n"
require_relative "xref"
require_relative "../../relaton/render/general"

module IsoDoc
  module Ietf
    # The IETF presentation-XML stage: the genuine shared
    # ::IsoDoc::PresentationXMLConvert, subclassed the same way every
    # other flavour subclasses it — nothing is ported, the shared
    # implementation runs. Pipeline position: Semantic XML → this →
    # Metanorma::IetfDocument::Root.from_xml → Transformer → RFC XML.
    #
    # Pass policy (maintainer, 2026-07-22): a pass survives only if the
    # transformer needs its decision; decisions are preferred in
    # attribute form; fmt-*/semx output is consumed only where a needed
    # decision has no other carrier. Kills are made on evidence (the
    # WS1b overlap-test method), not a priori — they accumulate below
    # as no-op overrides with the evidence cited.
    class PresentationXMLConvert < ::IsoDoc::PresentationXMLConvert
      def i18n_init(lang, script, locale, i18nyaml = nil)
        @i18n = I18n.new(lang, script, locale: locale,
                                       i18nyaml: i18nyaml || @i18nyaml)
      end

      def xref_init(lang, script, _klass, i18n, options)
        @xrefs = Xref.new(lang, script, self, i18n, options)
      end

      # Same construction as the released lib/isodoc/ietf reference
      # rendering (references.rb#bibliography_prep)
      def bibrenderer(options = {})
        ::Relaton::Render::Ietf::General
          .new(options.merge(language: @lang, i18nhash: @i18n.get,
                             config: @relatonrenderconfig))
      end

      # PASS KILL (evidence: antioch + example B-pipeline runs,
      # 2026-07-23): the shared layer relocates the normative
      # references section into //sections, per rendered-document
      # conventions. RFC XML back matter is the transformer's own
      # structure, and the transformer collects references from
      # //bibliography — the relocation orphans every normative
      # reference (dangling IDREFs, xml2rfc-fatal). The decision is
      # not needed downstream; the pass is switched off.
      def move_norm_ref_to_sections(docxml); end
    end
  end
end
