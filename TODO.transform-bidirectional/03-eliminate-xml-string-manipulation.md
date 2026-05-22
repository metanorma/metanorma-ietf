# 03: Eliminate XML String Manipulation

## Problem

Multiple locations in the transformer build or manipulate XML via string operations instead of using rfcxml model objects. This violates the core design constraint: all RFC XML output must be built through model objects.

## Catalog of violations

### 1. `transformer.rb:15` — xmlns stripping via gsub
```ruby
stripped = xml_string.gsub(/\sxmlns="[^"]*"/, "")
```

This is INPUT parsing, not output generation. The `metanorma-document` gem's `from_xml` should handle namespaces. If it doesn't, this is a bug in `metanorma-document` that should be fixed upstream, not worked around with string manipulation.

**Fix**: Remove the gsub. If `from_xml` fails, fix the parser in `metanorma-document` to ignore or strip default namespaces.

### 2. `cleanup_transformer.rb:200-203` — regex XML tag stripping
```ruby
c.gsub("<br/>", "\n").gsub("<br/>", "\n")
  .gsub(%r{\s+<t[ >]}, "<t>")
  .gsub("</t>", "")
  .gsub(%r{</?[^>]+>}, "")
```

This strips XML tags from text content. The real issue is that the content contains serialized XML nodes instead of model objects.

**Fix**: Operate on the model's content array. Filter out non-text entries programmatically instead of regex-stripping XML.

### 3. `cleanup_transformer.rb:306` — title tag stripping
```ruby
title.content = content.map { |c| c.to_s.gsub(%r{</?[^>]+>}, "") }
```

Same problem — content contains serialized XML strings.

**Fix**: Walk the content array and extract text from model objects instead of stringifying and stripping tags.

### 4. `term_transformer.rb:239` — xref built as string
```ruby
text += "<xref target='#{target}' section='' relative=''/>"
```

**Fix**: Create a `Rfcxml::V3::Xref` model object and append it to the parent's content array with proper element_order tracking.

### 5. `block_transformer.rb:490-491` — xref built as string
```ruby
ref_text = "[term defined in <xref target='#{target}'/>]"
```

**Fix**: Build structured content: `[ "[term defined in ", xref_obj, "]" ]` using model objects.

### 6. `annotation_transformer.rb:35` — synthetic XML root for parsing
```ruby
doc_fragment = Rfcxml::V3::Rfc.from_xml("<rfc>#{content}</rfc>")
```

**Fix**: Use `Rfcxml::V3::Rfc` fragment parsing or parse the annotation content directly into model objects without wrapping in a fake root.

### 7. `figure_transformer.rb:189` — CDATA built as string
```ruby
artwork.content = text.empty? ? nil : "<![CDATA[#{text}]]>"
```

**Fix**: Set `artwork.content = text` and let the rfcxml serialization handle CDATA wrapping. If the model doesn't auto-CDATA, add CDATA support to the rfcxml gem's artwork serialization.

### 8. `ietf_to_rfc_v3.rb:128` — manual XML entity escaping
```ruby
str.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;")
```

**Fix**: The model serialization layer should handle entity escaping. Remove this method and rely on the rfcxml gem's serialization.

### 9. `cleanup_transformer.rb:555` — image reference stripping
```ruby
content[item[:index]] = content[item[:index]].gsub("[IMAGE #{item[:image][:number]}]", "")
```

**Fix**: Operate on structured content array, remove the image reference model object instead of string manipulation.

## Priority order

1. Items 4, 5 (xref strings) — most dangerous, injection risk
2. Item 7 (CDATA) — straightforward fix
3. Items 2, 3 (tag stripping) — requires rethinking content handling
4. Item 6 (synthetic root) — requires rfcxml fragment parsing
5. Item 8 (entity escaping) — verify serialization handles it
6. Item 1 (xmlns stripping) — fix in upstream gem or keep as input parsing exception
7. Item 9 (image ref stripping) — requires structured content approach

## Files to modify

| File | Lines | What |
|------|-------|------|
| `transformer.rb` | 15 | Remove xmlns gsub |
| `cleanup_transformer.rb` | 200-203, 306, 555 | Replace regex with model ops |
| `term_transformer.rb` | 239 | Use Xref model object |
| `block_transformer.rb` | 490-491 | Use Xref model object |
| `annotation_transformer.rb` | 35 | Use fragment parsing |
| `figure_transformer.rb` | 189 | Let model handle CDATA |
| `ietf_to_rfc_v3.rb` | 128 | Remove manual escaping |
