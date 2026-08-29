# To Odo, from Garak — WS5b static port audit: method + results (2026-08-06)

A report in two halves: the method, because the editor has directed that this level of auditing become standard for future ports; and the results, because they materially reprice what "behavioral QA passed" means.

## The method (reusable template — lift this for any walker→typed-model port)

Context: the metanorma-ietf transformer epic (PR #257) replaces a Nokogiri-walker renderer with a typed model-to-model transformer. Behavioral QA (output comparison on 2 fixtures → folded spec suite → 21-doc corpus sweep) had reached parity: 10/21 byte-identical, all visible discrepancies adjudicated and fixed. The editor then interpolated **WS5b: a static code-level comparison** of the retired renderer against its replacement, on the thesis that output comparison proves "same answer on these inputs" while code comparison estimates "same capabilities on inputs we haven't got".

The pipeline, per docs/qa-plan.adoc §WS5b:

1. **Inventory both sides** (old at last-released state via `git show origin/main:…`; new on the branch).
2. **Partition into functional areas** pairing old files with new counterparts (we used 7: front matter; blocks; inline/footnotes; lists/tables; references; sections/terms; entry/validation/cleanup).
3. **Per area, one adversarial audit agent** walks EVERY old method, states its observable output behavior, locates the new-leg equivalent, and classifies: PORTED / PARTIAL (named unhandled case) / RELOCATED (moved upstream/downstream) / DROPPED-BY-DESIGN (adjudicated or architecturally dead) / MISSING. Explicitly prime the agents with the already-adjudicated ledger so they verify rather than re-report known items.
4. **Consolidate**: cross-area dedupe, subtract already-ledgered items, group into themes.
5. **Empirical verification wave**: for every significant code-read finding, a verifier agent builds a minimal probe document and runs it through the REAL pipeline, returning CONFIRMED (with output snippet) / REFUTED (with what the audit misread) / BLOCKED. Nothing unverified gets ticketed.
6. **Quantise**: tracking issue + per-theme tickets, each fix carrying specs for the probe shapes — closing the very coverage hole the audit exposed.

Why the audit found what behavioral QA could not: the old renderer was a generic recursive walker that **failed open** (unhandled children still got parsed); the new leg is typed per-tag dispatch that **fails closed** (unmapped tags silently dropped). A port of that shape accumulates a long tail of silent drops precisely in the territory the test corpus doesn't exercise. Treat static audit as mandatory, not garnish, for every such port.

Calibration data for the template: 7 area audits produced 86 raw findings; after dedupe/ledger-subtraction, the verification wave confirmed ~41 empirically, refuted 1 outright (the audit feared object-junk serialization of iref accessors; the model serializes them fine), reclassified 1 (a feared deprecated-`<postamble>` emission turned out to be dead code — the real defect is the content vanishing), and narrowed 1 (an anchor-sanitisation asymmetry bites only `#`-anchors; the presentation stage pre-normalises spaces). So: adversarial priming over-reports by design, and the verification wave is what makes the numbers trustworthy — but the false-alarm rate was far lower than feared. Two audit agents ran probes unprompted; encourage that.

## The results (headline)

Thirteen theme tickets are being filed on metanorma-ietf under a tracking issue (children of the #233 campaign). The heavyweights:

- **Reviewer annotations (cref) are an empty stub** — `build_annotations` returns `[]`; four independent audits converged.
- **Body/inline passthrough is dropped** — presentation XML still carries it; the transformer consumes passthrough only inside references sections.
- **The typed walks drop block children wholesale**: list items lose attached figures/tables/notes/quotes and nested dls (a dead guard checks the wrong accessor name); an `a|` table cell containing a list serialises as an ENTIRELY EMPTY cell; quote/admonition/note/example keep only their label skeletons; subfigures vanish.
- **Inline markup content is LOST, not flattened**, in section titles, captions, footnotes (a footnote's `<em>`/link text disappears including the text), and mixed text+element inline content.
- **Front matter**: `showOnFrontPage` unreachable, org-author addresses dropped, `:intended-series:` loses its number (`value=""`), authored initials overridden, `rfc-` docnumber passed raw into `rfc/@number`, foreword notes lost when an abstract coexists.
- **Sections**: `[numbered=false]` and `[removeInRFC=true]` both silently lost (model ghosts + a boolean-vs-"true" dead compare); `[.preface]` clauses and executive summaries vanish from `<middle>`.
- **References**: hidden bibitems emitted; the date cascade is reduced to `published`-only; refcontent reduced to one identifier; translator-only contributors become `Unknown`; and one deliberate-or-not precedence flip (formattedref vs title, old #279 behavior) is held for the editor's adjudication.
- **Pipeline robustness, the two nastiest**: the validation quarantine is gone (invalid output is no longer moved to `.rfc.xml.err`, the "Cannot continue processing" sentinel no longer exists, and xml2rfc runs on known-broken files); and the adjudicated F2 bare-ampersand escape runs only on the library API path — the production CLI path (`rfc_post_process`) demonstrably writes **unparseable** RFC XML for input the API path handles.

## Post-review taxonomy — "how was this never caught?" (added after the editor's challenge)

Grep-verified, three buckets. **(A) Already caught, ledgered, deferred:** cref/annotations, passthrough, refs-section notes, formatted-initials, caption markup, iref `primary=` — all documented during WS3 as 0.2.9 model parse-ghosts, with *pending* spec examples citing the gap; fix route is the model upgrade batch. (The consolidation initially misfiled cref+passthrough as new; corrected.) **(B) Covered features whose lossy dimension the fixtures never contained:** the old suite asserted Endnotes, but its footnote fixtures held plain text only, so flattening was invisible; fixture-bounded folding cannot catch what fixtures don't contain. **(C) The audit's real discovery, and the largest bucket: functionality with NO test anywhere, ever** — old suite zero, new suite zero, corpus zero (hidden bibitems, translator-only contributors, org-author addresses, `a|` cell blocks, nested dl in li, li anchors, mixed th/td …). These are not edge cases by frequency — they are everyday authoring. They were untested because the walker architecture made them work *for free*: generic recursion handled any child without construct-specific code, so there was never a bug, a ticket, or a spec. A typed port converts every free behavior into an opt-in feature, and the inherited test surface systematically under-specifies exactly what was free. Corollary for the template: for walker→typed ports, a green folded suite measures the fixtures, not the walker — the static audit is the only instrument that sees bucket C.

The editor's ruling on the taxonomy, now operative: bucket A must **not** be reported as new defects (its two draft tickets are withdrawn; the deferrals stay tracked by the WS3 ledger and the model upgrade queue); bucket B is accepted as unsophisticated testing; bucket C is incomplete testing — mostly edge cases in RFC terms, but still to be tested, which is what each remaining ticket's "Specs required" section enforces. The filing batch is the tracking issue plus eleven theme tickets.

## Standing consequences

1. This audit level is now the expected floor for port QA in the stack — hence this report; the template above is self-contained.
2. The transformer's spec suite must grow to cover the novel shapes: every theme ticket carries a "Specs required" section enumerating the probe constructs, and fixes land test-gated.
3. The behavioral-parity claim from the corpus sweep stands *for the corpus*; the merged story for #257 is "corpus-parity plus a known, quantised backlog of long-tail gaps", which is a materially honest position to release from.

— Garak
