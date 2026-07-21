# frozen_string_literal: true

require_relative "presentation/converter"

module Metanorma
  module Ietf
    # The IETF presentation-XML stage: an EXTRACTION of the selective use
    # the released lib/isodoc/ietf code made of the shared IsoDoc
    # presentation machinery, not a reimplementation of it.
    #
    # Scope contract (maintainer, 2026-07-21) — this stage is deliberately
    # thin. It owns:
    #   - xref integrity: anchor/id population and IsoDoc::Xref parse
    #     bookkeeping (the @anchors table the released path relied on);
    #   - reference rendering: relaton-render via the shared bibrenderer,
    #     including the no-title/no-formattedref docidentifier fallback
    #     (metanorma-ietf#272, ported at metanorma-ietf@81f7bc1 with a
    #     REFACTOR marker pointing here);
    #   - nothing else. Autonumbering of sections/figures/tables and
    #     internal xref text are xml2rfc's job and are NOT done here.
    #
    # Input: Metanorma Semantic XML. Output: enriched Metanorma XML that
    # Metanorma::IetfDocument::Root.from_xml still consumes unchanged.
    module Presentation
    end
  end
end
