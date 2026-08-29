# WS5b verification wave — V1 blocks/figures verdicts (banked 2026-08-06 22:07) — WAVE COMPLETE
Probe scripts: scratchpad/ws5b/probes/a2_probes.rb + a2_probes2.rb; outputs a2_out.txt.

- A2.2 body/inline passthrough dropped — CONFIRMED, and LOCALISED to the transformer leg: presentation XML still carries both inline and block passthrough; the transformer drops them. (T2 upgraded: fix is transformer-side, not presentation.)
- A2.3 nested figures dropped — CONFIRMED (subfigures F2/F3 gone entirely; model DOES parse them — map_element "figure" exists in 0.2.9 FigureBlock — so purely a missing transform branch, not a model ghost)
- A2.4 sourcecode src= dropped — CONFIRMED (presentation retains src; output `<sourcecode anchor="S1" type="c"/>` empty, no src)
- A2.5 keepWithPrevious dropped — CONFIRMED (control pair: keepWithNext wired, keepWithPrevious silently dropped; both present in presentation XML)
- A2.6 container children dropped — CONFIRMED all four shapes in one probe (quote-ul, admonition-ul, note-sourcecode, example-note all lose content; only skeletons/labels survive)
- A2.7 figure key dl + intra-figure paragraphs dropped — CONFIRMED (INTROPARAGRAPH, EXPLANATIONPARAGRAPH, key dl all vanish; no relocation)
- A2.8 [SOURCE:] as in-figure postamble — REFUTED AS STATED, but actual defect WORSE-DIFFERENT: figure_node.source is the model's source= ATTRIBUTE (string), not the <source> citation element — the postamble branch is dead code, and the figure's [SOURCE:] attribution (present in presentation XML as fmt-source) is DROPPED ENTIRELY. Reclassify: content loss, merge into T4 figure gaps alongside A2.7.

## FINAL WAVE TALLY
V1 6C + 1 refuted-as-stated (defect real but different: [SOURCE:] dropped)
V2 6C / 1R (A3.14 iref — genuine false alarm)
V3 6C / 0R (A4.5a WORSE: cell entirely empty)
V4 6C / 0R
V5 3C / 0R (A7.3 space sub-case refuted — presentation pre-normalises; '#' case confirmed)

Wave: 27 CONFIRMED, 1 pure false alarm (A3.14), 1 reclassified (A2.8), 1 sub-case narrowed (A7.3 spaces).
Plus prior in-audit empirical confirmations: A5.1–6, A6.1/2/4/5/6/9/10/12 (~14).
Net: ~41 findings now EMPIRICALLY CONFIRMED; remainder of the 86 are LEDGERED (known), low-priority code-reads, or design notes.
