<!-- TICKET DRAFT 06. Repo: metanorma/metanorma-ietf. Assignee: opoudjis. -->
<!-- Title: Transformer: table gaps — cell block content, @align, mixed header rows -->

Refs TRACKING-URL

1. **Block content in cells dropped — cell comes out EMPTY.** Empirically confirmed, worse than the audit claimed: an AsciiDoc `a|` cell containing a paragraph plus a bullet list serialises as an entirely empty `<td>` — even the leading paragraph is lost. `transform_table_cell` (table_transformer.rb:121-153) handles paragraphs, interleaved inlines, and bare text only; TableCell 0.2.9 carries ul/ol/dl/figure/sourcecode/table/note/quote accessors, all ignored. v3 td/th legally contain these blocks.
2. **table @align never copied.** Empirically confirmed, with the presentation-layer caveat resolved in the finding's favor: the semantic XML demonstrably carries `<table align="left">`, yet the output `<table>` has no align attribute at all.
3. **Mixed th/td header rows drop the td cells** (code-read, medium): table_transformer.rb:71-82 appends th cells for header rows and consults td only when there are no th — a thead row with both loses cells and breaks the column count.

## Specs required

`a|` cell with list + paragraph; `[align=left]` table; thead row mixing th/td.

🤖
