# 14: Round-Trip Fidelity Testing and Fixes

## Problem

Once both directions are implemented, we need to verify that transformations are lossless (or at least document where loss is acceptable).

## Strategy

### Phase 1: Forward fidelity
Start with Metanorma XML → RFC XML → verify output matches expected RFC XML.

This is already tested by `spec/transformer/transformer_spec.rb` but needs expansion.

### Phase 2: Reverse fidelity
Start with RFC XML → Metanorma XML → verify output is valid and complete.

### Phase 3: Round-trip fidelity
```
Metanorma XML → RFC XML → Metanorma XML → RFC XML
                 ^                          ^
                 |________ compare _________|
```

The two RFC XML outputs should be semantically equivalent (may differ in whitespace, attribute ordering, etc.).

### Known acceptable losses
- Auto-generated UUIDs/anchors will differ on each transformation
- Whitespace normalization
- Attribute ordering (XML attribute order is not significant)
- Default values may be omitted on one side

### Known problematic areas
- BCP14 keywords in `<strong>` vs `<span class="bcp14">`
- Image data (SVG content may not round-trip through string encoding)
- Cross-reference targets (ID mapping between formats)
- Annotation content (complex nested structures in crefs)

## Implementation

1. Create a `RoundTripTest` helper that:
   - Transforms forward, captures output
   - Transforms reverse, captures output
   - Transforms forward again, captures output
   - Compares first and second forward outputs (normalized)

2. Run on all fixtures in `spec/fixtures/`

3. Document any intentional losses in a `FIDELITY.md` file

## Dependencies

- All reverse transformer modules (TODOs 06-11)
- TODO 12 (spec coverage)
