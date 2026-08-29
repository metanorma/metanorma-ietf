# WS5c synthesis — grammar-conjunction completeness audit (2026-08-08)

Per the user's 2026-08-08 ruling, this synthesis is **adjudication-first**: every NOVEL row carries a "possibly deliberate?" assessment and NOTHING here is a fix recommendation. All dispositions are proposals awaiting the user's careful review.

## Cross-instrument validation

The three joints (c1 grammar→model, c2 model→transformer, c3 transformer→v3) mechanically re-derived essentially the entire WS5b never-emit/coverage ledger — cref, passthrough, `pre`, footnote channel, flattening family, container families, front-matter attribute set, root attributes, reqt family, hidden bibitems, SOURCE locality/citeas — which is strong evidence that both instruments are sound and that WS5b's behavioral findings plus WS5c's mechanical residue now bound the gap space tightly. The prep-tool / deprecated-v2 / no-v3-home tails were classified N-A with per-item rationale (c1/c3 tables).

## NOVEL roster (17 → 12 after merging overlaps), adjudication table

| # | Finding | Joint | Conf. | Port regression? | Possibly deliberate? | Proposed disposition (PENDING user review) |
|---|---|---|---|---|---|---|
| 1 | **Pseudocode dispatch dead guard** (`:class_attr` vs `:figure_class`); suite spec blesses empty figure | c2 | High (empirical + spec receipt) | **Yes** — released leg rendered pseudocode | Unlikely (guard exists; it just can't fire) | Candidate ticket or extend #296; the strongest WS5c catch |
| 2 | **display-text lost wholesale at parse** under semantic xref/eref/source (not mere flattening; authored xref text → auto-label) | c1 | High model / medium e2e | Escalation of known #292 family | Partially (semx side-channel was the intended carrier) | Fold as escalation note into #292; end-to-end probe first |
| 3 | **termnote/termexample parse as ParagraphBlock**, block content lost; contradicts a6 PORTED rating | c1 | Medium (model-empirical; e2e probe needed) | Likely | Possible (term-block restructuring at presentation may mask) | Probe, then extend #300 if it reproduces |
| 4 | **hidden_bibitem? guard structurally dead** (`bibitem@hidden` unmapped on the parsed class) | c1 | High | Already filed as #301 item 1 | No — but fix ROUTE changes | Escalation note on #301: fix is model-blocked (mapping or docidentifier read) |
| 5 | **Anchor ghosts beyond T5**: td/th/tr, fn, term, name/title, dd, definition, image, annotation, pre, span | c1 | High absence / medium incidence | Partially (released carried some) | Partially (many were never xref targets in practice) | Review list item-by-item; likely split KNOWN-extension vs N-A |
| 6 | **concept carriers ghosted** (@bold/@ital/@ref/@linkmention/@linkref; eref/erefstack/termref children) — external-ref/termbase concepts drop links | c1 | Medium-high | Yes (released rendered concept eref) | Possible for the styling attrs | Extend #300 after probe |
| 7 | **artwork/figure @width/@height never emitted** — image sizing lost | c3 | High emit-absence / medium impact | **No** — released never emitted either | Possible (sizing may have been deemed xml2rfc's business) | Enhancement-class; user call whether to file at all |
| 8 | **thead/tbody/tfoot @anchor dropped** | c3 | High / low impact | No (released unverified) | Possible | Fold into #295 or drop as N-A |
| 9 | **TermDefinition.nonverbalrepresentation unread** — figure/formula/sourcecode definitions | c2 | Medium-high | Yes on paper | **HELD — user: possibly deliberate omission** | Await user ruling; no probe-to-file |
| 10 | **VersionInfo.revision_date/draft + BibliographicDate.to unread** | c2 | Low | — | **User: "pretty sure had to be dodged" — treat as DELIBERATE** | Record rationale at review; close |
| 11 | **erefstack fully ghosted** | c1 | High drop / low impact | No (released had no handler) | Likely-tolerable parity | Probably N-A; user confirm |
| 12 | **Minor cluster**: amend family locus/newcontent, inline date@value | c1 | Low-medium | Mixed | Likely for amend (rare in IETF) | Fold into nearest theme or N-A |

## Adjudicated dispositions (2026-08-08, user rulings + probe wave)

Probe verdicts: see probe-verdicts.md. Row 1 → NEW ticket (draft 14). Row 2 → CLOSED (display-text survives end-to-end; semx channel masks the model drop — probe 1). Row 3 → CONFIRMED (probe 2) → #300 comment + model follow-up. Row 4 → escalation carried inside the model follow-up (hidden guard model-blocked). Row 5 → split: td/th/tr → #295, term → #300, remainder → #291 note; all model-blocked. Row 6 → probe 3 found a CONVERSION CRASH (body-paragraph concept, NoMethodError in safe_append) → NEW ticket (draft 17); carrier ghosts → model follow-up. Row 7 → NEW enhancement ticket (draft 16). Row 8 → #295 comment. Row 9 → probe 4 confirmed name-only terms; user ruling 2026-08-08: **DELIBERATE OMISSION — closed** (F6-style; removed from the model follow-up; rationale: non-verbal definition rendering is an accepted drop for the IETF flavor). Row 10 → CLOSED deliberate (rationale recorded). Row 11 → NEW ticket (draft 15), model-blocked. Row 12 → amend CLOSED; inline date reclassified MODEL-BLOCKED (both `date` and `fmt-date` unmapped in body; both-routes fix note) → model follow-up + #291 note.

Model-blocked consolidation → metanorma-document follow-up ticket (draft 18), which per user directive receives a separate comment: "Holding up the metanorma-ietf model-driven transformer — parent tracking issue: metanorma/metanorma-ietf#233."

Draft roster (docs/ws5c/tickets/): 14-pseudocode-dead-guard, 15-erefstack, 16-artwork-sizing, 17-concept-crash, 18-metanorma-document-followup (+ its blocker comment), comment-295, comment-300, comment-291.

## Durable deliverable

`model_coverage_exhaustiveness_spec.rb` (prototype, this directory; intended home `spec/model_coverage_spec.rb`): (1) every reachable model attribute must be read by the transformer or sit on a reasoned IGNORED list; (2) a dead-guard detector — every `respond_to?`/`method_defined?` accessor name must exist on a reachable class. The detector alone would have mechanically caught both dead guards found to date (`:definition_lists`, `:class_attr`). Landing it is proposed as part of the fix wave.

## Template note

WS5c re-runs cheaply: joint 1 is the regression harness for every model upgrade (0.4.x/0.5.x batch); joint 2's spec freezes traversal coverage permanently; joint 3 re-runs when the rfcxml vintage moves. Recorded in qa-plan §WS5c and the port-QA template memory.
