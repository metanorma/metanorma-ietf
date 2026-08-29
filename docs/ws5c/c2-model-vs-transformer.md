# WS5c joint 2 — model accessors vs transformer read-sites (banked 2026-08-08 00:31)
Artifacts: scratchpad/ws5c/{reflect_model.rb, model.json, diff_reads.py, diff.json, diff.txt (full 128-class unread listing), model_coverage_exhaustiveness_spec.rb}.

## Summary
- 207 reachable model classes, 2,089 attributes; 1,283 token-read (upper bound, receiver-blind), 806 definite-unread.
- Unread families: Mml 228 (plurimath-delegated N-A), fmt_* presentation duplicates 94, presentation ids 50, contrib_metadata 29, json_* 20, substantive 385 → triaged.
- Cross-validation: mechanically re-derived the WS5b coverage families (footnote channel #293, SemxElement flattening #292, reqt #299-family A6.12, executivesummary A6.5, org contact A1.2, EXAMPLE_CHILD_ATTRS #297, li/dd/cell gaps #294/#295, SOURCE locality/citeas #300, termref #300, checkbox A4.12, link style→brackets A3.4, keepWithPrevious A2.5) + bucket-A (cref stub channels, Passthrough.formats never referenced).
- Notable N-A parity confirmations (probed against old leg): video/audio/longdesc, variant/floating titles, amend/form, boilerplate no-op, term deprecates/subject, relaton metadata tail, colgroup/summary/valign, PiSettings false alarm (two-line %w scanner artifact — all PI keys ARE read).

## NOVEL
1. **Pseudocode dispatch DEAD GUARD** (HIGH, empirical): figure_transformer.rb:113-114 guards on `method_defined?(:class_attr)` but the model maps @class → :figure_class and defines no class_attr → transform_pseudocode unreachable; `[pseudocode]` figures fall to the generic path which drops intra-figure paragraphs. The suite's own blocks_spec.rb:1168 expects an EMPTY figure — spec has blessed total content loss. Same mechanical class as the :definition_lists dead guard; escaped WS5b (audit a2 rated pseudocode PARTIAL assuming the branch runs).
2. **TermDefinition.nonverbalrepresentation never read** (MEDIUM-HIGH, code-read): term definitions that are figures/formulae/sourcecode emit empty/verbal-only; released leg's generic walk rendered them. Not covered by WS5b T8.
3. **VersionInfo.revision_date/draft + BibliographicDate.to unread** (LOW): probably parity; flagged for a cheap probe only.

## Exhaustiveness spec (durable deliverable)
Prototype model_coverage_exhaustiveness_spec.rb (intended spec/model_coverage_spec.rb): (1) coverage assertion — every reachable attribute read OR on a reasoned IGNORED list (fixing a WS5b theme = deleting its IGNORED entry); (2) DEAD-GUARD DETECTOR — every respond_to?/method_defined? accessor name must exist on a reachable class; would have mechanically caught BOTH the :definition_lists and :class_attr dead guards, and turns future model-vintage renames into CI failures.

Disposition proposal at synthesis: NOVEL-1 pseudocode → new ticket (or extend #296) — it's a port regression with a spec receipt; NOVEL-2 nonverbal terms → extend #300 or new ticket after probe; NOVEL-3 → probe only; exhaustiveness spec → land with the fix wave.

## USER RULING (2026-08-08 00:36) — adjudication-first, not fix-first
Some drops were arguably necessary: NOVEL-2 (nonverbal term definitions) POSSIBLY deliberate omission — HOLD for careful review, do not pre-classify as defect. NOVEL-3 (bibdata version/draft, date-range .to) — user "pretty sure had to be dodged": treat as DELIBERATE, record rationale at review, no probe-to-file. All WS5c discrepancies get careful user review before any ticket/fix; only NOVEL-1 (pseudocode dead guard) currently stands as a clear port regression, and even it goes through the review. Synthesis must present every NOVEL with a deliberate-omission column, not a fix recommendation.
