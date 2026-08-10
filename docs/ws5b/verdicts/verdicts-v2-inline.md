# WS5b verification wave — V2 inline/footnotes verdicts (banked 2026-08-06 22:05)
Probe script: scratchpad/ws5b/probes/a3_probes.rb (full new pipeline via Metanorma::Ietf::Transformer.convert, presentation stage included).

- A3.2 span content dropped — CONFIRMED (`<t>before  after</t>`; span content gone wholesale)
- A3.3 br in td degraded to newline — CONFIRMED (`<td>line1\nline2</td>`, no <br/>)
- A3.8 footnote flattening — CONFIRMED (inline elements vanish INCLUDING their text: "[1] See  and  tail"; list-bodied footnote gets marker but NO endnote body at all)
- A3.9 table-footnote global dedup collision — CONFIRMED (both tables' cells show [1]; SECOND-TABLE-NOTE text absent from output entirely)
- A3.10 leading space before marker lost — CONFIRMED (`text[1]` vs old `text [1]`)
- A3.12 image-in-li orphaned marker — CONFIRMED (`<li>item [IMAGE 2]</li>`, artwork nowhere). BONUS: even the control image in a plain section paragraph produced `<t>ctrl </t>` with NO figure — the safe_append(:figure) recovery did not serialize in the probe, so the sweep path itself is lossy. Escalate A3.12 severity: inline images may be lost EVERYWHERE in this shape, not just in li/td.
- A3.14 iref raw-accessor serialization — REFUTED (`<iref item="keyword" subitem="subterm"/>` correct; model child objects serialize to text. Dead-code observation stands but no output damage.)

Score: 6 CONFIRMED, 1 REFUTED.
