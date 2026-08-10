<!-- WITHDRAWN 2026-08-06 (user ruling): known WS3-era model-vintage deferral — must NOT be filed as a new defect. Tracked by the WS3 ledger, the pending spec example, and the model upgrade queue. Kept for reference only. -->
<!-- Title: Transformer: reviewer annotations (cref) pipeline is an empty stub -->

Refs TRACKING-URL

## Status correction (2026-08-06 review)

This is a **known, ledgered model-vintage deferral**, not a newly discovered bug: `spec/feature/footnotes_spec.rb` carries the folded reviewer-notes example as *pending* with the note "annotation-container/annotation of this vintage parses to zero annotations in the model (metanorma-document 0.2.9), so no crefs can be built; `<bookmark>` is likewise unmapped — see qa-plan WS3 note". The WS5b audit's contribution is confirming the observable loss end-to-end and its four-area blast radius. **Fix route: the 0.4.x/0.5.x model upgrade batch** (annotation elements gain accessors), or a recovery side-channel à la the F5 trio if the upgrade slips.

## Defect

`lib/metanorma/ietf/transformer/annotation_transformer.rb:19` `build_annotations` returns `[]` unconditionally. The gating predicate `render_annotations?` (annotation_transformer.rb:8) was faithfully ported but nothing calls it and no code constructs `Rfcxml::V3::Cref`; `section_transformer.rb:170` iterates the empty array.

The retired renderer emitted `<cref anchor= display= source= from=>` with parsed children for every review/annotation, gated on `render-document-annotations` / `notedraftinprogress`, then relocated crefs to their `from=` anchor's text node (`cleanup_inline.rb:64-89` on main).

## Repro (empirically confirmed)

AsciiDoc reviewer note (`[reviewer=X]` review block) in a document with `:notedraftinprogress:` set → old leg: `<cref source="X">…</cref>` at the anchor; new leg: nothing anywhere in the output.

## Fix shape

Implement `build_annotations` from the model's annotation elements: construct `Rfcxml::V3::Cref` with anchor/display/source, place per the old relocation semantics (at the `from=` anchor where given, back matter otherwise), honouring the `render_annotations?` gate.

## Specs required

Reviewer note rendered under `:notedraftinprogress:`; suppressed without the gate; cref placement at the `from=` anchor; cref in back matter when no `from=`.

🤖
