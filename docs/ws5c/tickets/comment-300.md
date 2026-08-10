<!-- COMMENT DRAFT for metanorma-ietf#300 (terms). -->
WS5c completeness-audit additions (adjudicated + probe-confirmed 2026-08-08):

- **termnote/termexample block content is dropped** (probe-confirmed): a two-paragraph termnote emits an empty `<aside/>`; a termexample keeps only its "EXAMPLE 1" label — its paragraph and bullet list vanish. The presentation intermediate carries everything; the 0.2.9 model parses these as paragraph-shaped, so the fix is model-blocked (tracked in the model follow-up ticket).
- **term `@anchor` is unmapped at model level** — xrefs targeting terms dangle; same model follow-up.
- Concept carrier ghosts (`@ref`/`@linkmention`; eref/termref children) are also model-blocked; note that the *body-paragraph* concept case turned out to crash the conversion outright and is filed separately.

🤖
