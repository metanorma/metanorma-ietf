# Task 2: Fix extract_paragraph_text to use `text` attribute (not `content`)

## Problem
`extract_paragraph_text` in `inline_transformer.rb` calls `paragraph.content` but `ParagraphBlock` has no `content` attribute — it uses `text` (a string collection). This causes `NoMethodError` when forward-transforming MN XML that was produced by the reverse transformer (round-trip scenario).

## Root Cause
`ParagraphBlock` (from metanorma-document) maps `<p>` content to the `text` attribute (collection). The `content` attribute only exists on some other model types. The forward transformer was checking `content` first, which triggers lutaml-model's `method_missing` and raises.

## Fix Location
`lib/metanorma/ietf/transformer/inline_transformer.rb` — `extract_paragraph_text` method. Already partially fixed to use `paragraph.text`, but need to verify it's complete and no other callers depend on `content`.

## Status
Partially done — method was updated. Need to verify all callers work.
