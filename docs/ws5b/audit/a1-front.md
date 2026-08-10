# WS5b area audit — A1 front matter / metadata (agent raw result, banked 2026-08-06 21:19)

## Mapping

| Old method (file:line) | Behavior | New equivalent (file:line or —) | Status | Note |
|---|---|---|---|---|
| front.rb:6 `make_front` | front children in v3 order: title, seriesInfo, author, date, area, workgroup, keyword, abstract, note | front_transformer.rb:8 `build_front` | PORTED | Same order |
| front.rb:23 `info` | injects `:areas` metadata before base info | front_transformer.rb:342 `build_areas` reads `ietf_ext.area` directly | PORTED | Metadata layer collapsed into transformer |
| front.rb:28 `output_if_translit` | emit transliteration only when it differs from source | base.rb / front_transformer: `Sterile.transliterate` + `unless ==` pattern | PORTED | Used inconsistently — see PARTIAL rows below |
| front.rb:33 `title` | `<title>` with text from doctitle | front_transformer.rb:22 `build_title` | PORTED | OLD emits no `<title>` when doctitle absent; NEW emits empty `<title>`. Minor |
| front.rb:33 `title` | `@abbrev` from title[@type='abbrev'] | front_transformer.rb:26 + ietf_to_rfc_v3.rb:103 | PORTED | |
| front.rb:33 `title` | `@ascii` from title[@type='ascii'], else transliteration when differing | front_transformer.rb:27-32 + ietf_to_rfc_v3.rb:115 | PORTED | |
| metadata.rb:6 `TITLE_RFC` | title selection restricted to `@language='en'` | ietf_to_rfc_v3.rb:92-101 picks first `type=="main"` regardless of language | PARTIAL | Multilingual bibdata could pick non-English title (finding 12) |
| front.rb:40 `seriesinfo` | seriesInfo only for doctype RFC / Internet Draft | front_transformer.rb:36 `build_series_info` — `rfc?` else Internet-Draft | PORTED | NEW folds all non-RFC doctypes into I-D branch; benign for IETF flavor |
| front.rb:45 `seriesinfo_attr` | `@value` = docnumber, `@status` = stage, `@stream` = series[stream]/title | front_transformer.rb:41-53, 58-77 | PORTED | Status capitalization + "Published"/"Informational" defaults are adjudicated WS3 deviations |
| front.rb:45 `seriesinfo_attr` | `@asciiValue` = transliterated docnumber when non-ASCII | — | PARTIAL | rfcxml SeriesInfo supports `ascii_value`; never set (finding 5) |
| front.rb:53 `rfc_seriesinfo` | second seriesInfo: `@status` = intended title, `@value` = intended series **number** | front_transformer.rb:81-92 — `si.value = ""` hardcoded | PARTIAL | Intended-series number dropped (finding 3); model has `s.number` (SeriesType:22) |
| front.rb:63 `id_seriesinfo` | I-D seriesInfo + intended-status seriesInfo | front_transformer.rb:56-78, 81-92 | PORTED | Fallback restructure adjudicated (WS3, metadata_spec) |
| front.rb:71 `author` | iterate contributors with **any** role author/editor | front_transformer.rb:104 `contrib.role.first&.type` | PARTIAL | Only first role checked (finding 11) |
| front.rb:71 `author` | skip Workgroup-subdivision (committee) contributor | front_transformer.rb:114, 126 `workgroup_carrier?` | PORTED | Case-insensitive, slightly broader |
| front.rb:71 `author` | `@role="editor"` for editors | front_transformer.rb:136 | PORTED | |
| front.rb:81 `person_author_attrs` | initials: authored `./initial` element **preferred** over forename-derived | ietf_to_rfc_v3.rb:247-291 — forename-derived wins; `initials` accessor consulted only when no forenames | PARTIAL | Authored "B. X." overridden by computed "B." (finding 4) |
| front.rb:81 `person_author_attrs` | fullname/surname/initials attrs | ietf_to_rfc_v3.rb:247-291 | PORTED | NEW additionally synthesizes fullname & derives initials from completename (F10 enrichment) |
| front.rb:92 `pers_author_attrs1` | `@asciiFullname`/`@asciiInitials`/`@asciiSurname` when non-ASCII | ietf_to_rfc_v3.rb:255-266 — ascii_surname yes; ascii_fullname only in two of three branches; ascii_initials never | PARTIAL | Finding 5a |
| front.rb:103 `person_author` | affiliation org → `<organization>`, contact → `<address>` | front_transformer.rb:134-145, 153-198 | PORTED | |
| front.rb:115 `org_author` | org authors also get `<address>` (postal/phone/email/uri) | front_transformer.rb:147-151 — organization only, no address | PARTIAL | Finding 2 |
| front.rb:126 `organization` | `@showOnFrontPage` from document `//showOnFrontPage` on every author org | — (base.rb:152 `build_rfc_organization` has no such read; transformer.rb:131 recovery channel omits it) | MISSING | Finding 1 |
| front.rb:126 `organization` | org `@ascii` when non-ASCII name; `@abbrev` | base.rb:163-166, 157-161 | PORTED | |
| front.rb:126 `organization` | `@asciiAbbrev` when abbreviation non-ASCII | — | PARTIAL | rfcxml supports `ascii_abbrev`; never set (finding 5b) |
| front.rb:135 `address` | emit `<address>` only when any component present | front_transformer.rb:153-198 | PORTED | |
| front.rb:135 `address` | fax phone → `<facsimile>` | front_transformer.rb:163-169 comment | DROPPED-BY-DESIGN | RFC 7991 removed facsimile; ratified WS5 F6 |
| front.rb:144 `postal` | formattedAddress: `<br/>`→newline, one `<postalLine>` per line | front_transformer.rb:200-232 | PORTED | OLD emits `@ascii` always, NEW only when differing — cosmetic |
| front.rb:160 `postal_detailed` | structured street/city/region/country/code | front_transformer.rb:234-278 | PORTED | Order differs (code before country); presentation stage normally collapses to formattedAddress anyway |
| front.rb:160 `postal_detailed` | `@ascii` transliteration on every structured postal element | — | PARTIAL | Finding 5c; low impact since presentation collapses to postalLine |
| front.rb:174 `email` | `<email>` per email; `@ascii` when non-ASCII | front_transformer.rb:178-184 — no ascii | PARTIAL | Finding 5d |
| front.rb:180 `date` | published || circulated date, else today | front_transformer.rb:280-308 | PORTED | OLD prefers published over circulated; NEW takes first-in-document-order of either — negligible |
| front.rb:180 `date` | strip time component (`gsub(/T.*$/)`) before parsing | — (parse_date_into regexes don't match datetimes) | PARTIAL | Finding 6 |
| front.rb:188 `date_attr` | year / year-month / full-date parsing, day without leading zero | front_transformer.rb:310-324 | PORTED | |
| front.rb:188 `date_attr` | unparseable date → **no** `<date>` element | front_transformer.rb:321-323 — emits `date_str[0,4]` as year | PARTIAL | Finding 7 |
| front.rb:205 `area` | `<area>` per bibdata/ext/area | front_transformer.rb:342 | PORTED | |
| front.rb:211 `workgroup` / metadata.rb:41 `wg` | `<workgroup>` from committee contributor's Workgroup subdivision | front_transformer.rb:353-392 | PORTED | NEW adds editorial-group primary source; drops `role/description='committee'` filter (broader, benign) |
| front.rb:217 `keyword` | `<keyword>` per bibdata keyword | front_transformer.rb:394-410 | PORTED | NEW adds Relaton-2.0 vocab nesting |
| front.rb:223 `abstract` | `<abstract>` from preface abstract|foreword, all children parsed | front_transformer.rb:412-485 | PORTED | Legal subset (t/ul/ol/dl + example-as-labelled-t) in source order |
| front.rb:223 `abstract` | tables/sourcecode/figures inside abstract | front_transformer.rb:428-432 comment | DROPPED-BY-DESIGN | RFC 7991 abstract admits (dl|ol|t|ul)+ only; documented model-gap |
| front.rb:230 `note` | `<note>` per abstract note **and** foreword note (both containers, #285) | front_transformer.rb:504-532 — `preface.abstract || preface.foreword`, one container | PARTIAL | Finding 9 |
| front.rb:230 `note` | `@removeInRFC` | front_transformer.rb:536, 558 | PORTED | |
| front.rb:230 `note` | note `<name>` with inline children parsed | front_transformer.rb:538-547 — plain text only | PARTIAL | Finding 10 |
| front.rb:230 `note` | note body = all non-name children | front_transformer.rb:549-552 via `get_paragraphs` | PORTED | Paragraph-shaped content; lists in front notes untested |
| front.rb:247 `boilerplate` | no-op | — | DROPPED-BY-DESIGN | Dead code on origin/main already |
| metadata.rb:8 `title` | set doctitle/docabbrev/docascii | ietf_to_rfc_v3.rb:92-119 | PORTED | |
| metadata.rb:17 `relaton_relations` | included-in/described-by/derived-from/instance-of → `<link>` rel mapping | metadata_transformer.rb:150-179 `REL2IANA`, `build_links` | PORTED | Both spellings covered; biblio-tag scoped docids excluded |
| metadata.rb:22 `areas` | collect bibdata/ext/area | front_transformer.rb:342 | PORTED | |
| metadata.rb:30 `docid` | docnumber normalization: strip `^rfc-` prefix and `\.[a-z0-9]+$` extension | ietf_to_rfc_v3.rb:121-133 — raw docnumber, no stripping | PARTIAL | Finding 8; NEW adds docidentifier fallback (enrichment) |
| metadata.rb:36 `author` | trigger wg collection | front_transformer.rb:353 | PORTED | |
| metadata.rb:55 `doctype` | normalize "rfc"/"Rfc" casing → "RFC" (#268) | ietf_to_rfc_v3.rb:75-77 `casecmp?` | PORTED | |
| metadata.rb:61 `initialize` | clear inherited publisheddate/circulateddate defaults | — | RELOCATED | NEW reads bibdata dates directly; base-class default never exists |

## Findings

1. **`organization/@showOnFrontPage` never emitted — MISSING.**
   (a) front.rb:126-133 `organization`: `out.organization name, **attr_code(showOnFrontPage: show&.text, ...)` where `show = contrib.document.at(ns("//showOnFrontPage"))`.
   (b) The `:show-on-front-page:` document attribute (serialized by lib/metanorma/ietf/front.rb:77 into `bibdata/ext/showOnFrontPage`) sets `showOnFrontPage` on every author `<organization>`; xml2rfc uses it to suppress the affiliation on the first page.
   (c) Input: AsciiDoc with `:show-on-front-page: false` and any author affiliation → NEW emits `<organization>Acme</organization>` with no attribute, so the affiliation renders on the front page against the author's instruction. The element is ghosted by the pinned ext model (ietf_bib_data_extension_type.rb maps neither it, indexInclude, nor iprExtract), and the F5 recovery channel (lib/metanorma/ietf/transformer.rb:131) recovers only `symRefs tocInclude sortRefs` — so nothing downstream can see it. rfcxml-0.4.4 Organization *does* support `show_on_front_page`.
   (d) Confidence: **high**.

2. **Organizational authors lose their `<address>` block — PARTIAL.**
   (a) front.rb:115-124 `org_author`: after `organization(...)`, calls `address(contrib.at(ns(".//address")), phone, fax, email, uri, a)`.
   (b) An org-only contributor (no person) still got postal/phone/email/uri emitted inside `<author>`.
   (c) Input: presentation-XML `<contributor><role type="author"/><organization><name>IETF Tools Team</name><address>...</address>...` plus org email/uri → NEW `build_org_author` (front_transformer.rb:147-151) emits only `<organization>`; contact data silently vanishes.
   (d) Confidence: **high** for the behavioral gap, **medium** for real-world impact (org authors with contact info are uncommon but legal).

3. **Intended-series seriesInfo drops its `value` (series number) on the RFC branch — PARTIAL.**
   (a) front.rb:53-60 `rfc_seriesinfo`: `front.seriesInfo nil, **attr_code(name: "", status: i.at(ns("./title"))&.text, value: i.at(ns("./number"))&.text || "")`.
   (b) `<series type="intended"><title>bcp</title><number>14</number></series>` → `<seriesInfo name="" status="bcp" value="14"/>` (BCP number on the masthead).
   (c) Input: `:intended-series: bcp 14` on an RFC doctype → NEW (front_transformer.rb:81-92) hardcodes `si.value = ""`, losing "14". The model exposes `s.number` (metanorma-document SeriesType:22), so the data is reachable.
   (d) Confidence: **high**.

4. **Authored initials overridden by forename-derived initials — PARTIAL.**
   (a) front.rb:83-85 `person_author_attrs`: `init = contrib.at(ns("./initial"))&.text || forename-derived`.
   (b) An explicitly authored `<initial>B. X.</initial>` wins over computed initials.
   (c) Input: `:initials: B. X.` with `:forename: Barney` → OLD `initials="B. X."`; NEW (ietf_to_rfc_v3.rb:258-267) enters the forename branch and emits `initials="B."`, discarding the authored middle initial — the `person_name.initials` accessor is consulted only when forenames are absent (line 269).
   (d) Confidence: **high** (the metadata_spec fixture itself carries exactly this shape).

5. **ASCII-fallback attribute family largely unported — PARTIAL (four sub-gaps, all supported by rfcxml-0.4.4).**
   (a) front.rb:45-47 (`asciiValue`), front.rb:92-101 (`asciiInitials`; `asciiFullname` in the surname+completename case — ietf_to_rfc_v3.rb:283-284 sets fullname with no ascii), front.rb:129-131 (`asciiAbbrev`), front.rb:174-178 (email `@ascii`), front.rb:160-172 (structured postal `@ascii`).
   (b) OLD emitted transliterated ascii fallbacks wherever the source text was non-ASCII, per RFC 7991's i18n model.
   (c) Input: an author `José Núñez` with completename+surname (no forenames), a non-ASCII org abbreviation, or a Cyrillic street address → NEW output has no `asciiFullname`/`asciiAbbrev`/`ascii`, so xml2rfc has no ASCII rendering for text-mode output. (`ascii_surname` and the forename-branch `ascii_fullname` *are* ported; postalLine ascii is ported.)
   (d) Confidence: **medium** (non-ASCII front matter is a minority case but explicitly supported by the old leg).

6. **Datetime-stamped dates collapse to year-only — PARTIAL.**
   (a) front.rb:182 `date`: `date = date.gsub(/T.*$/, "")` before parsing.
   (b) A `bibdata/date … on="2015-01-01T00:00:00Z"` was normalized to `2015-01-01` → full day/month/year attrs.
   (c) Input: a revdate carrying a time component → NEW `parse_date_into` (front_transformer.rb:310-324) matches none of the three regexes and falls to the else branch, emitting `<date year="2015"/>` with month/day lost.
   (d) Confidence: **medium** (the OLD guard existed because such inputs occur; whether current standoc still emits datetimes is unverified).

7. **Unparseable date now emits a garbage `year` instead of omitting `<date>` — PARTIAL.**
   (a) front.rb:184 `attr = date_attr(date) || return` — `Date.iso8601` failure → no `<date>` element (xml2rfc then defaults sensibly).
   (b) Malformed dates were suppressed.
   (c) Input: `on="May 2015"` (or any free-text date ≥ 4 chars) → NEW emits `<date year="May "/>` (front_transformer.rb:322 `date_str[0, 4]`), which is invalid v3 and an xml2rfc error.
   (d) Confidence: **medium** (requires malformed upstream data, but the failure mode is now worse than the old one).

8. **Docnumber normalization (`rfc-` prefix / file-extension strip) dropped — PARTIAL.**
   (a) metadata.rb:30-34 `docid`: `dn&.text&.strip&.sub(/^rfc-/, "")&.sub(/\.[a-z0-9]+$/i, "")`.
   (b) Legacy/mmark-heritage docnumbers like `rfc-2313.md` rendered as `2313` in `rfc/@number` and `seriesInfo/@value`.
   (c) Input: `:docnumber: rfc-8341` (or a filename-derived name) → NEW `docnumber` (ietf_to_rfc_v3.rb:121-133) returns it verbatim; `rfc.number = "rfc-8341"` and `seriesInfo value="rfc-8341"`, both xml2rfc-visible corruption. No stripping anywhere in the new leg (grepped lib/metanorma/ietf/ and lib/isodoc/ietf/).
   (d) Confidence: **medium** (mainline `:docnumber: 8341` inputs are unaffected; the guard existed for a real legacy corpus).

9. **Front notes collected from only one preface container — PARTIAL.**
   (a) front.rb:231-233 `note`: xpath `//preface/abstract/note | //preface/foreword/note` collects from **both** containers (the #285 fix deliberately widened this).
   (b) All abstract and foreword notes become `<note>` elements.
   (c) Input: preface with both an `<abstract>` (no notes) and a `<foreword>` containing a note → NEW `build_front_notes` (front_transformer.rb:511) picks `preface.abstract || preface.foreword`, so the foreword note is silently lost.
   (d) Confidence: **medium** (abstract+foreword coexistence is an edge shape, but the old code comments show note loss was a real reported bug, #285).

10. **Note `<name>` inline markup flattened to plain text — PARTIAL.**
    (a) front.rb:233-235: `title.children.each { |tt| parse(tt, t) }` — rich inline (em, tt, xref) preserved in the note name.
    (b) Note titles kept their formatting.
    (c) Input: `[NOTE]` with a heading containing `` `code` `` or emphasis → NEW (front_transformer.rb:538-547) emits `ls_text` plain text; markup lost (rendering-only, not structural).
    (d) Confidence: **medium-low**.

11. **Multi-role contributors matched on first role only — PARTIAL.**
    (a) front.rb:72-73: xpath `role/@type = 'author' or role/@type = 'editor'` matches any of a contributor's roles.
    (b) A contributor listed with roles e.g. [publisher, author] still became a front author.
    (c) Input: presentation XML contributor with two `<role>` elements where author/editor is not first → NEW (front_transformer.rb:104 `contrib.role.first&.type`) skips them.
    (d) Confidence: **low** (standoc emits single-role contributors; only hand-authored or relaton-imported bibdata would hit it).

12. **English-language title filter dropped — PARTIAL.**
    (a) metadata.rb:6 `TITLE_RFC = "//bibdata//title[@type='main' and @language='en']"`.
    (b) Only the English main title fed `<title>`.
    (c) Input: bilingual bibdata with `<title type="main" language="fr">` appearing before the English one → NEW `main_title` (ietf_to_rfc_v3.rb:97) takes the first `type=="main"` regardless of language.
    (d) Confidence: **low** (IETF-flavor documents are effectively monolingual English).
