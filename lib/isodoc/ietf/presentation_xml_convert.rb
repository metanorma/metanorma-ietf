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

      # PASS KILL (evidence: default-ON suite run, 2026-07-24): the
      # shared layer rewrites reference docidentifier content to
      # display form (type prefix + esc/semx wrapping); the model-side
      # unknown-element drop then reduces them to bare type names
      # ("DOI", "ISO/IEC"), destroying the raw values. Every
      # transformer consumer of docidentifier (seriesInfo mapping,
      # refcontent, anchors, obsoletes/updates) needs the raw value;
      # none needs the display form. The pass is switched off.
      def docid_prefixes(docxml); end

      # PASS KILL (evidence: antioch fixture spec, default-ON run,
      # 2026-07-24): the shared layer harvests inline <index> terms
      # into an indexsect (or strips them), removing them from the
      # running text. RFC XML has its own index construct — the
      # transformer maps <index> to <iref> in place — so the harvest
      # destroys the transformer's source. The pass is switched off;
      # <index> elements survive to the transformer.
      def index(docxml); end
    end
  end
end
