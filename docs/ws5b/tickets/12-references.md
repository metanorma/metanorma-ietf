<!-- TICKET DRAFT 12. Repo: metanorma/metanorma-ietf. Assignee: opoudjis. -->
<!-- Title: Transformer: references gaps — hidden bibitems, uri target, date cascade, refcontent, contributor roles; formattedref precedence (adjudication) -->

Refs TRACKING-URL

Empirically confirmed (probes through Transformer.convert):

1. **Hidden bibitems emitted.** `hidden_bibitem?` is checked only in the fallback branch (reference_transformer.rb:88); the `element_order` branch — the one actually taken on 0.2.9 — appends every bibitem. `<bibitem hidden="true">` renders as a full `<reference>`; old leg skipped it.
2. **HTML-typed URI no longer becomes `target=`.** `extract_bibitem_target` matches `src` only; old accepted `%w(src HTML)`.
3. **Date cascade lost.** Only `type == "published"` accepted (reference_transformer.rb:431); a bibitem with only `issued`/`circulated` dates emits no `<date>`. Old cascade: published → issued → circulated → first non-accessed, with host fallback.
4. **Refcontent reduced to a single identifier.** Old joined all eligible ids (`ISO 2002, IEEE 802.2002`); new picks one. Also over-emits: ISBN/URN types the old exclusion list suppressed now become refcontent (code-read).
5. **Contributor role cascade lost.** Translator-only (etc.) bibitems render `<author surname="Unknown"/>`; old rendered the translator (role cascade incl. performer/distributor/authorizer).

**Held for adjudication (do not fix without a ruling):**

6. **Formattedref-vs-title precedence FLIPPED.** Old (#279): a user-supplied formattedref wins over a co-present title. New (`formattedref_only?`, reference_transformer.rb:275): the fetched title wins and the formattedref is discarded (empirically confirmed). Caveat: the presentation stage's shared bibrender now inserts formattedrefs into enriched bibitems, which may make the old precedence unportable wholesale — needs a deliberate decision on intended semantics before any code change.

## Specs required

Hidden bibitem excluded; HTML-uri target; issued-only date; multi-id refcontent; translator-only contributor; plus whichever precedence semantics the adjudication of (6) settles.

🤖
