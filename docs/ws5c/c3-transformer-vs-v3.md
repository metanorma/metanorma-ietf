# WS5c joint 3 — transformer emit-sites vs RFC XML v3 grammar (banked 2026-08-08 00:09)
Scripts + TSVs in scratchpad/ws5c/ (extract_rng_vocab.rb, reflect_rfcxml.rb, diff_emit_vs_grammar.rb).
Grammar: lib/metanorma/ietf/schema/v3.rng (7991bis-lineage: includes deprecated v2 vocabulary + prep-tool vocabulary).

## Summary
- 85 grammar elements; 63 emitted (incl. th/thead/tfoot via slot assignment, em via parent-slot serialization, u via post-serialization u_cleanup; list attribute families via dynamic apply_list_attributes — raw grep corrected for all four mechanisms); 22 never emitted.
- ~168 attribute slots on emitted elements; 51 never set → 31 prep-tool/xml2rfc-internal (pn/derived*/slugifiedName/originalSrc/rfc mode-prepTime-scripts-expiresDate/xref pageno), rest KNOWN or NOVEL.
- Cross-validation: every WS5b never-emit finding of this class re-derived mechanically (cref, br, showOnFrontPage, ascii* family, tocDepth/indexInclude/iprExtract, keepWithPrevious, sourcecode/@src, table/@align, numbered dead-compare, removeInRFC, eref/@brackets, iref/@primary, facsimile F6). relref retirement + boilerplate/toc/stream N-A confirmed as deliberate.
- Note: postamble emit-site (figure [SOURCE:]) exists in code but WS5b verification proved the path dead.

## NOVEL (2)
1. **artwork/@width,@height (+figure width/height) never emitted** — `image::foo.png[width=300,height=200]` sizing silently dropped (transform_image sets type/src/alt/title/content only). NOT a port regression — released leg never emitted them either; pure grammar-completeness gap. High confidence never-emitted; medium author impact.
2. **thead/tbody/tfoot @anchor never carried** — transform_table_section drops the row-group id; xref to an anchored row group dangles (T5 class, unenumerated). High confidence; low impact (rare authoring).

Disposition proposal: both NOVEL items are enhancement-class, not port regressions → candidates for a small WS5c ticket (or fold #1 into #296 figures/images as an adjacent item and #2 into #295 tables). Await user ruling at WS5c synthesis.
