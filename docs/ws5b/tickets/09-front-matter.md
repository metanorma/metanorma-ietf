<!-- TICKET DRAFT 09. Repo: metanorma/metanorma-ietf. Assignee: opoudjis. -->
<!-- Title: Transformer: front-matter gaps — showOnFrontPage, org address, intended-series value, initials, docnumber, foreword notes, ascii*, dates -->

Refs TRACKING-URL

Empirically confirmed (probes end-to-end from AsciiDoc):

1. **`organization/@showOnFrontPage` unreachable.** `:show-on-front-page: false` reaches `bibdata/ext` in the semantic XML; the output org element carries no attribute — the affiliation renders against the author's instruction. Ghosted by the pinned ext model AND absent from the `recover_rfc_attributes` side-channel (transformer.rb:131, which recovers only symRefs/tocInclude/sortRefs). rfcxml supports `show_on_front_page`.
2. **Org-only authors lose `<address>`.** Contributor with organization + formattedAddress/phone/email/uri → `<organization>` only (front_transformer.rb:147-151); all contact data vanishes.
3. **Intended-series seriesInfo hardcodes `value=""`.** `:intended-series: BCP 14` → `<seriesInfo name="" value="" status="BCP"/>` — the "14" lost (front_transformer.rb:81-92; model exposes `s.number`). Old: `value="14"`.
4. **Authored initials overridden.** `:initials: B. X.` + `:givenname: Barney` → `initials="B."`; the forename branch (ietf_to_rfc_v3.rb:258-267) wins over the `initials` accessor. Old preferred the authored element.
5. **Docnumber normalization lost.** `:docnumber: rfc-8341` → `rfc/@number="rfc-8341"` and seriesInfo value likewise (old stripped to `8341`; metadata.rb:30-34 on main also stripped file extensions).
6. **Foreword notes lost when an abstract coexists.** `build_front_notes` picks `preface.abstract || preface.foreword` (front_transformer.rb:511); control probe proves the machinery works foreword-only. The #285 fix had deliberately collected BOTH containers.

Code-read (medium confidence, verify while fixing):

7. ascii* family partial: asciiValue, asciiInitials, asciiFullname (surname+completename branch), asciiAbbrev, email/structured-postal `ascii` never set (rfcxml supports all).
8. Datetime-stamped dates collapse to year-only (old stripped `T.*`); unparseable dates fabricate `year="May "`/`"circ"` garbage instead of omitting `<date>` (front_transformer.rb:322 `date_str[0,4]`) — also surfaces on the references side.
9. Multi-role contributors matched on first role only (front_transformer.rb:104).

## Specs required

One per confirmed item (probe shapes 1–6); ascii* with a non-ASCII author; malformed-date omission.

🤖
