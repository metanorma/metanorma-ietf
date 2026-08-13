# 02: Encapsulate lutaml-model Private API Calls

## Problem

The transformer calls two private lutaml-model methods via `send`:

1. **`track_order`** (called in `ietf_to_rfc_v3.rb:270`) — registers element order for mixed-content serialization
2. **`build_order_entry`** (called in `ietf_to_rfc_v3.rb:276`) — creates order entries for tag-based tracking

These are private to lutaml-model. Using `send` breaks encapsulation and makes the code fragile.

## Current code

```ruby
# ietf_to_rfc_v3.rb:267-277
def track_element_order(target, attr, value)
  target.send(:track_order, attr, value, nil)
end

def build_order_entry_for(target, tag)
  target.send(:build_order_entry, tag, nil, nil)
end
```

Additionally, 16 other `send` calls use dynamic attribute access:

```ruby
# ietf_to_rfc_v3.rb:248-251 (safe_append)
coll = obj.send(attr_name)
obj.send(:"#{attr_name}=", [])
coll = obj.send(attr_name)
```

```ruby
# list_transformer.rb:45-46
val = source.send(attr)
target.send(:"#{attr}=", val.to_s)

# cleanup_transformer.rb (multiple locations)
val = li.send(attr)
target.send(:"#{attr}=", tgt_val)
section.send(list_attr).each { ... }
```

## Solution

### A. Public API for element ordering in lutaml-model

Request or add public methods to lutaml-model's `Lutaml::Model::Serializable`:

```ruby
# Option 1: Make track_order and build_order_entry public
# These are stable APIs used by Builder internally — they should be public.

# Option 2: Add high-level public methods:
module Lutaml::Model::Serializable
  # Public wrapper for track_order
  def register_element_order(attr, value, index = nil)
    track_order(attr, value, index)
  end

  # Public wrapper for build_order_entry
  def create_order_entry(tag, index = nil, value = nil)
    build_order_entry(tag, index, value)
  end
end
```

### B. Replace dynamic attribute `send` with lutaml-model's public API

For `safe_append` and similar dynamic access patterns, lutaml-model models already respond to standard Ruby attribute accessors. Replace:

```ruby
# Before
obj.send(attr_name)
obj.send(:"#{attr_name}=", [])

# After — use public_send for attribute read/write
obj.public_send(attr_name)
obj.public_send(:"#{attr_name}=", [])
```

`public_send` is acceptable for dynamic dispatch where the attribute name is computed. It respects visibility and is the standard Ruby idiom. The key constraint is: never use `send` to bypass private/protected visibility.

### C. Eliminate all `send` calls to private methods

Replace all 18 `send` calls:

| Location | Current | Replacement |
|----------|---------|-------------|
| `ietf_to_rfc_v3.rb:270` | `target.send(:track_order, ...)` | `target.register_element_order(...)` (public API) |
| `ietf_to_rfc_v3.rb:276` | `target.send(:build_order_entry, ...)` | `target.create_order_entry(...)` (public API) |
| `ietf_to_rfc_v3.rb:248,250,251` | `obj.send(attr_name)` | `obj.public_send(attr_name)` |
| `list_transformer.rb:45-46` | `source.send(attr)` | `source.public_send(attr)` |
| `cleanup_transformer.rb` (11 calls) | Various `send` | `public_send` |
| `metadata_transformer.rb:62` | `pi.public_send(key)` | Already `public_send` — OK |

## Files to modify

| File | Change |
|------|--------|
| `ietf_to_rfc_v3.rb` | Replace 5 `send` calls |
| `list_transformer.rb` | Replace 2 `send` calls |
| `cleanup_transformer.rb` | Replace 11 `send` calls |

## Verification

- All existing specs pass
- No `send(` in transformer code (grep confirms)
