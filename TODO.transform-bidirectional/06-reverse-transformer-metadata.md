# 06: Reverse Transformer — Metadata and Root Attributes

## Problem

No reverse transformer exists. This is the first module for `RfcV3ToIetf`: RFC XML v3 root attributes → Metanorma XML bibdata.

## Scope

Parse `Rfcxml::V3::Rfc` root attributes and build `Metanorma::IetfDocument::Root` bibdata:

| RFC XML v3 attribute | Metanorma XML field |
|---------------------|---------------------|
| `number` | `bibdata/docnumber` |
| `category` | `bibdata/ext/doctype` |
| `ipr` | `bibdata/ext/ipprefix` |
| `consensus` | `bibdata/ext/consensus` |
| `docName` | `bibdata/docidentifier[@type="IETF"]` |
| `obsoletes` | `bibdata/relation[@type="obsoletes"]` |
| `updates` | `bibdata/relation[@type="updates"]` |
| `submissionType` | `bibdata/ext/submissiontype` |
| `xml:lang` | `bibdata/language` |
| `tocInclude` | `bibdata/ext/toc` |
| `symRefs` | `bibdata/ext/symrefs` |
| `sortRefs` | `bibdata/ext/sortrefs` |
| `pi.*` | `bibdata/ext/pi.*` |

## Implementation

```ruby
# lib/metanorma/ietf/transformer/rfc_v3_to_ietf/metadata_transformer.rb
module Metanorma::Ietf::Transformer::RfcV3ToIetf
  module MetadataTransformer
    def build_bibdata(rfc)
      bibdata = Metanorma::IetfDocument::Bibdata.new
      set_doctype(bibdata, rfc)
      set_docnumber(bibdata, rfc)
      set_docidentifier(bibdata, rfc)
      set_language(bibdata, rfc)
      set_relations(bibdata, rfc)
      set_ext(bibdata, rfc)
      bibdata
    end
  end
end
```

## Dependencies

- Requires understanding of both `Rfcxml::V3::Rfc` attributes and `Metanorma::IetfDocument::Bibdata` structure
- Requires TODO 01 (architecture) to define the `RfcV3ToIetf` class
