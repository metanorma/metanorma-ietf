# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`metanorma-ietf` is a Ruby gem that converts AsciiDoc documents into IETF RFC XML v3 (RFC 7991) format, used for writing Internet-Drafts and RFCs. It is part of the [Metanorma](https://www.metanorma.com) publishing suite.

## Build & Test Commands

```sh
bin/setup              # Install dependencies
bin/rspec              # Run full test suite
bundle exec rake       # Run default task (rspec)
bin/rspec spec/metanorma/base_spec.rb     # Run a single spec file
bin/rspec spec/metanorma/base_spec.rb:37  # Run a single test by line number
```

Tests freeze time to `2000-01-01T00:00:00Z` (via Timecop) so generated timestamps are deterministic.

## Architecture

This gem follows the standard Metanorma plugin architecture with three main processing layers:

### Layer 1: AsciiDoc → Semantic XML (`Metanorma::Ietf::Converter`)
- **Entry point:** `lib/metanorma-ietf.rb` registers the `:ietf` processor
- **Converter:** `lib/metanorma/ietf/converter.rb` — extends `Metanorma::Standoc::Converter`, parses AsciiDoc into Metanorma semantic XML (`ietf-standard` root tag, namespace `https://www.metanorma.org/ns/ietf`)
- **Supporting modules** (all under `Metanorma::Ietf::Converter`):
  - `front.rb` — metadata extraction (author, series, committees, IPR, PI settings)
  - `blocks.rb` — block-level AsciiDoc element handling (paragraphs, lists, images, code listings)
  - `macros.rb` — custom Asciidoctor inline macro `InlineCrefMacro` for `cref:[]`
  - `cleanup.rb` — post-processing (BCP14 keyword detection, cref→bookmark resolution, smart quote stripping, xref cleanup)
  - `validate.rb` — input validation (SVG-only images, workgroup names, submission type rules)

### Layer 2: Semantic XML → RFC XML v3 (`IsoDoc::Ietf::RfcConvert`)
- **Converter:** `lib/isodoc/ietf/rfc_convert.rb` — extends `IsoDoc::Convert`, transforms semantic XML into RFC XML v3
- **Key modules** (all mix into `RfcConvert`):
  - `front.rb` — `<front>` element generation (title, seriesInfo, author, date, area, workgroup, abstract)
  - `blocks.rb`, `section.rb`, `table.rb`, `lists.rb`, `inline.rb` — element-by-element conversion
  - `references.rb` — bibliography/reference handling
  - `terms.rb` — definition list and terminology handling
  - `cleanup.rb` + `cleanup_blocks.rb` + `cleanup_inline.rb` — post-processing (reference groups, abstracts, dates, asides)
  - `validation.rb` — RFC XML v3 schema validation via Jing (`v3.rng`) plus content rules (numbered sections, TOC, xref targets, IPR)
  - `xref.rb` — cross-reference handling
  - `metadata.rb` — metadata extraction for conversion

### Layer 3: Model-Driven Transformer (`Metanorma::Ietf::Transformer`)
- **Entry point:** `lib/metanorma/ietf/transformer.rb` — provides `Transformer.convert(xml_string)` as a pure OOP alternative to the string-based IsoDoc layer
- **Orchestrator:** `lib/metanorma/ietf/transformer/ietf_to_rfc_v3.rb` — `IetfToRfcV3` class; parses input via `Metanorma::IetfDocument::Root.from_xml`, builds `Rfcxml::V3::Rfc` output via 13 mixed-in modules, calls `to_xml` once at the end
- **Transformation modules** (all private, mixed into `IetfToRfcV3`):
  - `metadata_transformer.rb` — RFC root attributes (number, category, ipr, consensus, docName, obsoletes/updates, PI settings)
  - `front_transformer.rb` — `<front>` (title, seriesInfo, authors with postal/email/uri, date, areas, workgroups, keywords, abstract, front notes)
  - `section_transformer.rb` — `<middle>` and `<back>` construction, clause traversal, loose bibitems, endnotes, annexes
  - `block_transformer.rb` — paragraphs, notes, examples, sourcecode, blockquotes, admonitions, formulas, inline elements via element_order interleaving
  - `inline_transformer.rb` — cross-references (xref, relref, eref), stem/MathML, footnotes, BCP14 from span, concept terms
  - `figure_transformer.rb` — figures, pseudocode, SVG data-URI artwork, pre→artwork, figure source citations, figure notes→aside
  - `table_transformer.rb` — tables (thead/tbody/tfoot), colgroup, colspan/rowspan
  - `list_transformer.rb` — ordered/unordered lists, definition lists, list item children, ol type mapping
  - `term_transformer.rb` — terms/definitions, term source references, concept organization
  - `reference_transformer.rb` — bibliography sections, reference groups, bibitem→reference conversion, reference anchors, annotations
  - `annotation_transformer.rb` — editor annotations → cref elements, annotation rendering control
  - `cleanup_transformer.rb` — post-processing pipeline: li unwrap → sourcecode clean → deflist → BCP14 from strong → front title → biblio → cref → aside → figure unnest → unicode wrap → inline image extract
  - `validation_transformer.rb` — RFC XML v3 schema validation via Nokogiri::XML::Schema (`v3.rng`), content rules (numbered sections, TOC, references, xref targets, IPR)
- **Design constraints:**
  - No XML string manipulation (no gsub, Nokogiri, or Ox on output) — all transformations use OOP model objects from the `rfcxml` gem
  - Inline element ordering is tracked via `element_order` from lutaml-model's mixed_content support
  - Cleanup passes operate on `Rfcxml::V3` model objects via `walk_sections` traversal
- **Tests:** `spec/transformer/transformer_spec.rb` — fixture-based tests (example RFC + antioch Internet-Draft) plus unit tests for individual cleanup/validation helpers

### Supporting Components
- **Processor:** `lib/metanorma/ietf/processor.rb` — registers output formats (`rfc`, `txt`, `html`, `pdf`, `xml`, `rxl`) and orchestrates `xml2rfc` for text/PDF/HTML generation
- **Relaton rendering:** `lib/relaton/render/` — custom bibliographic string rendering for IETF references
- **Schema files:** `lib/isodoc/ietf/v3.rng` (RFC XML v3 RELAX NG), `lib/isodoc/ietf/SVG-1.2-RFC.rng`

### Data Flow
```
AsciiDoc → Metanorma::Ietf::Converter → Semantic XML (ietf-standard)
         → IsoDoc::Ietf::RfcConvert → RFC XML v3 (.rfc.xml)
         → Transformer (model-driven) → RFC XML v3 (.rfc.xml)
         → xml2rfc (external tool) → .txt / .html / .pdf
```

## Key Conventions

- The default document type is `internet-draft` (not `rfc`)
- Output file extension for RFC XML is `.rfc.xml` (not `.xml`) — the `.xml` extension is reserved for semantic XML
- BCP14 keywords (MUST, SHALL, SHOULD, etc.) are auto-detected and wrapped in `<span class="bcp14">` unless `:no-rfc-bold-bcp14:` is set
- Only SVG images are allowed in IETF documents (validated in `Metanorma::Ietf::Validate`)
- The gem depends on `metanorma-standoc` (~> 3.4.0), `metanorma-ietf-data` (workgroup lists), `rfcxml` (RFC XML v3 model objects), and `metanorma-document` (Metanorma document model objects)
- The model-driven transformer (`Metanorma::Ietf::Transformer`) uses only OOP model objects — never XML string manipulation for output
- Transformer specs use fixture XML files in `spec/fixtures/transformer/input/` and `spec/fixtures/transformer/output/`
- `xml2rfc` must be installed on the system to generate `.txt`, `.html`, or `.pdf` output
- Tests use `Canon` (profile: `:metanorma`) and `equivalent-xml` for XML comparison, with `strip_guid` helper to normalize generated UUIDs/IDs before comparison
- RuboCop rules are inherited from `https://raw.githubusercontent.com/riboseinc/oss-guides/master/ci/rubocop.yml`
- CI uses `metanorma/ci/.github/workflows/generic-rake.yml` with `setup-tools: xml2rfc`
