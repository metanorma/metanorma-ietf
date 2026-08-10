# WS5b verification wave — V3 lists/tables verdicts (banked 2026-08-06 22:06)
Probe script: scratchpad/ws5b/probes/a4_probes.rb (bundle exec ruby a4_probes.rb f1|f2|f3|f4x|f5a|f7).

- A4.1 li anchors lost — CONFIRMED (li id never emitted as anchor; xref target="itemid" dangles; presentation warned "No label has been processed for ID itemid")
- A4.2 dl-in-li dead guard — CONFIRMED end-to-end (semantic has dl inside li; RFC output drops it wholesale; :definition_lists vs :dl)
- A4.3 li block children dropped — CONFIRMED (quote + note + table attached via `+` continuation all vanish from the li)
- A4.4 li child order grouped not source order — CONFIRMED (p → ul → p emits t, t, ul; trailing paragraph serialized before the sublist)
- A4.5a block content in table cells — CONFIRMED, WORSE than audited: a| cell with paragraph + bullet list emits an ENTIRELY EMPTY cell (even the leading paragraph lost)
- A4.7 table @align dropped — CONFIRMED (semantic carries align="left" — presentation-layer caveat resolved in the finding's favor; RFC table has no align attribute at all; "forced center" sub-claim does not materialize in serialization)

Score: 6 CONFIRMED (one worse than claimed), 0 REFUTED.
Running totals: V2 6C/1R, V3 6C/0R, V4 6C/0R, V5 3C/0R(+1 sub-case refuted). Awaiting V1 (blocks/figures) only.
