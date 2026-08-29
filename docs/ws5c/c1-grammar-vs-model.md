# WS5c joint 1 — isodoc/basicdoc/reqt grammar vs metanorma-document mappings (banked 2026-08-08 00:42)
Scripts: scratchpad/ws5c/{rng_inventory.rb → rng_inventory.json, model_reflect.rb → model_classes.json + model_elements.json, diff_ghosts.py → diff_output.txt}.
Method calibration (empirical): `mixed` content does NOT preserve unmapped children (ruby-in-p vanishes incl. text); only true raw mappings round-trip; raw-class union-poisoning corrected.

## Summary
- Grammar: 171 elements (170 reachable from <metanorma>); biblio internals scoped out (→ #301 territory).
- Model: 200 Serializable classes, 475 mapped XML element names.
- 36 elements fully ghosted; 79 with attribute-level ghosts; 90 with child-mapping ghosts.
- KNOWN cross-validation: passthrough + annotation orphaned-root classes (bucket-A), clause-level pre (A2.9), raw svg (ledgered), reqt members (#297/#299), location-under-xref (ledgered), T3 flattening + T4 container families (#292/#297), note numbering concession, abstract restriction, [SOURCE:] family.
- NEGLIGIBLE families: hr/toc no-op parity, ruby/svgmap/imagemap/forms/audio-video (no v3 home), designation metadata, index ranges/see-also, styling metadata (~45-element @source bookkeeping etc.).

## NOVEL (all subject to user careful review — adjudication-first per 2026-08-08 ruling)
1. **display-text dropped WHOLESALE at parse under semantic xref/eref/source** (HIGH model-level, MEDIUM end-to-end): `<xref><display-text>see <tt>this</tt></display-text></xref>` → `<xref target="t1"/>`. Escalates the #292 family: not flattening — total node loss; recovery only via fmt-xref/semx side channel on the abstract-flatten path. Authored custom xref text silently replaced by auto-label.
2. **termnote/termexample parse as ParagraphBlock — all block content lost** (MEDIUM, needs end-to-end probe): `<termnote id="n1"><p>…</p><ul>…</ul></termnote>` → `<p id="n1"/>`. Contradicts a6's PORTED rating for termnote_parse (verified case must have been inline-text-only).
3. **Anchor ghosts broader than T5 ledger** (HIGH mapping-absence, MEDIUM incidence): @anchor unmapped on td/th/tr, fn, term, name, title, variant-title, dd, definition, image, annotation, floating-title, pre, form, span. Xrefs to these dangle.
4. **concept semantic carriers ghosted** (MEDIUM-HIGH): @bold/@ital/@ref/@linkmention/@linkref + children eref/erefstack/termref unmapped — concepts sourced from external refs/termbases drop their links entirely (feeds #300).
5. **erefstack fully ghosted** (HIGH drop, LOW impact): released leg had no handler either — parity-ish.
6. **bibitem@hidden ghost → transformer's hidden_bibitem? guard structurally DEAD** (HIGH for inspected class): reference_transformer.rb:107 tests an attribute the class doesn't have. ESCALATES #301 item 1: the fix is model-blocked (mapping addition or docidentifier read), not just the missing element_order branch check. @suppress_identifier ghosted alongside.
7. **Minor cluster** (LOW): amend family loses locus/newcontent/section; inline date maps to relaton BibliographicDate ghosting @value.
