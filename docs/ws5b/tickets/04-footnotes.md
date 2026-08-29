<!-- TICKET DRAFT 04. Repo: metanorma/metanorma-ietf. Assignee: opoudjis. -->
<!-- Title: Transformer: footnote content losses and table-footnote numbering collision -->

Refs TRACKING-URL

All empirically confirmed by probes:

1. **Bodies flattened, inline content vanishes including its text.** `collect_footnote_content` (block_transformer.rb:667-680) reads only `fn_elem.p` text fragments. Probe: footnote `See <em>emphatic</em> and <link…>site</link> tail` → endnote `[1] See  and  tail`. Old leg parsed footnote children fully (footnotes.rb:20-33 on main).
2. **Non-paragraph footnote bodies dropped wholesale.** A footnote whose body is a `<ul>` gets a `[2]` marker in the text but NO endnote body at all (`return unless ps`).
3. **Table-footnote dedup keyed globally by `reference`.** `@seen_footnotes[reference]` (block_transformer.rb:656): two tables each with `fn reference="a"` but different text → both cells `[1]`, second table's content absent from the document. Old leg keyed per-table (`tid + fn`, footnotes.rb:35-48,67-72) precisely against this.
4. **Leading space before markers lost.** `"[#{num}]"` (block_transformer.rb:658) → `text[1]`; old emitted `text [1]`.
5. **Endnote paragraph anchors dropped** (section_transformer.rb:196-203): xrefs targeting a footnote paragraph id dangle (code-read, medium).

## Specs required

Footnote with inline markup (content preserved); list-bodied footnote; two tables with same-labelled distinct footnotes (both texts present, distinct numbers); marker spacing.

🤖
