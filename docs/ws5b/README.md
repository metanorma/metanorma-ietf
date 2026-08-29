# WS5b static port audit — review tree (2026-08-06)

**FILED 2026-08-07:** tracking = metanorma-ietf#291; themes: #292 (03 flattening), #293 (04 footnotes), #294 (05 list items), #295 (06 tables), #296 (07 figures/images), #297 (08 containers), #298 (09 front matter), #299 (10 sections/root attrs), #300 (11 terms), #301 (12 references), #302 (13 pipeline robustness). All assigned opoudjis, all on org project 15.

Everything here is for file-based review; nothing has been filed or committed without approval.

| Path | What it is |
|---|---|
| `../qa-plan.adoc` §WS5b | Method (the reusable template) + final findings ledger by theme |
| `audit/a1-front.md` … `a7-entry-validation.md` | The seven raw area audits (full mapping tables + findings, verbatim agent output) |
| `verdicts/verdicts-v1…v5.md` | Empirical verification wave verdicts (CONFIRMED/REFUTED per finding, with probe evidence) |
| `consolidated.md` | Cross-area dedupe, 11→13 themes, running tallies |
| `tickets/00-tracking.md` | Draft tracking issue (umbrella) |
| `tickets/01…13-*.md` | Draft theme tickets — titles in the HTML comment header of each file; every ticket has a "Specs required" section per the test-coverage directive |
| `odo-report-ws5b.md` | The explicit Odo report: method-first template + results headline |

Review order suggestion: consolidated.md → tickets/ (each is self-contained) → dip into audit/ and verdicts/ where you want the raw evidence. Probe scripts live in the session scratchpad (`ws5b/probes/`) — volatile, but their decisive output snippets are quoted in the verdict files.

Verification tally: ~41 findings empirically confirmed; 1 refuted (iref); 1 reclassified (figure [SOURCE:] dropped, not postamble-emitted); 1 narrowed (NCName asymmetry: '#'-anchors only). One item explicitly held for adjudication, not fixing: formattedref-vs-title precedence (tickets/12, item 6).

**Consolidation correction + user ruling (2026-08-06 late review):** tickets 01 (cref) and 02 (passthrough) were initially misfiled as newly discovered. Both are **known WS3-era model-vintage deferrals**, documented in pending spec examples (`spec/feature/footnotes_spec.rb` reviewer-notes pending note; `spec/feature/inline_spec.rb:634-656` passthrough pending notes) and the qa-plan WS3 ledger; fix route is the 0.4.x/0.5.x model upgrade batch. Per the user's ruling, bucket-A items **must not be reported as new defects**: the two drafts are renamed `WITHDRAWN-*` (kept for reference, never to be filed), and the tracking issue carries a scope note excluding all bucket-A deferrals. **The filing batch is therefore: 00-tracking + tickets 03–13 (12 issues).** Bucket taxonomy per the user's characterization: A = known deferrals (excluded); B = unsophisticated testing (fixtures lacked the lossy dimension); C = incomplete testing — mostly edge cases in RFC terms, but they should still be tested, and each ticket's "Specs required" section is the closure mechanism.
