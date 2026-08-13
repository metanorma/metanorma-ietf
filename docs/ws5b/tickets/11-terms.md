<!-- TICKET DRAFT 11. Repo: metanorma/metanorma-ietf. Assignee: opoudjis. -->
<!-- Title: Transformer: terms gaps — escaped SOURCE xref, modification text, source merging, definition ol, termref -->

Refs TRACKING-URL

Empirically confirmed (probes):

1. **`[SOURCE:]` xref emitted as ESCAPED literal markup.** `transform_term_source` (term_transformer.rb:265-306) splices `"<xref target='X'/>"` into Text content; the serializer escapes it, so readers see `[SOURCE: &lt;xref target='RFC2119'/&gt;, adapted]` — no live cross-reference, and the locality ("Section 5") and citeas display are gone. The same string-splice pattern in `build_concept` (block_transformer.rb:637, `[term defined in <xref…>]`) is suspect for identical escaping — verify while fixing.
2. **Modification text lost unless status="modified".** Old appended the `— modification` text regardless of status; new only in the `when "modified"` branch (term_transformer.rb:288-295). `adapted` sources lose their modification note.
3. **Consecutive sources no longer merged.** Old: one `[SOURCE: A; B]`; new: one `<t>[SOURCE: …]</t>` per source (term_transformer.rb:206-210).
4. **Multi-paragraph single definition renders as a spurious `<ol>`.** New counts definition *paragraphs* where old counted `<definition>` elements (term_transformer.rb:123-150) — one definition with two paragraphs is misrepresented as two enumerated definitions.

Code-read:

5. **Origin-with-termref unhandled** — falls to flattened plain text; locality unmapped (0.2.9 ghost, note model dependency).

## Specs required

Term source with bibliographic origin (live xref element, locality text); adapted source with modification; two consecutive sources; single definition with two paragraphs (no ol).

🤖
