<!-- TICKET DRAFT 00 — tracking issue. Repo: metanorma/metanorma-ietf. Assignee: opoudjis. -->
<!-- Title: WS5b static port audit: transformer functionality gaps vs the retired renderer (tracking) -->

Refs https://github.com/metanorma/metanorma-ietf/issues/233

## Summary

The WS5b static port audit (method: docs/qa-plan.adoc §WS5b on the transformer branch) compared every method of the retired RFC-XML renderer (`lib/isodoc/ietf/*.rb` at the last released state) against the model-driven transformer, then empirically verified the significant candidates with minimal probe documents through the full new pipeline. The behavioral QA instruments (WS2/WS3/WS5) could only see constructs their inputs exercised; this audit targets the corpus's blind spot. The architecture makes the gap class predictable: the old renderer was a generic recursive walker that failed open (unhandled children still parsed), while the transformer is typed per-tag dispatch that fails closed (unmapped tags silently dropped).

Outcome: **~41 findings empirically confirmed** (probe evidence per child ticket), 1 false alarm refuted, plus code-read items of lower confidence recorded in the child tickets. Full ledger: docs/qa-plan.adoc §WS5b findings ledger.

## Scope note

Known WS3-era model-vintage deferrals (cref/annotations, passthrough, references-section notes, formatted-initials, caption-markup model gap, iref `primary=`) are **deliberately excluded** from this batch: they are already tracked by the WS3 ledger, pending spec examples, and the metanorma-document upgrade queue (#37–#44), and re-ticketing them would misrepresent known deferrals as new defects.

## Child tickets

- [ ] inline markup content lost (ls_text flattening family)
- [ ] footnote content losses and table-footnote collision
- [ ] list item gaps: anchors, nested dl, block children, ordering
- [ ] table gaps: cell block content, @align, header rows
- [ ] figure/image gaps: nested figures, key/paragraphs, [SOURCE:], sourcecode src, image artwork attrs, image_cleanup scope
- [ ] container children dropped (quote/admonition/note/example)
- [ ] front-matter gaps (showOnFrontPage, org address, intended-series value, initials, docnumber, foreword notes, ascii*, dates)
- [ ] section/root-attribute gaps (numbered, removeInRFC, tocDepth/indexInclude/iprExtract, preface clauses)
- [ ] terms gaps (escaped SOURCE xref, modification text, source merging, definition ol, termref)
- [ ] references gaps (hidden bibitems, uri target, date cascade, refcontent, contributor roles; formattedref precedence — adjudication)
- [ ] pipeline robustness (validation quarantine, CLI ampersand escaping, NCName '#' asymmetry, refcontent iteration)

## Discipline

Every fix lands with specs covering the probe shapes that confirmed the finding — the audit exists precisely because the current suite does not exercise these constructs.

🤖
