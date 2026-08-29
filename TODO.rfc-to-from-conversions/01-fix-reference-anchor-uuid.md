# Task 1: Fix bibliography reference anchors using UUIDs instead of original IDs

## Problem
When forward-transforming ADOC input with `[bibliography] == References * [[[RFC2119,Key Words]]] ...`, the reference anchor in RFC XML output is a UUID like `_302856a2-5468-3783-9d82-c075e1073e0b` instead of the expected `RFC2119`. This causes xml2rfc to emit:
```
Warning: Unused reference: There seems to be no reference to [_302856a2-...]
```

## Root Cause
The forward transformer's reference_transformer.rb likely doesn't extract the original `id` or anchor from the `<bibitem id="RFC2119">` element in semantic XML, instead generating a new UUID.

## Fix Location
`lib/metanorma/ietf/transformer/reference_transformer.rb` — the `transform_bibitem` or equivalent method that creates `<reference>` elements must use the bibitem's `id` attribute as the RFC XML `anchor`.

## Verification
- Run the full ADOC integration spec
- xml2rfc should have 0 warnings about unused references
- The `<reference anchor="RFC2119">` should appear in RFC XML output
