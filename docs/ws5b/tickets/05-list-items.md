<!-- TICKET DRAFT 05. Repo: metanorma/metanorma-ietf. Assignee: opoudjis. -->
<!-- Title: Transformer: list-item gaps — anchors, nested dl, block children, source order -->

Refs TRACKING-URL

All empirically confirmed by probes against `transform_list_item` (list_transformer.rb:57-106):

1. **li anchors never emitted.** `<li id="itemid">` → no `anchor=` on the output `<li>`, while `<xref target="itemid"/>` survives → dangling IDREF (xml2rfc error). The model maps `anchor` (ListItem, 0.2.9); the transformer never assigns it.
2. **Nested dl inside li dropped — dead guard.** The branch gates on `item.class.method_defined?(:definition_lists)`, but ListItem's accessor is `:dl` — the branch can never fire. End-to-end probe: `* item` + continuation `term:: definition` → the dl vanishes.
3. **Block children of li dropped.** ListItem 0.2.9 carries figure/table/note/quote/example/formula accessors; the transformer handles only text/p/ul/ol/(dead)dl/sourcecode. Probe: li with attached quote + NOTE + table via `+` continuation → all three gone.
4. **Child order grouped by type, not source order.** Probe: li with p → ul → p emits `<t>`, `<t>`, `<ul>` — the trailing paragraph is serialized before the sublist. The dd side got exactly this fix (`build_dd_ordered`); li never did.

## Specs required

Anchored li with xref to it; dl under li; each block type under li; p/sublist/p ordering.

🤖
