# Task 5: Write integration spec for Pipeline 1 (ADOC → RFC XML → xml2rfc)

## Goal
Verify that ADOC documents can be converted to semantic XML, parsed by metanorma-document, transformed to RFC XML v3, and accepted by xml2rfc with **no errors and no warnings**.

## Test Cases
1. Simple document (title, sections, paragraphs) — clean pass
2. Full document (abstract, intro, lists, tables, bibliography, BCP14 keywords, notes) — clean pass
3. Fixture documents (example.xml, antioch.xml) — clean pass

## Assertion Criteria
- `xml2rfc --text` exit code must be 0
- No "Error:" lines in xml2rfc output
- RFC XML must have `<rfc>`, `<front>`, `<middle>`, `<back>`
- Title, author, sections, metadata preserved correctly

## Current Status
DONE. Integration spec includes:
- Step-by-step pipeline tests (ADOC→XML, XML→model, model→RFC XML, RFC XML→xml2rfc)
- Fixture-based tests with shared examples
- Content preservation assertions for metadata, sections, lists, tables, BCP14, notes, bibliography
- 38 integration tests pass, 288 total specs pass with 0 failures
