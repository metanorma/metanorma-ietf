# 07: Reverse Transformer — Front Matter

## Problem

No reverse transformer for `<front>` element: RFC XML v3 `<front>` → Metanorma XML front matter.

## Scope

### Title
| RFC XML v3 | Metanorma XML |
|-----------|---------------|
| `front/title` | `bibdata/title[@type="main"]` |
| `front/title/@ascii` | `bibdata/title[@type="main"]/formatted-initials` |
| `front/seriesInfo[@stream]` | `bibdata/ext/stream` |

### Authors
| RFC XML v3 | Metanorma XML |
|-----------|---------------|
| `front/author/@fullname` | `bibdata/contributor/person/name/completename` |
| `front/author/@surname` | `bibdata/contributor/person/name/surname` |
| `front/author/@initials` | `bibdata/contributor/person/name/formatted-initials` |
| `front/author/organization` | `bibdata/contributor/organization/name` |
| `front/author/organization/@ascii` | `bibdata/contributor/organization/name/@ascii` |
| `front/author/organization/@abbrev` | `bibdata/contributor/organization/abbreviation` |
| `front/author/address/email` | `bibdata/contributor/person/email` |
| `front/author/address/uri` | `bibdata/contributor/person/uri` |
| `front/author/@role="editor"` | `bibdata/contributor/role[@type="editor"]` |

### Date
| RFC XML v3 | Metanorma XML |
|-----------|---------------|
| `front/date/@year` | `bibdata/date[@type="published"]` |
| `front/date/@month` | `bibdata/date[@type="published"]` |

### Series
| RFC XML v3 | Metanorma XML |
|-----------|---------------|
| `front/seriesInfo[@name="RFC"]` | `bibdata/series/title` + `bibdata/series/number` |
| `front/seriesInfo[@name="Internet-Draft"]` | `bibdata/series` |

### Area/Workgroup
| RFC XML v3 | Metanorma XML |
|-----------|---------------|
| `front/area` | `bibdata/ext/editorialgroup/committee-group[@type="area"]` |
| `front/workgroup` | `bibdata/ext/editorialgroup/committee-group[@type="workgroup"]` |

### Abstract
| RFC XML v3 | Metanorma XML |
|-----------|---------------|
| `front/abstract` | `bibdata/abstract` |

### Keywords
| RFC XML v3 | Metanorma XML |
|-----------|---------------|
| `front/keyword` | `bibdata/keyword` |

## Dependencies

- TODO 01 (architecture) and TODO 06 (metadata)
