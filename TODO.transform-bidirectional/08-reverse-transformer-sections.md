# 08: Reverse Transformer — Sections, Blocks, and Inline Elements

## Problem

No reverse transformer for `<middle>` and `<back>` content.

## Scope

### Section structure
| RFC XML v3 | Metanorma XML |
|-----------|---------------|
| `rfc/middle/section` | `sections/clause` |
| `rfc/middle/section/section` | nested `clause` |
| `rfc/back/section` | `annex/clause` or back `clause` |
| `@anchor` | `@id` |
| `@title` | `title` |

### Block elements
| RFC XML v3 | Metanorma XML |
|-----------|---------------|
| `t` | `p` |
| `t/@anchor` | `@id` |
| `figure` | `figure` |
| `figure/name` | `figure/name` |
| `artwork` | `image` (for SVG) or `sourcecode` (for text) |
| `sourcecode` | `sourcecode` |
| `blockquote` | `quote` |
| `aside` | `note` |
| `note` | `note` |

### Inline elements
| RFC XML v3 | Metanorma XML |
|-----------|---------------|
| `xref` | `xref` |
| `eref` | `eref` |
| `cref` | `annotation` |
| `strong` | `strong` |
| `em` | `em` |
| `tt` | `tt` |
| `sub` | `sub` |
| `sup` | `sup` |
| `spanx[@style="emph"]` | `em` |
| `spanx[@style="strong"]` | `strong` |
| `spanx[@style="verb"]` | `tt` |
| `contact` | person reference |

### List elements
| RFC XML v3 | Metanorma XML |
|-----------|---------------|
| `ul` | `ul` |
| `ol` | `ol` |
| `dl` | `dl` |
| `li` | `li` |
| `dt` | `dt` |
| `dd` | `dd` |

### Table elements
| RFC XML v3 | Metanorma XML |
|-----------|---------------|
| `table` | `table` |
| `thead` | `thead` |
| `tbody` | `tbody` |
| `tfoot` | `tfoot` |
| `tr` | `tr` |
| `td` | `td` |
| `th` | `th` |

## Implementation approach

Each element type gets a `transform_*` method that takes a `Rfcxml::V3::*` model object and returns a `Metanorma::Document::*` model object. Content recursion handles nesting.

```ruby
module Metanorma::Ietf::Transformer::RfcV3ToIetf
  module BlockTransformer
    def transform_t(t_node)
      p = Metanorma::Document::Components::Blocks::ParagraphBlock.new
      p.id = t_node.anchor
      # Build inline content from t_node's mixed content
      p.content = transform_inline_content(t_node.content)
      p
    end
  end
end
```

## Dependencies

- TODO 01 (architecture)
- Requires detailed knowledge of `Rfcxml::V3` and `Metanorma::Document` model APIs
