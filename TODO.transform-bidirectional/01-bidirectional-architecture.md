# 01: Bidirectional Transformer Architecture

## Problem

The current transformer is one-directional: `IetfToRfcV3` only handles Metanorma XML → RFC XML v3. There is no reverse transformer. The architecture is a single monolithic class with 13 mixins, ~4,400 lines total, using private APIs and XML string manipulation.

## Design

### 1. Introduce `Transform` protocol module

Define a `Transform` module that both directions implement:

```ruby
module Metanorma::Ietf::Transformer
  module Transform
    # @param input [String] XML string
    # @param options [Hash] transformation options
    # @return [String] transformed XML string
    def self.call(input, options = {})
      raise NotImplementedError
    end
  end
end
```

### 2. Split into two transformer classes under a common base

```
lib/metanorma/ietf/transformer/
  base.rb                    # Shared utilities (ls_text, to_ncname, etc.)
  ietf_to_rfc_v3.rb          # Forward: Metanorma XML → RFC XML v3 (refactored)
  rfc_v3_to_ietf.rb          # Reverse: RFC XML v3 → Metanorma XML (NEW)
```

`Base` holds:
- `ls_text`, `extract_text`, `escape_xml_text`, `to_ncname`, `to_array`, `anchor_for`
- `build_organization` (shared between forward and reverse)
- No state (no `@doc`, `@xrefs`, etc.) — those belong to the concrete transformers

### 3. Refactor `IetfToRfcV3` to extend `Base`

Move shared helpers to `Base`. Keep the 13 existing modules but:
- Each module becomes a standalone class or remains a mixin — but no more `send` to private lutaml-model APIs
- Replace `NullBibdata`/`NullExt` with proper null objects (see TODO 04)

### 4. Create `RfcV3ToIetf` (reverse transformer)

New class extending `Base` with its own modules:
- `RfcV3ToIetf::Metadata` — RFC attributes → bibdata
- `RfcV3ToIetf::Front` — `<front>` → Metanorma front matter
- `RfcV3ToIetf::Section` — `<middle>`/`<back>` → Metanorma sections
- `RfcV3ToIetf::Block` — paragraphs, sourcecode, etc.
- `RfcV3ToIetf::Inline` — xref, eref, cref, etc.
- `RfcV3ToIetf::Table` — tables
- `RfcV3ToIetf::Figure` — figures/artwork
- `RfcV3ToIetf::List` — lists
- `RfcV3ToIetf::Term` — terms/definitions
- `RfcV3ToIetf::Reference` — bibliography
- `RfcV3ToIetf::Cleanup` — post-processing

### 5. Update entry point

```ruby
module Metanorma::Ietf::Transformer
  def self.convert(xml_string, direction: :forward, options = {})
    case direction
    when :forward then Forward.call(xml_string, options)
    when :reverse then Reverse.call(xml_string, options)
    end
  end
end
```

## Files to modify/create

| File | Action |
|------|--------|
| `lib/metanorma/ietf/transformer/base.rb` | NEW — shared utilities |
| `lib/metanorma/ietf/transformer/ietf_to_rfc_v3.rb` | Refactor to extend Base |
| `lib/metanorma/ietf/transformer/rfc_v3_to_ietf.rb` | NEW — reverse transformer |
| `lib/metanorma/ietf/transformer.rb` | Update entry point with direction parameter |

## Dependencies

- TODO 02 (private API encapsulation) must be done first
- TODO 04 (NullBibdata replacement) should be done before refactoring
