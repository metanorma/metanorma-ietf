<!-- TICKET DRAFT 17 (WS5c row 6, probe-escalated). Repo: metanorma/metanorma-ietf. Assignee: opoudjis. -->
<!-- Title: Transformer: a concept in body text crashes the whole conversion -->

Refs https://github.com/metanorma/metanorma-ietf/issues/291

## Defect (conversion abort)

A `concept` in an ordinary body paragraph kills the forward conversion with an unrescued `NoMethodError`. The presentation stage renders the concept fine but retains the semantic `<concept>` as a paragraph sibling; the model's `element_order` for the paragraph includes the `concept` tag; `build_interleaved_content` (block_transformer.rb:95) has no `INLINE_TAG_MAP` entry for it and falls through to `safe_append(text_elem, :concept, …)` (ietf_to_rfc_v3.rb:145), which calls a nonexistent `concept` accessor on `Rfcxml::V3::Text`:

```
lutaml/model/serialize.rb:186: undefined method 'concept' for an instance of Rfcxml::V3::Text (NoMethodError)
```

Empirically confirmed (WS5c probe 3): both eref-carrying and termref-carrying concepts are equally fatal — the failure is tag-level, before children matter. The suite and corpus never exercise a concept outside terms sections, which is why this survived every green run.

Related but separate: `build_concept` (#300 family) handles terms-section concepts; the model-side carrier ghosts (`@ref`/`@linkmention`/eref/termref children unmapped) are recorded for the metanorma-document follow-up.

## Repro

Any AsciiDoc body paragraph with `{{term}}` concept markup → conversion aborts, no output file.

## Fix shape

At minimum: `safe_append` must not crash on unmapped tags (skip + warn); properly: consume the presented `fmt-concept` rendering in interleaved content.

## Specs required

Body-paragraph concept (both flavors) converts without error and renders the presented text; unmapped-tag fall-through path covered by a no-crash spec.

🤖
