# 12: Comprehensive Spec Coverage

## Problem

Current specs only test the forward direction. The reverse transformer needs full spec coverage, and the forward transformer needs improved coverage.

## Existing specs
- `spec/transformer/transformer_spec.rb` — fixture-based tests for forward direction (example RFC + antioch I-D)
- `spec/isodoc/ref_spec.rb` — reference rendering specs (IsoDoc layer)

## New specs needed

### Forward direction improvements
1. **Unit tests per transformer module** — each of the 13 modules should have focused unit tests
2. **Edge case coverage**:
   - Documents with no bibdata
   - Empty sections, empty paragraphs
   - Deeply nested structures (sections in sections)
   - Mixed inline content with complex element ordering
   - Tables with colspan/rowspan
   - Figures with multiple artwork elements
   - Bibliography with reference groups
   - Annexes
   - Terms with complex definitions

### Reverse direction (NEW)
1. **Fixture-based tests**:
   - Parse existing RFC XML v3 fixture files, transform to Metanorma XML, validate output
   - Use the same fixtures from forward tests for round-trip verification
2. **Unit tests per reverse module**:
   - `metadata_reverse_spec.rb` — RFC attributes → bibdata
   - `front_reverse_spec.rb` — front matter
   - `section_reverse_spec.rb` — section structure
   - `block_reverse_spec.rb` — blocks
   - `inline_reverse_spec.rb` — inline elements
   - `table_reverse_spec.rb` — tables
   - `list_reverse_spec.rb` — lists
   - `reference_reverse_spec.rb` — bibliography
   - `term_reverse_spec.rb` — terms

### Round-trip tests
1. **Forward → Reverse → Forward**: Start with Metanorma XML, transform to RFC XML, transform back, transform forward again. Compare first RFC XML output with second.
2. **Reverse → Forward → Reverse**: Start with RFC XML, transform to Metanorma XML, transform forward, transform back. Compare first Metanorma XML with second.

## Test infrastructure
- Use `Canon` (profile: `:metanorma`) for XML comparison
- Use `strip_guid` to normalize generated IDs
- Create shared fixture files in `spec/fixtures/transformer/`
