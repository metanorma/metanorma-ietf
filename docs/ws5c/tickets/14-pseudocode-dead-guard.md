<!-- TICKET DRAFT 14 (WS5c row 1). Repo: metanorma/metanorma-ietf. Assignee: opoudjis. -->
<!-- Title: Transformer: pseudocode figure dispatch is dead code (class_attr vs figure_class) -->

Refs https://github.com/metanorma/metanorma-ietf/issues/291

## Defect

`figure_transformer.rb:113-114` guards the pseudocode branch with `figure_node.class.method_defined?(:class_attr) && figure_node.class_attr == "pseudocode"`, but the reachable model class (`FigureBlock`, metanorma-document 0.2.9) maps XML `@class` to `:figure_class` and defines no `class_attr`. The guard is always false; `transform_pseudocode` is unreachable. `[pseudocode]` figures fall through to the generic figure path, which drops intra-figure paragraphs.

Aggravator: the suite has blessed the loss — `spec/feature/blocks_spec.rb:1168` ("processes pseudocode") expects an **empty** `<figure anchor="_"><name>Label</name></figure>`. The fix must correct that spec alongside the guard.

Found by the WS5c completeness audit (model-reflection joint), not WS5b: the static audit rated this path PARTIAL on the assumption the branch executes. Second instance of the dead-guard class (`:definition_lists` vs `:dl` was the first); the model-coverage exhaustiveness spec's dead-guard detector (WS5c deliverable) turns this class into a CI failure.

## Repro

AsciiDoc `[pseudocode]` example block with formatted lines → RFC XML contains an empty figure; old leg rendered the content as sourcecode.

## Specs required

Pseudocode figure with paragraphs/indentation renders its content; the blessed-empty expectation replaced; guard probes an accessor that exists (or dispatches on `figure_class` directly).

🤖
