<!-- TICKET DRAFT 10. Repo: metanorma/metanorma-ietf. Assignee: opoudjis. -->
<!-- Title: Transformer: section/root-attribute gaps — numbered, removeInRFC, tocDepth/indexInclude/iprExtract, preface clauses -->

Refs TRACKING-URL

Empirically confirmed (probe documents end-to-end):

1. **`numbered="false"` lost.** The 0.2.9 model maps only `@unnumbered` (boolean) while the IETF converter emits `@numbered`; and even for `unnumbered="true"` input, section_transformer.rb:213-216 compares the boolean against the string `"true"` — always false. `[numbered=false]` clauses get numbered by xml2rfc.
2. **`removeInRFC` lost.** No model mapping (parse ghost), no recovery side-channel: `[removeInRFC=true]` sections will wrongly survive into the published RFC.
3. **Generic preface clauses and executivesummary dropped from `<middle>`.** build_middle (section_transformer.rb:11-22) reads only introduction + acknowledgements; the Preface model's `content` (mapped from `clause`) and `executivesummary` are never read — `[.preface]` clause body text vanishes.

Code-read (high confidence for tocDepth, parallels the fixed F5 trio):

4. **tocDepth/indexInclude/iprExtract never reach the `<rfc>` root** — not in `recover_rfc_attributes` (transformer.rb:128-136) nor `set_rfc_attributes`. Since xml2rfc v3 ignores the legacy `<?rfc tocdepth?>` PI, `:toc-depth:` is silently overridden.
5. PI coverage narrowed ~35 → 8 keys (metadata_transformer.rb PI_ORDER) — low impact (xml2rfc v3 ignores the channel), recorded for completeness.

Items 1, 2, 4 partly require model additions (metanorma-document) or extension of the existing recovery side-channel; note which route each fix takes.

## Specs required

`[numbered=false]`; `[removeInRFC=true]` on clause and annex; `:toc-depth: 2` → root tocDepth; `[.preface]` clause content present; executivesummary present.

🤖
