<!-- COMMENT DRAFT for metanorma-ietf#291 (tracking). -->
WS5c grammar-conjunction completeness audit — adjudicated dispositions (2026-08-08):

**New tickets filed from the audit:** pseudocode dead-guard; body-concept conversion crash; erefstack rendering; artwork width/height enhancement. **Model-blocked items** are consolidated in a metanorma-document follow-up ticket (anchors family, termnote/termexample block content, inline date/fmt-date, bibitem@hidden, concept carriers, erefstack mapping).

**Recorded as known gaps, no separate tickets** (adjudicated):

- `@anchor` model-mapping ghosts beyond the ticketed set: fn, name/title, variant-title, dd, definition, image, annotation, pre, span — xrefs to these dangle; rides the model follow-up.
- Inline `date`: both the semantic element and its rendered `fmt-date` sibling are unmapped in body content — inline dates vanish entirely. Model-blocked; two fix routes noted in the audit record (consume fmt-date's rendered text; `@value` fallback where format is absent, since the presentation renderer requires both attributes to fire).

**Adjudicated closures:** authored xref/eref display-text survives end-to-end (the presentation fmt-xref/semx channel masks the model-level drop — probe-confirmed, no action); bibdata version/draft and date-range ends deliberately not carried (no v3 carrier; I-D versioning rides the docName); amend-family content (rare in IETF authoring, partly consumed at presentation).

🤖
