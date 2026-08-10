<!-- TICKET DRAFT 13. Repo: metanorma/metanorma-ietf. Assignee: opoudjis. -->
<!-- Title: Transformer: pipeline robustness — validation quarantine, CLI ampersand escaping, NCName '#' asymmetry, refcontent iteration -->

Refs TRACKING-URL

Empirically confirmed (probes):

1. **Validation quarantine gone.** Old leg moved invalid output to `<file>.rfc.xml.err` and warned "Cannot continue processing", so downstream xml2rfc (txt/html/pdf legs) never consumed a known-broken file. New processor leg (`rfc_post_process`) only warns: probe with a dangling xref left `f2.rfc.xml` on disk, no `.err`, no sentinel (the string does not exist anywhere in branch lib/). xml2rfc then runs on broken files; tooling that greps for the sentinel is also broken.
2. **Bare-ampersand escaping (F2) absent from the processor/CLI path — writes UNPARSEABLE XML.** `escape_bare_ampersands` runs in `convert_forward` but `rfc_post_process` (processor.rb:77-83) calls only `u_cleanup` + validation despite its mirror-comment. Probe: identical input → API leg well-formed (`&amp;para;`); processor leg raw `&para;` → strict parse FATAL `Entity 'para' not defined`. Core does not pre-escape. This asymmetry means the production `metanorma -t ietf` path is exposed to exactly the defect the adjudicated F2 fix closed on the API path.
3. **NCName sanitisation asymmetry for `#`-anchors.** Element anchors go through `to_ncname` (which maps `#`→`_`), xref targets are passed raw (inline_transformer.rb:209): anchor `RFC5234#section-2` serialises as `anchor="RFC5234_section-2"` while the xref keeps `target="RFC5234#section-2"` — invalid IDREF + dangling target. (Space-anchors are fine — presentation pre-normalises both sides.) Old `to_ncname` deliberately preserved `#` (split-sanitise per half).
4. **refcontent each-with-delete iteration bug** (code-read): `ref.refcontent.delete(rc)` inside `each` (cleanup_transformer.rb:369-382) skips the successor — second of two consecutive empty refcontents survives.

Design note (no fix asked, recorded): unknown elements are now dropped silently at `from_xml` where the old leg emitted loud escaped text — every future coverage gap is invisible in output. Worth a debug-mode counter or logged warning if cheap.

## Specs required

Invalid doc → quarantine behavior (whatever semantics are chosen: .err restore or hard failure); literal-entity input through the processor leg parses clean; `#`-anchor + xref pair consistent; consecutive empty refcontents both removed.

🤖
