# Task 3: Fix duplicate anchors and invalid anchor attributes in round-trip RFC XML

## Problem
When round-tripping (RFC XML → reverse → forward → RFC XML), the output has:
1. **Duplicate anchors** — same UUID appearing on multiple elements (e.g., `_d36058ae...` on multiple `<t>` elements)
2. **Invalid `anchor` on `<t>`** — RFC XML v3 `<t>` element does NOT support `anchor` attribute, but the forward transformer is generating `<t anchor="...">` 

xml2rfc errors:
```
Error: Invalid attribute anchor for element t, at /rfc/middle/section[1]/t[5]
Error: Duplicate xsd:ID attribute anchor="_d36058ae-..." found.
```

## Root Cause
The forward transformer's `transform_paragraph` (or `transform_t`) sets `anchor` on `<t>` elements. In RFC XML v3, only `<section>`, `<figure>`, `<table>`, `<ul>`, `<ol>`, `<references>` etc. support `anchor` — NOT `<t>`.

The duplicate anchors happen because the reverse transformer preserves IDs in the MN XML, and then the forward transformer re-applies those same IDs, but the MN XML model has `id` on `ParagraphBlock` which maps to both the paragraph's `id` AND gets used as an RFC anchor.

## Fix Location
1. `lib/metanorma/ietf/transformer/block_transformer.rb` — `transform_paragraph` must NOT set `anchor` on `<t>` elements
2. Check all element types in forward transformer that set `anchor` — verify they only do so for RFC v3 elements that support it

## Verification
- Round-trip example.xml through forward→reverse→forward→xml2rfc with exit 0 and 0 errors
- No "Invalid attribute anchor" errors
- No "Duplicate xsd:ID" warnings
