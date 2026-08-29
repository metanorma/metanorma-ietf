<!-- TICKET DRAFT 18 (WS5c model-blocked consolidation). Repo: metanorma/metanorma-document. Assignee: ronaldtse. -->
<!-- Title: IETF document model: mapping gaps found by the WS5c completeness audit -->
<!-- SEPARATE COMMENT to post immediately after creation (user-dictated, same as the five stalled tickets):
     Holding up the metanorma-ietf model-driven transformer — parent tracking issue: metanorma/metanorma-ietf#233. -->

Refs https://github.com/metanorma/metanorma-ietf/issues/291

The WS5c grammar-conjunction audit (isodoc/basicdoc grammar vs the 0.2.9 model mappings; method in the metanorma-ietf qa-plan §WS5c) surfaced mapping gaps that block transformer-side fixes. Distinct from the existing #37–#44 set; grouped here as one follow-up:

1. **`@anchor` unmapped** on td/th/tr, fn, term, name/title, variant-title, dd, definition, image, annotation, pre, span — any xref targeting these dangles in output. (td/th/tr and term are the realistic authoring targets.)
2. **termnote/termexample parse as paragraph-shaped**, dropping block children (probe-confirmed: a two-paragraph termnote emits an empty aside; a termexample keeps only its label — the list and paragraphs vanish).
3. **Inline `date` + `fmt-date` both unmapped in body content** — inline dates vanish entirely; two fix routes need the mapping first (consume fmt-date's rendered text; value-fallback for format-less dates).
4. **`bibitem/@hidden` (and `@suppress_identifier`) unmapped** on the parsed bibliographic class — makes the transformer's `hidden_bibitem?` guard structurally dead (metanorma-ietf#301 is model-blocked on this).
5. **`erefstack` unmapped** (element and as child of related/concept) — metanorma-ietf ticket pending for the render side.
6. **`concept` semantic carriers unmapped** (`@ref`/`@linkmention`/`@linkref`/`@bold`/`@ital`; children eref/erefstack/termref) — concepts sourced from external references or termbases have no model data to render from.

(Non-verbal term representations were probe-confirmed as dropped but adjudicated a deliberate omission by the maintainer — deliberately not included here.)

🤖
