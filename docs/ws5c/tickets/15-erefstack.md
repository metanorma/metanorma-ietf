<!-- TICKET DRAFT 15 (WS5c row 11). Repo: metanorma/metanorma-ietf. Assignee: opoudjis. -->
<!-- Title: erefstack is never rendered (model-ghosted; parity with released leg) -->

Refs https://github.com/metanorma/metanorma-ietf/issues/291

## Gap

`erefstack` (stacked external references) is fully ghosted at model level — unmapped as an element and as a child of `related`/`concept` — so stacked erefs vanish silently at parse. Output parity holds: the released renderer had no `erefstack` handler either, so this construct has never rendered in the IETF flavor; adjudicated as worth fixing regardless (WS5c row 11 ruling).

## Dependencies

Model-blocked: needs an `erefstack` mapping in metanorma-document (0.5.x-batch family) before the transformer can render it; transformer-side rendering (sequence of xrefs/erefs with connectives) follows.

## Specs required

An erefstack of two erefs renders both references with their connective; erefstack inside `related`/`concept` contexts.

🤖
