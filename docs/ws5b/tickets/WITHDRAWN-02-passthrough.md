<!-- WITHDRAWN 2026-08-06 (user ruling): known WS3-era model-vintage deferral — must NOT be filed as a new defect. Tracked by the WS3 ledger, the pending spec examples, and the model upgrade queue. Kept for reference only. -->
<!-- Title: Transformer: body and inline passthrough content dropped -->

Refs TRACKING-URL

## Status correction (2026-08-06 review)

This is a **known, ledgered model-vintage deferral**, not a newly discovered bug: `spec/feature/inline_spec.rb:634-656` carries two *pending* examples with the note "MODEL GAP (metanorma-document 0.2.9): `<passthrough>` is parse-ghosted (ghost order entry, no accessor); the presentation layer's format gating works … but the content cannot reach the transformer. Re-test on 0.4.x — see qa-plan". The WS5b audit's contribution is confirming the loss end-to-end (presentation retains both inline and block passthrough; the model parse drops them) and noting the #275 comma-split fix has no new-leg body consumer. **Fix route: the 0.4.x/0.5.x model upgrade batch**; the references-side consumer works because it re-parses raw XML rather than going through the model accessors.

## Defect

The transformer consumes `<passthrough>` only inside references sections (`reference_transformer.rb:66-110`, the raw-`<reference>` capability). On 0.2.9 the element is parse-ghosted at `from_xml`, so body-level and inline passthrough content vanishes.

Empirically localised to the transformer leg: the intermediate presentation XML still carries both inline (`<p>Before <passthrough formats=" rfc ">…</passthrough> after.</p>`) and block-level passthrough; the transformer then drops them. The retired renderer's `passthrough_parse` (blocks.rb) + isodoc `passthrough_cleanup` re-inserted the entity-decoded raw content, format-gated on `formats` (including the #275 comma/space-split fix — which currently has no new-leg body consumer to inherit it).

## Repro (empirically confirmed)

`++++`-block or `pass:[]` inline with rfc format in any clause body → both markers absent from the RFC XML; old leg emitted the raw markup.

## Fix shape

Handle the passthrough element in the block/inline walks: format-gate on `formats` (comma/whitespace split), entity-decode, splice raw into output — reusing the references-side machinery.

## Specs required

Inline passthrough in a paragraph; block passthrough between paragraphs; non-rfc `formats` suppressed; comma-separated formats list (the #275 shape).

🤖
