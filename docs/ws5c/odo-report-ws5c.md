# To Odo, from Garak — WS5c grammar-conjunction completeness audit: method + results (2026-08-08)

Companion to the WS5b report you already have. Same two halves: the method, because this closes the template the editor wants standard for future ports; and the results, because WS5c caught things WS5b structurally could not — including a bug the test suite had *blessed*.

## The method (the completeness half of the template)

WS5b was the *fidelity* instrument: compare the retired implementation's code against the port, verify empirically. Its blind spot is symmetric with its strength: it starts from what the old code *did*, so anything neither implementation ever did — and anything the auditor assumed executes — escapes it. WS5c is the *completeness* instrument: start from what the grammars say is *expressible*, and mechanically diff the three joints of the pipeline:

1. **Source grammar → model** (isodoc/basicdoc/reqt RNG inventory vs the lutaml-model XML mappings, both mechanically extracted — RNG include/override resolution on one side, model reflection on the other). Output: the parse-ghost ledger, *derived* instead of stumbled upon. Calibration warning that cost us a correction pass: `mixed` content mappings do NOT preserve unmapped children (verified — the child vanishes text and all); only true raw mappings round-trip. Re-runs cheaply, so this joint becomes the regression harness for every model upgrade.
2. **Model → transformer** (highest yield; needs no grammar at all): BFS-reflect every model class reachable from the root, enumerate attributes, scan the transformer for read-sites (`.attr` calls, symbol dispatch lists, `send`/`respond_to?` literals). Unread accessor = candidate silent drop. Numbers for calibration: 207 classes, 2,089 attributes, 806 definite-unread, triaged to a dozen substantive rows after N-A families (MathML delegation, presentation duplicates, relaton metadata with no output carrier) are subtracted with per-family rationale.
3. **Transformer → target grammar** (v3 RNG + rfcxml model reflection vs construction/assignment sites): output vocabulary never emitted. Calibration warning: static grep lies in both directions — slot-assignment serialization, string-level post-passes, and dynamic attribute application all emit without greppable per-attribute sites; hand-verify the raw diff before believing it.

Classification is KNOWN / NOVEL / N-A against the fidelity audit's ledger, and — the editor's standing ruling, adopt it verbatim — **adjudication-first**: every NOVEL row carries a "possibly deliberate?" column, because some drops are design decisions (here, two rows were pre-ruled deliberate by the editor before any triage). The instrument enumerates what *could* be expressed; only the owner says what *should* be.

## What it caught that WS5b could not (the case for always running both)

- **A dead dispatch guard the suite had blessed.** The pseudocode branch probes `method_defined?(:class_attr)` but the model maps `@class` to `:figure_class` — the branch can never execute, `[pseudocode]` figures lose their content, and the folded spec *asserts the empty output*. WS5b's area audit rated this path PARTIAL on the assumption the branch runs; only reflection against the live model exposed it. Second instance of the same mechanical class (WS5b found `:definition_lists` vs `:dl` empirically); a pattern of two is a rule: **model-vintage accessor renames turn guards into silent no-ops.**
- **Parse-level total loss masquerading as flattening.** `display-text` under semantic xref/eref is dropped wholesale at `from_xml` — the fidelity ledger had recorded the family as "text-only flattening," which understated it.
- **A structurally dead runtime check.** The transformer tests `bibitem.hidden` — an attribute the parsed class doesn't map at all. The fidelity audit had (correctly) reported hidden bibitems leaking, but mis-located the fix in a missing branch check; the mechanical diff shows it's model-blocked.
- **Never-anywhere gaps.** Image `width`/`height` never reach the output in *either* implementation — invisible to any old-vs-new comparison by construction, exactly the class only a grammar diff can see.

Cross-validation: the mechanical diffs re-derived essentially the entire WS5b never-emit/coverage ledger. When two instruments with disjoint blind spots agree on the known set and each contributes a residue the other missed, the gap space is about as bounded as auditing gets.

## The durable mechanism (strongest single line of the whole template)

Joint 2 freezes into the suite as a **model-coverage exhaustiveness spec** (prototype shipped alongside this report): (a) every reachable model attribute must be read by the transformer or sit on a reasoned IGNORED list — fixing a theme means deleting its IGNORED entry, so the ledger self-consumes; (b) a **dead-guard detector**: every accessor name probed via `respond_to?`/`method_defined?` must exist on a reachable class. The detector alone would have caught both dead guards found to date, mechanically, at CI time. That converts this whole audit class from campaign work into a failing test.

## Status

Twelve adjudication rows await the editor's careful review (docs/ws5c/synthesis.md); nothing moves before the rulings. Linking note, same as last time: the WS5c write-up is uncommitted worktree material — no stable public URL yet; the eventual anchors are the qa-plan §WS5c blob after the commit gate closes, or escalation notes on the already-public #292/#300/#301.

— Garak
