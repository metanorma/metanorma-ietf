# 10: Reverse Transformer — Terms and Definitions

## Problem

No reverse transformer for `<section>` elements that contain term definitions (RFC XML v3 doesn't have explicit term markup — terms are represented as definition lists with specific formatting conventions).

## Scope

### Term identification
In RFC XML v3, terms are typically:
- Sections with `<dl>` where `<dt>` is the term and `<dd>` is the definition
- Or sections marked as terminology sections by convention

### Mapping
| RFC XML v3 | Metanorma XML |
|-----------|---------------|
| Section with term DL | `terms/term` |
| `dt` | `preferred/expression/name` |
| `dd` | `definition/verbal-definition/p` |
| `dd` with multiple paragraphs | Multiple `p` elements |

## Dependencies

- TODO 01, TODO 08
