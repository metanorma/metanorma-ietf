# 13: Refactor Forward Transformer for Code Quality

## Problem

The forward transformer works but has accumulated technical debt: 4,400 lines across 14 files, with mixed concerns, duplicated patterns, and code that could be cleaner.

## Issues to address

### 1. `cleanup_transformer.rb` is 605 lines — too large
Split into focused cleanup modules:
- `cleanup/li_unwrap.rb` — list item unwrapping (~50 lines)
- `cleanup/sourcecode.rb` — sourcecode post-processing (~40 lines)
- `cleanup/deflist.rb` — definition list cleanup (~60 lines)
- `cleanup/bcp14.rb` — BCP14 keyword detection (~40 lines)
- `cleanup/biblio.rb` — bibliography cleanup (~80 lines)
- `cleanup/cref.rb` — comment reference cleanup (~60 lines)
- `cleanup/aside.rb` — aside/annotation cleanup (~50 lines)
- `cleanup/figure.rb` — figure unnesting (~60 lines)
- `cleanup/unicode.rb` — Unicode wrapping (~30 lines)
- `cleanup/title.rb` — front title cleanup (~30 lines)

Or keep as one file but organize with clear section comments and extracted methods.

### 2. `ietf_to_rfc_v3.rb` has too many responsibilities
It's both the orchestrator AND a utility class. Move utilities to `Base`:
- `ls_text`, `extract_text`, `escape_xml_text` → `Base`
- `to_ncname`, `to_array`, `anchor_for` → `Base`
- `build_organization` → `Base`
- `get_paragraphs` → `Base`

### 3. Duplicated content extraction patterns
Multiple modules have their own text extraction logic. Consolidate into `Base`:
- `inline_transformer.rb` has `text_content`, `inline_text_content`
- `block_transformer.rb` has paragraph extraction
- `term_transformer.rb` has definition text extraction

### 4. `TEXT_BASED_TYPES` constant is fragile
`ietf_to_rfc_v3.rb:67-89` — a hardcoded list of 23 inline element types. This breaks when `metanorma-document` adds new types.

**Fix**: Add a common module/mixin to `metanorma-document` inline types that identifies them as text-based, or use duck-typing based on the presence of `.text` method (check with `defined?` or `is_a?`).

### 5. `get_paragraphs` (ietf_to_rfc_v3.rb:306-330) has type-checking spaghetti

**Fix**: Each node type should implement a uniform interface (e.g., `#paragraphs` or `#content_paragraphs`). Push this down to the model level.

## Dependencies

- TODO 02 (private API encapsulation) — do first to clean up `send` calls
- TODO 04 (null objects) — do first to clean up `NullBibdata`
- TODO 03 (XML string elimination) — do first to clean up string manipulation
