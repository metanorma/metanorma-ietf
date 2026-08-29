# Task 6: Write integration spec for Pipeline 2 (RFC XML → reverse → forward → xml2rfc)

## Goal
Verify that RFC XML v3 documents can be reverse-transformed to metanorma-document, then forward-transformed back to RFC XML v3, and the round-tripped RFC XML is accepted by xml2rfc with **no errors and no warnings**.

## Test Cases
1. Simple RFC XML (sections, paragraphs, lists, bibliography) — clean round-trip
2. Complex RFC XML (example.xml fixture forward output) — clean round-trip
3. Antioch.xml fixture forward output — clean round-trip

## Assertion Criteria
- `xml2rfc --text` on round-tripped RFC XML exit code must be 0
- No "Error:" lines
- No "Warning:" lines
- Round-tripped RFC XML must preserve: title, author, sections, references
- Content text must be preserved (no data loss)

## Prerequisites
- Task 2 (fix extract_paragraph_text) — DONE
- Task 3 (fix duplicate anchors) — DONE
- Task 4 (fix li/t children) — DONE

## Current Status
DONE. Integration spec includes:
- Shared examples for fixture-based round-trip (example.xml, antioch.xml)
- ADOC-based full round-trip test (ADOC → RFC → reverse → forward → xml2rfc)
- All 38 integration tests pass, 288 total specs pass with 0 failures
