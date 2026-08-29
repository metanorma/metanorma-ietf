# Bidirectional Transformer TODOs

Execution order (dependencies indicated):

## Foundation (do first)
1. **Bidirectional Architecture** — shared `Base`, `RfcV3ToIetf` class, entry point update
2. **Encapsulate lutaml-model Private API** — replace `send` with public API / `public_send`
3. **Eliminate XML String Manipulation** — 9 locations building XML via strings
4. **Replace NullBibdata/NullExt** — explicit null objects instead of `method_missing`
5. **Remove Nokogiri from Validation** — isolate or replace with moxml

## Reverse Transformer (RFC XML v3 → Metanorma XML)
6. **Reverse: Metadata** — RFC root attributes → bibdata
7. **Reverse: Front Matter** — title, authors, date, series, area, workgroup, abstract, keywords
8. **Reverse: Sections, Blocks, Inline** — middle/back content, all element types
9. **Reverse: References** — bibliography sections, reference groups
10. **Reverse: Terms** — definition lists → term entries
11. **Reverse: Cleanup & Validation** — normalize output, verify schema

## Quality & Testing
12. **Spec Coverage** — unit tests per module, edge cases, reverse direction tests
13. **Refactor Forward Transformer** — split cleanup, consolidate utilities, fix TEXT_BASED_TYPES
14. **Round-Trip Fidelity** — verify lossless transformation, document acceptable losses
