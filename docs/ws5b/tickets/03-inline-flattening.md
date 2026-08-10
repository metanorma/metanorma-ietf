<!-- TICKET DRAFT 03. Repo: metanorma/metanorma-ietf. Assignee: opoudjis. -->
<!-- Title: Transformer: inline markup content lost in titles, captions, and mixed inline content (ls_text flattening) -->

Refs TRACKING-URL

## Defect

`ls_text`-based extraction returns only a model element's string runs, so wherever it feeds output, child-element content is not merely flattened to text — it disappears. Surfaces:

- Section/annex titles: `section_transformer.rb:225-231`. Empirically confirmed: `== Plain _emphasized_ tail` → `<name>Plain  tail</name>` — the word "emphasized" is gone from the document. Same mechanism in terms-section titles (term_transformer.rb:12-18) and term designations (term_transformer.rb:229).
- Figure/example captions: figure_transformer.rb:18-24, block_transformer.rb:274. (Table captions are the ledgered 0.2.9 NameWithIdElement model gap — tracked separately.)
- Front note names: front_transformer.rb:538-547.
- Mixed inline content: the simple-inline builder (ietf_to_rfc_v3.rb:181-196) walks nested children only when own text is EMPTY; `<em>alpha <strong>beta</strong> gamma</em>` → `<em>alpha  gamma</em>` (code-read, medium-high confidence).
- strike/smallcap/keyword: `build_dropped_inline` (block_transformer.rb:702-723) emits text only; a nested xref inside `<strike>` vanishes. `keyword` uses `.to_s` — potential inspect-string leak.
- dt inline coverage: `build_dt_inline` (list_transformer.rb:191-207) handles simple inlines + xref/eref only; link/stem/br content in a `<dt>` is omitted.

v3 `<name>` legally contains inline elements — full fidelity is available, and where structure is genuinely unrepresentable the text content must at minimum be preserved.

## Specs required

Emphasis inside a section title; xref inside a figure caption; `<em>text <strong>nested</strong> tail</em>` mixed content; xref inside strike; link inside dt. Each asserting content preservation at minimum, structure where legal.

🤖
