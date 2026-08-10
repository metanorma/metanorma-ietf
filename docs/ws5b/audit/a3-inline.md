# WS5b area audit — A3 inline markup / footnotes / inline cleanup (agent raw result, 2026-08-06 15:20)

## Mapping

| Old method (file:line) | Behavior | New equivalent (file:line or —) | Status | Note |
|---|---|---|---|---|
| inline.rb:4 `em_parse` | `<em>` wrapping child content | ietf_to_rfc_v3.rb:167,181 `build_simple_inline(_model)` | PORTED | via SIMPLE_INLINE_CLASSES |
| inline.rb:4-32 em/sup/sub/tt/strong | mixed content inside inline (own text + nested elements, in order) | ietf_to_rfc_v3.rb:181-214 | PARTIAL | nested walk fires only when own text is EMPTY; `foo <strong>b</strong> baz` inside `<em>` keeps only text — see Finding 7 |
| inline.rb:10 `sup_parse` / :16 `sub_parse` / :22 `tt_parse` / :28 `strong_parse` | `<sup>/<sub>/<tt>/<strong>` | ietf_to_rfc_v3.rb:176-179 | PORTED | |
| inline.rb:34 `bcp14_parse` | `<bcp14>` wrapping | block_transformer.rb:144-150 | PORTED | plus a new strong→bcp14 keyword promotion (cleanup_transformer.rb:240) with no old counterpart |
| inline.rb:40 `display_text_parse` | unwrap display-text, keep children incl. markup | inline_transformer.rb:189 `inline_flat_text` (abstract only), extract_*_text elsewhere | PARTIAL | outside the abstract, nested markup in link-text flattens/drops — Finding 7 |
| inline.rb:44 `strike_parse` / :48 `smallcap_parse` / :52 `keyword_parse` | drop wrapper but PARSE children (nested xref/link survive as elements) | block_transformer.rb:702-723 `build_dropped_inline` | PARTIAL | new keeps text only (`ls_text` / `.to_s`); nested elements inside strike/smallcap lost — Finding 15 |
| inline.rb:56 `text_parse` | text node passthrough (raw serialization) | block_transformer.rb:68-71 element_order text fragments + transformer.rb:69 `escape_bare_ampersands` | PORTED | |
| inline.rb:63 `semx_stem_parse` | MathML: asciimath child else Plurimath mathml→asciimath; other: encoded text; wrapped in math delimiters | inline_transformer.rb:237-309 `build_stem_text` | PORTED | new adds delimiter-collision escaping (stem_delimiter) |
| inline.rb:75,77 `page_break`/`pagebreak_parse` | suppress page breaks | — (no map entry → dropped) | PORTED | noop both sides |
| inline.rb:79 `br_parse` | emit `<br/>` element | block_transformer.rb:151-152 (`"br" => "\n"`) | PARTIAL | v3 `<br>` is legal in td/th; new degrades to whitespace — Finding 3 |
| inline.rb:83 `hr_parse` | suppress hr | — | PORTED | noop both sides |
| inline.rb:85 `semx_link_parse` | link → `<eref target=>` | inline_transformer.rb:226 `build_link` | PORTED | |
| inline.rb:85-87 `semx_link_parse` (brackets) | `brackets=` attr from `@style` | — | MISSING | Finding 4 |
| inline.rb:92-101 `image_parse(_attrs)` | inline image → `<artwork src/title/align/name/anchor/type=svg/alt>` | figure_transformer.rb:117 `transform_image_to_artwork` + block_transformer.rb:684 | PARTIAL | src/alt/title kept; align, name(filename), anchor dropped; type=svg now conditional (improvement) — Finding 13 |
| inline.rb:103 `svg_parse` | embedded SVG → artwork wrapper | figure_transformer.rb:126-146 (data-URI decode) | PORTED | raw `<svg>` noted as 0.2.9 model gap, suppressed empty artwork |
| inline.rb:113 `semx_xref_parse` | `<xref target= format=>` | inline_transformer.rb:199 `build_xref` | PORTED | |
| inline.rb:113-115 (relative) | `relative=` on plain xref | — (only on eref path, inline_transformer.rb:53) | PARTIAL | Finding 5 |
| inline.rb:120 `get_linkend` | linkend keeps child MARKUP (to_xml), skips locality/location, unwraps display-text | inline_transformer.rb:220 `extract_xref_text` | PARTIAL | text-only — Finding 7 |
| inline.rb:131 `semx_eref_parse` | eref → `<xref target=bibitemid section= relative= sectionFormat=>`, linkend parsed | inline_transformer.rb:17 `build_eref_xref` | PORTED | linkend text-only (Finding 7); abstract-flatten branch matches released output per WS3 |
| inline.rb:147 `eref_relative` | fallback: `relative` from `locality[@type='anchor']/referenceFrom`; empty→nil (#269) | inline_transformer.rb:71-118 | PARTIAL | anchor localities explicitly skipped, never promoted to relative= — Finding 6; empty-drop itself ported |
| inline.rb:153 `eref_section` | section label via shared `eref_localities`, span-strip, Section/Clause-strip | inline_transformer.rb:100-132 | PORTED | local re-implementation (documented interim); connectives + ranges handled |
| inline.rb:163 `semx_origin_parse` | origin → termref render or eref render | term_transformer.rb:265-300 `transform_term_source` | PARTIAL | bibitemid → literal xref string; termref branch and origin locality unhandled (documented model ghost) — Finding 16 |
| inline.rb:171 `index_parse` | `<iref item= subitem=>` from primary/secondary child TEXT | block_transformer.rb:604 `build_iref_from_model` | PARTIAL | live builder assigns raw model accessor, not text; the text-safe `build_iref` (inline_transformer.rb:316) is dead code — Finding 14 |
| inline.rb:171-174 (primary attr) | `primary=` attribute on iref | — | DROPPED-BY-DESIGN | documented unreachable: model `:primary` accessor claimed by child element (0.2.9 ledger) |
| inline.rb:177 `bookmark_parse` | emit `<bookmark>` (later removed by cleanup) | block_transformer.rb:169-170 → nil | PORTED | net output identical (old bookmark_cleanup removed them all); but see cref interplay, Finding 1 |
| inline.rb:181 `span_parse` (bcp14 branch) | span class=bcp14 → `<bcp14>` | block_transformer.rb:135-143 | PORTED | |
| inline.rb:181-186 `span_parse` (else) | non-bcp14 span → children pass through | — (returns nil, element skipped) | MISSING | span content silently dropped — Finding 2 |
| footnotes.rb:3 `footnote_parse` | emit fnref + local fn | block_transformer.rb:649 `build_footnote_reference` | PORTED | numbering moved to build time |
| footnotes.rb:11 `make_local_footnote` | dedup repeated reference, emit body once | block_transformer.rb:656 (`@seen_footnotes[reference] ||=`) | PORTED | |
| footnotes.rb:20 `make_generic_footnote_text` | fn body: `<t anchor=first-p-id>` with FULL parsed children (markup), multi-block bodies | block_transformer.rb:667 `collect_footnote_content` | PARTIAL | plain paragraph text only; inline elements inside footnotes vanish; anchors dropped; non-`p` first-child bodies dropped — Finding 8 |
| footnotes.rb:35 `table_footnote_parse` | in-table/in-figure fn: inline " [ref]", body after table, dedup per tid+fn | block_transformer.rb:649 (same path via table cell element_order) | PARTIAL | dedup keyed globally by reference, not per table — Finding 9; figure-context fns unreachable |
| footnotes.rb:50 `make_table_footnote_link` | literal " [ref]" with leading space, authored label | block_transformer.rb:658 `"[#{num}]"` | PARTIAL | leading space lost, authored per-table label replaced by global number — Findings 9, 10 |
| footnotes.rb:54 `make_table_footnote_text` | "[ref]  " prefix + parsed body | section_transformer.rb:196-203 | PARTIAL | same text-flattening as Finding 8 |
| footnotes.rb:67 `get_table_ancestor_id` | per-table dedup key, UUID fallback | — | MISSING | subsumed in Finding 9 |
| cleanup_inline.rb:4 `u_cleanup` | wrap U+0080–FFFF in `<u>` under t/blockquote/li/dd/preamble/td/th/annotation, basic-entity encode | transformer.rb:85 `Transformer.u_cleanup` | PORTED | same parents, same range, post-serialization |
| cleanup_inline.rb:14 `footnote_cleanup` | move fn bodies to Endnotes, replace internal ref with "[n] " | section_transformer.rb:186 `build_endnotes` | PORTED | "[n] " prefix present; anchors not carried (Finding 11) |
| cleanup_inline.rb:26 `footnote_refs_cleanup` | document-wide sequential renumbering, fnref → " [n]" | block_transformer.rb:653-664 counter | PORTED | leading space lost — Finding 10 |
| cleanup_inline.rb:39 `make_endnotes` | create `<back>` if absent, append Endnotes section | section_transformer.rb:180-206 | PORTED | back always built; anchor="endnotes" added (harmless) |
| cleanup_inline.rb:49 `image_cleanup` | pull artwork out of `<t>` ANYWHERE, insert as next siblings of the t, marker "[IMAGE i]" per-paragraph | block_transformer.rb:684 + cleanup_transformer.rb:433-470 | PARTIAL | only direct section.t scanned; figure appended to section end, not adjacent — Finding 12 |
| cleanup_inline.rb:60 `bookmark_cleanup` | strip all bookmarks from output | block_transformer.rb:170 (never emitted) | PORTED | net-equivalent |
| cleanup_inline.rb:64,71,81 `cref_cleanup`/`cref_move`/`cref_unwrap` | relocate `cref[@from]` to its anchor's text node, unwrap inner `<t>`, wrap bare crefs in `<t>` | annotation_transformer.rb:19 `build_annotations` → `[]` | MISSING | entire reviewer-annotation (cref) pipeline is a stub — Finding 1 |

## Findings

1. **Reviewer annotations (cref) never emitted — whole pipeline stubbed.**
   (a) `cleanup_inline.rb:64-89` (`cref_cleanup`/`cref_move`/`cref_unwrap`), consuming crefs emitted by `blocks.rb:187 review_note_parse` (`out.cref anchor/display/source/from`).
   (b) Old output carried RFC XML `<cref>` comments placed at the text node of their `from=` anchor, unwrapped of inner `<t>`, wrapped in `<t>` when directly under section/abstract. New leg: `annotation_transformer.rb:19 build_annotations` returns `[]` unconditionally, so `section_transformer.rb:170` appends nothing; no other code constructs `Rfcxml::V3::Cref`. The gate `render_annotations?` (annotation_transformer.rb:8) is implemented but its payload is empty — reviewer notes vanish even when `render_document_annotations=true` or `notedraftinprogress`.
   (c) AsciiDoc reviewer note (`[reviewer=X]` review block) / presentation XML `<annotation reviewer="X" from="anchor">` → old: `<cref source="X">…</cref>` at the anchor; new: nothing.
   (d) Confidence: **high** (may be a known deferral, but it is live dropped functionality on this branch).

2. **Non-bcp14 `<span>` content dropped entirely.**
   (a) `inline.rb:181-187 span_parse` else-branch: `children_parse(node, out)`.
   (b) Old passed span children (text and elements) through unwrapped. New (`block_transformer.rb:135-139`) returns nil unless `class_attr == "bcp14"`; the element_order walk then skips the element and its content — the text is not even flattened.
   (c) Presentation XML `<t>before <span class="mycss">important words</span> after</t>` (e.g. AsciiDoc `span:mycss[...]`) → "important words" silently missing from output.
   (d) Confidence: **high**.

3. **`<br>` degraded to a newline character.**
   (a) `inline.rb:79 br_parse` → `out.br` element.
   (b) New maps `"br" => "\n"` string (block_transformer.rb:151-152); `Rfcxml::V3` Br objects are never built (though cleanup_transformer INLINE_ATTRS:39 anticipates a `:br` collection). RFC XML v3 permits `<br>` in `<td>/<th>`; a newline in mixed content is whitespace-collapsed by xml2rfc.
   (c) Table cell `<td>line1<br/>line2</td>` → old `<td>line1<br/>line2</td>`; new `line1 line2`.
   (d) Confidence: **medium-high** (genuine in-cell case; outside td/th the old `<br>` was itself schema-questionable).

4. **eref `brackets=` from link `style=` dropped.**
   (a) `inline.rb:85-90 semx_link_parse`: `out.eref target:, brackets: node["style"]`.
   (b) New `build_link` (inline_transformer.rb:226-235) sets only target and content; no brackets attribute anywhere in the new leg.
   (c) Presentation XML `<link target="https://x" style="angle"/>` → old `<eref target="https://x" brackets="angle"/>`; new plain `<eref>` — xml2rfc rendering of the bracket style lost.
   (d) Confidence: **medium** (depends on the presentation layer actually stamping `style=` on links; the old code read it deliberately).

5. **`relative=` dropped on plain (internal) xref.**
   (a) `inline.rb:113-115 semx_xref_parse`: `relative: node["relative"]`.
   (b) New `build_xref` (inline_transformer.rb:199-218) sets target/format/content only; `relative` is handled solely on the eref path.
   (c) Presentation XML `<xref target="X" relative="sect2">` → attribute lost.
   (d) Confidence: **medium-low** (rare construct on semantic xref; attr_code would have passed it through in old).

6. **Anchor-locality → `relative=` fallback on eref missing.**
   (a) `inline.rb:147-151 eref_relative`: `node["relative"] || node.at(.//locality[@type='anchor']/referenceFrom)&.text`.
   (b) New `extract_eref_locality` (inline_transformer.rb:71-118) derives relative only from the `relative` attribute; anchor localities are explicitly skipped in label building (line 103) and never promoted to `relative=`.
   (c) `<eref bibitemid="RFC9000"><localityStack><locality type="anchor"><referenceFrom>tls-anchor</referenceFrom></locality></localityStack></eref>` → old `<xref target="RFC9000" relative="tls-anchor"/>`; new `<xref target="RFC9000"/>` — deep link lost.
   (d) Confidence: **medium-high**.

7. **Mixed/nested inline content flattened to own-text.**
   (a) `inline.rb:4-32` (children_parse in em/strong/tt/sub/sup), `inline.rb:120-129 get_linkend` (keeps child markup via to_xml, unwraps display-text).
   (b) New simple-inline builder (ietf_to_rfc_v3.rb:181-196) uses nested recovery only when own text is empty; when an element has both text and element children, children are dropped (not even text-merged). Xref/eref link text (`extract_xref_text`/`extract_eref_text`) is text-only, so markup inside a linkend (`<xref…><display-text><tt>x</tt></display-text></xref>`) loses the `<tt>` (abstract-flatten path handles this; the normal path does not).
   (c) `<em>alpha <strong>beta</strong> gamma</em>` → old `<em>alpha <strong>beta</strong> gamma</em>`; new `<em>alpha  gamma</em>` (beta gone). Partly a documented metanorma-document 0.2.9 parse ghost, but the own-text-nonempty branch drops children the model *does* expose.
   (d) Confidence: **medium-high** for the text+children case; the pure-nested case is ported.

8. **Footnote bodies flattened to plain text; inline elements inside footnotes vanish.**
   (a) `footnotes.rb:20-33 make_generic_footnote_text`: fully parses footnote children (`parse(n, div)`), carries the first-p anchor, and handles non-`p` bodies and multi-block footnotes.
   (b) New `collect_footnote_content` (block_transformer.rb:667-680) reads only `fn_elem.p` and `extract_paragraph_text` (text fragments) — an eref/xref/link/em inside a footnote paragraph is dropped *including its text*; a footnote whose body is not `<p>` (e.g. a list) is dropped wholesale (`return unless ps`); the old `<t anchor=…>` on the endnote is not carried (see also 11).
   (c) AsciiDoc `footnote:[See <<RFC2119>> and https://example.com[site]]` → old endnote `[1] See <xref…/> and <eref…>site</eref>`; new endnote `[1] See  and` (or the footnote missing entirely if no bare text).
   (d) Confidence: **high**.

9. **Table-footnote dedup keyed globally by `reference`, not per table.**
   (a) `footnotes.rb:35-48,67-72`: dedup key is `tid + fn` (table ancestor id + reference; UUID fallback), precisely because table footnote references (`a`, `1`, …) repeat across tables.
   (b) New `build_footnote_reference` keys `@seen_footnotes[reference]` globally and `collect_footnote_content` returns early if the number is already collected — the *second* table's footnote with the same reference label reuses the first footnote's number and its distinct content is never emitted. Also: the old figure-context path (`@in_figure`) has no analogue (fn is only reached through paragraph/table-cell element_order). Authored per-table labels (`[a]`) are replaced by global sequential numbers — probably acceptable, but it is an output change.
   (c) Two tables each carrying a footnote with `reference="a"` but different text → old: two entries `[a]` scoped per table; new: both cells show `[1]`, second footnote's text lost.
   (d) Confidence: **high** for the collision; **medium** on how often the presentation layer reuses reference labels (the old code's tid guard is strong evidence it does).

10. **Leading space before footnote marker lost.**
    (a) `cleanup_inline.rb:34` `f.replace(" [#{fn[f.text]}]")` and `footnotes.rb:51` `out << " [#{fnref}]"`.
    (b) New emits `"[#{num}]"` with no leading space (block_transformer.rb:658,663), so the marker abuts the preceding word.
    (c) `text<fn reference="1">…</fn>` → old `text [1]`; new `text[1]`.
    (d) Confidence: **high** (cosmetic but a guaranteed textual diff).

11. **Endnote paragraph anchors dropped.**
    (a) `footnotes.rb:24` / `footnotes.rb:57`: `xml.t anchor: first["id"]`.
    (b) New `build_endnotes` (section_transformer.rb:196-203) emits anchor-less `<t>`; any xref targeting a footnote paragraph's id dangles.
    (c) Presentation XML footnote whose first `<p id="fnp1">` is cross-referenced elsewhere → broken target.
    (d) Confidence: **medium** (anchors were GUIDs, rarely targeted).

12. **Inline-image extraction only sweeps direct `section.t`; markers elsewhere never resolved.**
    (a) `cleanup_inline.rb:49-58 image_cleanup`: xpath `//t[descendant::artwork]` (any `<t>` anywhere), inserts the artwork as the *next sibling* of the paragraph.
    (b) New `image_cleanup` (cleanup_transformer.rb:433-470) walks only `section.t`; an inline image inside a list item, table cell, blockquote or aside leaves the literal `[IMAGE n]` marker in the text while the queued artwork is silently discarded. Additionally the recovered figure is `safe_append`ed to the section (end position) instead of adjacent to its paragraph, and numbering is global (`@image_counter`) where old restarted per paragraph — the marker/figure pairing survives, placement does not.
    (c) AsciiDoc list item containing `image::pic.svg[]` inline → new output text `… [IMAGE 1]` with no figure anywhere.
    (d) Confidence: **high** for the scope gap; placement drift **medium** severity.

13. **Inline-image artwork loses `align`, `name` (filename), `anchor`.**
    (a) `inline.rb:92-101 image_parse_attrs/image_parse`: artwork with src/title/align/name/anchor/type/alt.
    (b) New `transform_image_to_artwork` (figure_transformer.rb:117-175) maps src/alt/title only; no align, no name from filename, no anchor.
    (c) `<image src="a.svg" filename="a.svg" align="center" id="img1"/>` → old `<artwork … align="center" name="a.svg" anchor="img1"/>`; new bare `<artwork src=… type="svg"/>`.
    (d) Confidence: **medium-high** (attributes verifiably read by old code; `anchor` loss breaks xrefs to the image).

14. **Live iref builder bypasses the text-safe one; may assign raw model objects.**
    (a) `inline.rb:171-175 index_parse`: `item:` = primary child *text*, `subitem:` = secondary child *text*.
    (b) The dispatch (`block_transformer.rb:159-160`) calls `build_iref_from_model` (block_transformer.rb:604-613), which assigns `elem.primary`/`elem.secondary` directly — per the comment in `inline_transformer.rb:311-315` the model's `:primary` accessor is claimed by the child *element*, so this sets a model object (or array) as `item=`, not its text. The corrected, `ls_text`-based `build_iref` (inline_transformer.rb:316-329, with its WS3 comment) is **dead code** — no call site in the forward path.
    (c) AsciiDoc `((keyword,subterm))` → `<index><primary>keyword</primary><secondary>subterm</secondary></index>` → risk of `item=` serializing as object/inspect junk or empty, instead of `item="keyword" subitem="subterm"`.
    (d) Confidence: **medium** (wiring mismatch is certain; the serialized damage depends on the model vintage's accessor shape — the `primary="true"` attribute loss itself is documented DROPPED-BY-DESIGN).

15. **strike/smallcap markup children flattened to text.**
    (a) `inline.rb:44-50 strike_parse/smallcap_parse` (and `keyword_parse:52`): wrapper dropped but children *parsed*, so a nested xref/eref/link still emitted as an element.
    (b) New `build_dropped_inline` (block_transformer.rb:702-723) emits `ls_text` only; `keyword` uses `coll[idx].to_s` (object to_s, not ls_text — potential inspect-string leak).
    (c) `<strike>see <xref target="X"/></strike>` → old `see <xref target="X"/>`; new `see ` (xref gone).
    (d) Confidence: **medium**.

16. **Term-source origin: no termref branch, literal-string xref.**
    (a) `inline.rb:163-169 semx_origin_parse`: origin containing `<termref>` → `termrefelem_parse`; else full eref rendering (section/relative/sectionFormat).
    (b) New `transform_term_source` (term_transformer.rb:265-300) handles only the bibitemid case, by splicing a literal `"<xref target='…'/>"` string into `<t>` content (relies on the raw-serialization quirk to avoid escaping; fragile), with locality/section unmapped (documented 0.2.9 model ghost); origin-with-termref falls to `ls_text(origin)` plain text.
    (c) Term sourced from another terminology dataset (`termref`) → old rendered termref form; new bare flattened text; and any `[SOURCE: …]` with section info loses the section.
    (d) Confidence: **medium** (partly documented model limitation; the literal-markup-in-string mechanism is a robustness risk rather than a proven output break).
