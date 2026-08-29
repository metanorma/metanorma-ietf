# 04: Replace NullBibdata and NullExt with Proper Null Objects

## Problem

Two Null Object pattern implementations use `method_missing` and `respond_to_missing?` to silently swallow all method calls. This:
- Breaks `respond_to?` (it says yes to everything, but most methods return nil)
- Hides real bugs when bibdata is missing expected attributes
- Makes debugging impossible (no error when accessing a typo'd attribute)
- Violates the "no respond_to" rule

## Current code

### `NullBibdata` (ietf_to_rfc_v3.rb:158-166)
```ruby
class NullBibdata
  def method_missing(name, *args, &block)
    nil
  end

  def respond_to_missing?(name, include_private = false)
    true
  end
end
```

### `NullExt` (metadata_transformer.rb:20-27)
```ruby
class NullExt
  def method_missing(name, *args)
    nil
  end

  def respond_to_missing?(name, include_private = false)
    true
  end
end
```

## Solution

Replace with explicit null objects that define exactly the attributes accessed by the transformer. This makes the contract clear and fails loudly on typos.

```ruby
# lib/metanorma/ietf/transformer/null_bibdata.rb
module Metanorma::Ietf::Transformer
  class NullBibdata
    def doctype; nil end
    def docnumber; nil end
    def title; nil end
    def language; nil end
    def docidentifier; nil end
    def ext; NullExt.new end
    def contributor; nil end
    def date; nil end
    def abstract; nil end
    def keyword; nil end
    def relation; nil end
    def series; nil end
    def source; nil end
    def version; nil end
    def editorialgroup; nil end
  end

  class NullExt
    def doctype; nil end
    def submissiontype; nil end
    def editorialgroup; nil end
    def ipprefix; nil end
    def series; nil end
  end
end
```

This approach:
- Is explicit about the interface contract
- Fails with `NoMethodError` on typos (good!)
- Is easy to extend — add the method when a new attribute is needed
- Avoids `respond_to?` and `method_missing` entirely

## Files to modify

| File | Change |
|------|--------|
| `lib/metanorma/ietf/transformer/null_bibdata.rb` | NEW — explicit null objects |
| `ietf_to_rfc_v3.rb` | Remove inner `NullBibdata` class, require new file |
| `metadata_transformer.rb` | Remove inner `NullExt` class, use shared null objects |
