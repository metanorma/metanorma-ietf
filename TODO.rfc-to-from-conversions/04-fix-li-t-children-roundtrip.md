# Task 4: Fix `<li>` containing `<t>` children in round-trip

## Problem
xml2rfc error:
```
Error: Element li has extra content: t, at /rfc/middle/section[1]/ul[4]/li[1]/t
```

In RFC XML v3, `<li>` can contain `<t>` but the xml2rfc error suggests a structural issue. This happens in the round-trip output.

## Root Cause
The reverse transformer creates paragraph blocks inside list items. When forward-transforming back, those paragraphs become `<t>` inside `<li>`, but the surrounding structure may be wrong — e.g., the `<t>` should be a direct child of `<li>` but there might be extra wrapping, or the `<li>` has mixed content that isn't allowed.

Need to inspect the actual round-trip XML to see the exact structure.

## Fix Location
- Likely `lib/metanorma/ietf/transformer/list_transformer.rb` — how list items with paragraph children are transformed
- Possibly `lib/metanorma/ietf/transformer/rfc_v3_to_ietf/list_transformer.rb` — how reverse transformer creates list item content

## Verification
- Round-trip example.xml → xml2rfc exit 0
- No "Element li has extra content" errors
