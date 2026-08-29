# Pre-triage: Keiko's grammar-census hits on the IETF corpus (2026-08-06)

Status: PROVISIONAL — based on Keiko's 2026-08-06 debrief (255 hits, 15 patterns, 7 named families); to be firmed up when Keiko's ticket wave lands with per-pattern instances. No fixes started; adjudication rulings needed where marked.

## The layer this lives at

The census validates the corpus's **semantic XML against the metanorma grammar** — i.e. it audits the **standoc emitter** (`lib/metanorma/ietf/` converter) and corpus authoring. This is a *third surface*, upstream of both legs WS5b covered (presentation→RFC XML, old renderer vs transformer). WS5b says nothing about it either way.

A census hit is by construction just "emitted XML ≠ grammar". Which side is wrong is the adjudication:

- **emitter-bug** → ours (metanorma-ietf converter fix);
- **grammar-gap** → Keiko's governance queue (model-iso / IETF flavor grammar);
- **authoring defect** → corpus (Keiko has already ruled: do NOT fix the documents pre-emptively).

## Pattern-by-pattern provisional read

**Resolution update 2026-08-07:** Keiko's generator-vs-grammar audit settled patterns 1 and 6 — both are metanorma-ietf generator defects, handed over as #289 (`pre` without id: our `literal` override predates base standoc's unconditional id-minting; grammar has required `pre/@id` since basicdoc-models#32, May 2024) and #288 (`pi` modelled all along in relaton-ietf but emitted in the wrong ext slot — rejected purely on position). My provisional reads below ("coordination/eventually-ours" for 1, "grammar-gap" for 6) were both **wrong in the same direction**: I assumed grammar-side novelty where the grammar had been right for over a year and our emitter deviated. Rows kept for the record. Also per Keiko: ~19 further hits clear when model-iso#158/#159 (erefType convergence, ol@type) are actioned on 08-13 — which resolves pattern 2's adjudication in the direction the F3 precedent argued.

| # | Pattern (per Keiko) | Provisional bucket | Rationale |
|---|---|---|---|
| 1 | 198× `pre` missing required `@id` (RequiredId family, cousin of model-iso#153) | ~~coordination, eventually ours~~ **OURS — #289** | The grammar epic is tightening `@id` to required; our emitter predates that and doesn't stamp ids on `pre`. Not a today-bug — an alignment obligation once RequiredId lands. Standoc-level auto-id is the likely fix shape. |
| 2 | `ol/@type` enum rejects v2 format strings (`R%d`) | **adjudication needed** | The grammar-side sibling of the F3/isodoc#832 rendering fix. Either the IETF flavor grammar admits format strings (v2 heritage is legal metanorma-ietf input, and the transformer deliberately passes them through per the F3 ruling), or the emitter normalises them at ingestion. Consistency with the F3 adjudication argues for grammar admission. |
| 3 | 15× `display-text` placement in bibliography contexts | **likely emitter-bug (ours)** | If the emitter is placing a presentation-era element where the semantic grammar forbids it, that's our emission; needs instance inspection. |
| 4 | 9× date-before-docidentifier + 2× contributor ordering in manual bibitems | **authoring, tolerated** | Hand-authored bibitems in heritage docs; grammar enforces element order. Keiko ruled documents untouched — either standoc normalises order on ingestion (small emitter enhancement) or grammar relaxes order. Low stakes. |
| 5 | 8× date-format content | **authoring / relaton normalisation** | Free-text dates in manual bibitems. Same tolerance ruling; note WS5b ticket 09/12 already covers the downstream garbage-year behavior on such input. |
| 6 | 7× `pi` (xml2rfc processing instructions) unmodelled | **grammar-gap (flavor model)** | `//pi/*` is a deliberate, documented metanorma-ietf semantic feature; the flavor grammar simply never modelled it. Belongs in the IETF flavor grammar via Keiko's governance. |
| 7 | 4× empty-ish sections | **authoring, tolerated** | Heritage skeleton docs (skel etc.); harmless. |

## Why "deviations reported as buggy" is expected, not alarming

Keiko's census classifier cannot itself distinguish emitter-bug from grammar-gap — every mismatch is surfaced as a deviation, and the *governance adjudication* assigns fault. Keiko's earlier framing ("overwhelmingly grammar gaps, not authoring defects") and the new "your output deviates" framing are the same dataset viewed from the two ends of that adjudication. The expected outcome distribution from the table above: the bulk (patterns 1, 2, 6) resolves as grammar-side or coordination work on Keiko's queue; the plausible genuinely-ours item is pattern 3 (display-text placement), plus optional emitter normalisation for 4/5.

## Next actions

1. Await Keiko's ticket numbers (promised "cc on the epic"); attach them to this table.
2. Inspect pattern-3 instances (display-text in bibliography) against the emitter — the one candidate for a real metanorma-ietf bug ticket.
3. Where adjudication is needed (pattern 2 especially), the F3 precedent should be cited so grammar and renderer rulings stay consistent.
