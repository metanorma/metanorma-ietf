<!-- TICKET DRAFT 08. Repo: metanorma/metanorma-ietf. Assignee: opoudjis. -->
<!-- Title: Transformer: quote/admonition/note/example lose non-paragraph children -->

Refs TRACKING-URL

Empirically confirmed in one probe — all four container shapes lose their content, leaving only skeletons/labels:

- blockquote containing a `ul` → `<blockquote/>` (transform_quote, block_transformer.rb:431-434 walks paragraphs only; v3 blockquote admits ul/ol/dl/sourcecode/figure)
- admonition containing a `ul` → aside with only the `CAUTION` label `<t>` (block_transformer.rb:464-467, paragraphs only)
- note containing `sourcecode` → empty `<aside/>` (block_transformer.rb:192-228 covers p/dl/ul/ol only)
- example containing a `note` → only the `EXAMPLE` label `<t>` (EXAMPLE_CHILD_ATTRS lacks note/quote/formula — the F7 fix added sourcecode/figure/lists/tables but not these three)

The retired renderer parsed all children of these containers generically.

## Specs required

One spec per container shape above, asserting child content present in output.

🤖
