# WS5b consolidated ledger (synthesis v1, 2026-08-06 21:55)

Sources: a1-front.md, a2-blocks.md, a3-inline.md, a4-lists-tables.md, a5-references.md, a6-sections-terms.md, a7-entry-validation.md (86 raw findings).
Notation: [A3.8] = area file + finding number. Status: EMPIRICAL (agent ran probe), CODE (code-read only, needs repro), LEDGERED (already documented/adjudicated in WS3/WS5 ledgers — NOT new), UNRESOLVED (needs adjudication not repro).

## Cross-area duplicates (merged)
- cref/annotation stub: A2.1 = A3.1 = A6.3 = A7.5 → T1 (A6 empirically confirmed)
- body passthrough: A2.2 = A7.1 → T2
- garbage year from unparseable date: A1.7 = A7.7 → T6
- ls_text flattening family: A2.11, A4.6, A1.10, A3.7, A6.4 (same mechanism, distinct surfaces) → T3

## Themes

### T1 — Reviewer annotations (cref) pipeline is a stub [EMPIRICAL, 4-agent consensus]
build_annotations returns [] unconditionally; render_annotations? gate ported but dead. A2.1/A3.1/A6.3/A7.5.

### T2 — Body/inline passthrough dropped [CODE→verify]
Only references-section passthrough consumed; clause/inline passthrough vanishes. A2.2/A7.1. (Piquant: the #275 formats-split fix on the released leg has no new-leg body consumer to inherit it.)

### T3 — ls_text flattening: inline markup content LOST (not just flattened) in named containers [A6.4 EMPIRICAL for section titles; rest CODE]
- section/annex titles [A6.4 EMPIRICAL — content of <em> child gone entirely]
- figure/example captions [A2.11], table captions [A4.6 LEDGERED model gap], note names front [A1.10]
- mixed text+children in em/strong/tt/sub/sup [A3.7], strike/smallcap children [A3.15]
- footnote bodies flattened; non-p footnote dropped wholesale [A3.8]
- term designations [A6 mapping]
- dt inline coverage (link/stem/br/fn) [A4.9]

### T4 — Typed-walk block-coverage gaps (fails-closed dispatch maps) [CODE→verify]
- li: nested dl dead guard (:definition_lists vs :dl) [A4.2]; figure/table/note/quote/example/formula children [A4.3]; child order grouped not source-order [A4.4]
- dd: note/quote/example/formula [A4.10]
- quote: only paragraphs [A2.6]; admonition: only paragraphs [A2.6]; note: p/dl/ul/ol only [A2.6]; example: note/quote/formula missing from EXAMPLE_CHILD_ATTRS [A2.6]
- table cells: block content (ul/ol/dl/sourcecode/figure/table) ignored [A4.5a]; mixed th/td header rows drop td [A4.5]
- figure: key dl + intra-figure paragraphs dropped [A2.7]; nested figures dropped (no figure_unnest) [A2.3]; [SOURCE:] emitted as deprecated in-figure <postamble> [A2.8]
- clause-level pre dropped [A2.9]
- preface: generic clauses + executivesummary dropped [A6.5 EMPIRICAL]
- reqt: requirement/recommendation/permission blocks vanish [A6.12 EMPIRICAL]

### T5 — Anchor losses (dangling xref class) [CODE→verify except noted]
- li anchors never set [A4.1]
- inline-image artwork loses anchor/align/name [A3.13]
- bookmark-derived dt/dd anchors [A2.12]
- endnote paragraph anchors [A3.11]
- NCName sanitisation asymmetry: element anchors sanitised, xref targets raw; '#' semantics changed [A7.3]
- referencegroup constituent UUID anchor fallback [A5.11 low]

### T6 — Front-matter gaps [CODE→verify except noted]
- showOnFrontPage unreachable end-to-end (model ghost + not in F5 recovery channel) [A1.1]
- org-only authors lose <address> [A1.2]
- intended-series seriesInfo value="" hardcoded (loses BCP/STD number) [A1.3]
- authored initials overridden by forename-derived [A1.4]
- ascii* attribute family partial (asciiValue/asciiInitials/asciiAbbrev/email+postal ascii) [A1.5]
- datetime dates collapse to year [A1.6]; unparseable date → garbage year="May "/"circ" instead of omission [A1.7=A7.7]
- docnumber rfc-prefix/extension strip lost [A1.8]
- front notes: abstract||foreword instead of both (#285 regression class) [A1.9]
- multi-role contributors (first role only) [A1.11 low]; en-title filter [A1.12 low]

### T7 — Root attrs / PIs / sections [mostly EMPIRICAL via A6]
- numbered= lost (model maps only unnumbered; == "true" vs boolean dead compare) [A6.1 EMPIRICAL]
- removeInRFC lost (model ghost, no recovery channel) [A6.2 EMPIRICAL]
- tocDepth/indexInclude/iprExtract not on root (F5-parallel) [A6.7]
- PI coverage 35→8 keys [A6.8 low, xml2rfc v3 ignores PIs]

### T8 — Terms [EMPIRICAL via A6]
- SOURCE xref emitted as ESCAPED literal markup (&lt;xref…&gt; visible; locality + citeas gone) [A6.9]; same string-splice suspect in build_concept [A6 mapping]
- modification text lost unless status="modified" [A6.10]
- multiple sources not merged [SOURCE: A; B] [A6.11]
- multi-paragraph single definition → fake <ol> [A6.6]
- origin termref branch unhandled [A3.16]

### T9 — References [EMPIRICAL via A5]
- hidden bibitems emitted (element_order branch misses hidden_bibitem? check) [A5.1]
- HTML-typed uri no longer target [A5.2]
- date cascade lost (published only; issued/circulated dropped) [A5.3]
- refcontent single id (was join of all eligible) [A5.4]; over-emission of ISBN/URN [A5.9]
- formattedref-vs-title precedence FLIPPED [A5.5 UNRESOLVED — presentation bibrender enrichment may make old precedence unportable; adjudication]
- contributor role cascade lost (translator-only → Unknown) [A5.6]
- refs-section notes → annotations [A5.7 LEDGERED 0.2.9]; formatted-initials [A5.8 LEDGERED]

### T10 — Pipeline robustness [CODE→verify via CLI]
- validation quarantine gone: invalid output no longer moved to .rfc.xml.err, "Cannot continue processing" sentinel gone, xml2rfc runs on broken files [A7.2]
- F2 bare-& escape asymmetry: convert_forward yes, processor rfc_post_process no [A7.9]
- unknown-element silent drop replaces loud escaped-text fallback [A7.6 — design note for ticket narrative, not a fix ask]
- refcontent each-with-delete iteration bug [A7.8]

### T11 — Inline misc [CODE→verify]
- non-bcp14 span content dropped entirely [A3.2]
- br → "\n" (legal <br> in td/th lost) [A3.3]
- eref brackets= from link style= [A3.4]; xref relative= [A3.5]; anchor-locality→relative fallback [A3.6]
- iref: live builder assigns raw model accessors; text-safe build_iref is dead code [A3.14]
- table-footnote dedup global not per-table (collision loses second table's text) [A3.9]; leading space before marker lost [A3.10]
- image_cleanup only sweeps section.t: [IMAGE n] marker orphaned in li/td/quote, figure discarded [A3.12]; placement at section end not adjacent [A3.12]
- ol unknown literal types collapsed to "1" [A4.11 low]; table align dropped [A4.7]; checkbox li [A4.12 low/design]; dl title [A4.13 low]
- keepWithPrevious never set [A2.5]; sourcecode src= never set [A2.4]; note anchor fallback [A2 mapping]

## Already-ledgered (dedupe OUT of new-findings count)
- table caption model gap [A4.6], refs-section notes [A5.7], formatted-initials [A5.8], iref primary= [A3 mapping], notes unnumbered concession [A2 mapping], abstract block restriction [A1 mapping], facsimile F6 [A1 mapping], docid_prefix kill [A5 mapping], PI channel largely moot [A6.8]

## Verification wave (launched 2026-08-06 ~22:00)
V1 blocks/figures: A2.2 passthrough, A2.3 nested figures, A2.4 sourcecode src, A2.5 keepWithPrevious, A2.6 container children, A2.7 figure key, A2.8 postamble
V2 inline/footnotes: A3.2 span, A3.8 footnote markup, A3.9 collision, A3.10 spacing, A3.12 image-in-li, A3.3 br-in-td, A3.14 iref
V3 lists/tables: A4.1 li anchor, A4.2 dl-in-li, A4.3 li blocks, A4.4 li order, A4.5a cell blocks, A4.7 table align
V4 front matter: A1.1 showOnFrontPage, A1.2 org address, A1.3 intended-series value, A1.4 initials, A1.8 docnumber, A1.9 foreword note
V5 pipeline/CLI: A7.2 quarantine, A7.9 F2 asymmetry, A7.3 NCName targets
Already empirically confirmed (no re-verification needed): T1 cref, A6.1/2/4/5/9/10/12, A5.1/2/3/4/5/6.

## Ticket quantisation (PROPOSAL — user approval required)
One tracking issue (WS5b static port audit, child of #233) + theme tickets ≈ T1 cref; T2 passthrough; T3 flattening; T4 block-coverage; T5 anchors; T6 front-matter; T7 root attrs; T8 terms; T9 references; T10 pipeline robustness; T11 inline misc (possibly folded into nearest theme). UNRESOLVED items (A5.5) flagged for adjudication inside their theme ticket, not pre-decided.
