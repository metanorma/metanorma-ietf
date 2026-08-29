# 05: Remove Nokogiri from Validation

## Problem

`validation_transformer.rb` uses Nokogiri for RFC XML v3 schema validation:

```ruby
require "nokogiri"

# line 15
schema = Nokogiri::XML::Schema(File.read(schema_path))

# line 17
doc = Nokogiri::XML(xml_string, &:noblanks)
errors = schema.validate(doc)
```

This is the ONLY Nokogiri usage in the transformer layer. Nokogiri should not be a dependency of the model-driven transformer — it's part of the old IsoDoc layer.

## Solution

### Option A: Use the rfcxml gem's built-in validation

If the rfcxml gem can validate against the RELAX NG schema via its own adapter (moxml/lutaml-model), delegate to it:

```ruby
def validate_schema(rfc_model)
  rfc_model.validate  # if rfcxml supports validation
end
```

### Option B: Use moxml for schema validation

moxml (already a dependency via lutaml-model) can parse XML. Use moxml with the Nokogiri backend for validation only:

```ruby
require "moxml"

def validate_schema(xml_string)
  context = Moxml.new(:nokogiri)
  doc = context.parse(xml_string)
  # moxml may not support RELAX NG validation directly
end
```

### Option C: Keep Nokogiri for validation only, isolate it

If Nokogiri is the only Ruby library that can do RELAX NG validation, keep it but isolate it behind an interface. Validation is INPUT PROCESSING (reading/parsing), not output generation, so Nokogiri is acceptable here — similar to how it's used for reading the input XML.

The constraint is: **no Nokogiri for GENERATING output**. Using Nokogiri to VALIDATE already-generated output is a gray area but acceptable if isolated.

**Recommended**: Option C with clear documentation that Nokogiri is only for validation input processing, never for output generation. If moxml adds RELAX NG support, switch to Option B.

## Files to modify

| File | Change |
|------|--------|
| `validation_transformer.rb` | Add comment clarifying Nokogiri is validation-only; consider moxml migration path |
