<!-- COMMENT DRAFT for metanorma-ietf#295 (tables). -->
WS5c completeness-audit additions (adjudicated 2026-08-08):

- `thead`/`tbody`/`tfoot` never carry `@anchor` — an xref targeting an anchored row group dangles (`transform_table_section` drops the source id while table/tr/td all keep theirs).
- `td`/`th`/`tr` `@anchor` is additionally **unmapped at model level** (metanorma-document mapping gap — tracked in the model follow-up ticket), so cell-level anchors need the model addition before the transformer can carry them.

🤖
