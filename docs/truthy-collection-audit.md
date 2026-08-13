# Truthy-collection guard audit — 2026-07-19

Method: cross-reference metanorma-document attributes declared
`collection: true` (129 of them) against transformer sites that assign
`var = node.<attr>` and then guard with bare truthiness (`if var` /
`var &&`). Every hit can silently short-circuit on `[]` (empty but
truthy) — the N1 defect class.

| Site | Guarded attr | Risk note |
|---|---|---|
| base.rb:146 | .content | generic text extraction — shared plumbing |
| base.rb:151 | .text | generic text extraction — shared plumbing |
| block_transformer.rb:232 | .content | N1 site — blank-guarded 674ee05 |
| figure_transformer.rb:19 | .name | figure captions |
| figure_transformer.rb:76 | .source | figure sources |
| front_transformer.rb:49 | .series | N9 territory |
| front_transformer.rb:63 | .series | N9 territory |
| inline_transformer.rb:166 | .math | prime N13 suspect (formula drop) |
| list_transformer.rb:56 | .text | list item text |
| metadata_transformer.rb:73 | .series | N9 territory |
| metadata_transformer.rb:89 | .series | N9 territory |
| annotation_transformer.rb:93 | .content | annotation bodies |
| table_transformer.rb:18 | .name | table captions |
| table_transformer.rb:82 | .th | header cells |
| term_transformer.rb:40 | .clause | term clauses |
| term_transformer.rb:227 | .origin | term sources |
| term_transformer.rb:263 | .preferred | preferred terms |

Disposition: each site needs either a blank-guard (as in N1's fix) or
demonstration that the attribute cannot be empty-non-nil there. Work
through construct-by-construct during WS-R, with the content-conservation
invariant spec as the dynamic net underneath.
