# 11: Reverse Transformer — Cleanup and Validation

## Problem

The reverse transformer needs its own cleanup pass to normalize the Metanorma XML output.

## Scope

### Cleanup operations
1. **Remove generated IDs** — RFC XML anchors that were auto-generated (UUIDs) should be stripped
2. **Normalize whitespace** in text content
3. **Fix cross-references** — map RFC XML `xref/@target` back to Metanorma `xref/@target` (ID mapping)
4. **Reconstruct bibdata** — ensure complete bibdata from parsed front matter
5. **Validate output** — verify Metanorma XML schema compliance

### Validation
- Verify the output can round-trip: `from_rfc(to_rfc(xml))` produces equivalent RFC XML
- Validate against Metanorma XML schema (if available)

## Dependencies

- All reverse transformer modules (06-10)
