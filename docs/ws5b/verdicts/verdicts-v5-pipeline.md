# WS5b verification wave — V5 pipeline/CLI verdicts (banked 2026-08-06 22:06)
Probes: scratchpad/ws5b/probes/probe_f{2,3,9}.rb + output artefacts (f2.rfc.xml, f3.rfc.xml, f9_convert_forward.rfc.xml, f9_processor.rfc.xml, stderr logs).

- A7.2 validation quarantine gone — CONFIRMED. Processor#output(:rfc) on a doc with a dangling xref: output file SURVIVES under its normal name, no .err file, no "Cannot continue processing" sentinel anywhere in branch lib/ (old leg: FileUtils.mv → .err + halt). Warnings only; xml2rfc would consume the broken file.
- A7.3 NCName sanitisation asymmetry — CONFIRMED for the '#'-anchor class; space-anchor case REFUTED (presentation layer pre-normalises spaces consistently on both sides). Hash case: element anchor="RFC5234_section-2" vs xref target="RFC5234#section-2" → invalid IDREF + dangling target; old leg's '#'-preserving to_ncname split not ported.
- A7.9 F2 bare-& escape asymmetry — CONFIRMED, severity ESCALATED to full. Same input: convert_forward output well-formed (&amp;para;); processor leg output contains raw &para; → strict parse FATAL "Entity 'para' not defined" — the production CLI path writes unparseable RFC XML. Core does NOT pre-escape.

Score: 3 CONFIRMED (one sub-case refuted within A7.3), 0 fully refuted.
Running totals: V2 6C/1R, V4 6C/0R, V5 3C/0R (A7.3 space sub-case refuted). Awaiting V1 (blocks/figures), V3 (lists/tables).
