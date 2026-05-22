# 09: Reverse Transformer — References and Bibliography

## Problem

No reverse transformer for `<references>` / `<reference>` / `<referencegroup>` elements.

## Scope

### Reference structure
| RFC XML v3 | Metanorma XML |
|-----------|---------------|
| `references` | `bibliography/clause` |
| `reference/@anchor` | `bibitem/@id` |
| `reference/front/title` | `bibdata/title` |
| `reference/front/author` | `bibdata/contributor` |
| `reference/front/date` | `bibdata/date` |
| `reference/front/seriesInfo` | `bibdata/series` or `bibdata/docidentifier` |
| `reference/front/abstract` | `bibdata/abstract` |
| `referencegroup` | `relation[@type="includes"]` |

### SeriesInfo → docidentifier mapping
| seriesInfo name | docidentifier type |
|----------------|-------------------|
| `RFC` | `IETF RFC` |
| `Internet-Draft` | `IETF I-D` |
| `DOI` | `DOI` |
| `BCP` | `IETF BCP` |

### Reference annotations
| RFC XML v3 | Metanorma XML |
|-----------|---------------|
| `annotation` | `annotation` elements in bibitem |

## Dependencies

- TODO 01 (architecture)
- May require `relaton-ietf` for semantic enrichment of parsed references
