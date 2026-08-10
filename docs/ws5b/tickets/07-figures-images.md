<!-- TICKET DRAFT 07. Repo: metanorma/metanorma-ietf. Assignee: opoudjis. -->
<!-- Title: Transformer: figure and image gaps — nested figures, key/paragraphs, [SOURCE:], sourcecode src, artwork attrs, image_cleanup scope -->

Refs TRACKING-URL

1. **Nested figures dropped entirely** (empirical): a figure with two subfigures emits only the empty parent — subfigure captions and images gone. The model is NOT at fault (0.2.9 FigureBlock has `map_element "figure"`); `transform_figure`'s walk (figure_transformer.rb:32-59) simply has no `figure` branch. Old leg promoted subfigures to siblings (`figure_unnest`).
2. **Figure key `<dl>` and intra-figure paragraphs dropped** (empirical): pre-artwork paragraph, post-artwork paragraph, and the key dl all vanish. Tables got the equivalent surroundings machinery (table_transformer.rb:155-175); figures did not.
3. **Figure `[SOURCE:]` attribution dropped** (empirical, reclassified from the audit): `figure_node.source` in figure_transformer.rb:74-88 reads the model's `source=` *attribute* (a string), not the `<source>` citation element — the postamble branch is dead code, and the rendered `fmt-source` content present in the presentation XML never reaches the output. (Silver lining: no deprecated `<postamble>` is emitted either.)
4. **sourcecode `src=` never wired** (empirical): presentation retains it; output is an empty `<sourcecode anchor= type=/>`. rfcxml maps `src`.
5. **Inline-image artwork loses align/name/anchor** (code-read): transform_image_to_artwork (figure_transformer.rb:117-175) maps src/alt/title only; anchor loss breaks xrefs to the image.
6. **image_cleanup scope + lossy recovery** (empirical, escalated): `[IMAGE n]` markers are orphaned in list items (artwork discarded), and in the probe even the plain-section-paragraph case failed to serialise its recovered figure — the sweep path itself lost the image. cleanup_transformer.rb:433-470.
7. **Clause-level `<pre>` dropped** (code-read): SRC_TO_RFC_TAG has no "pre" entry; old leg emitted `artwork type="ascii-art"` wherever pre occurred.

## Specs required

Subfigure pair; figure with key + explanatory paragraphs; figure with [SOURCE:]; sourcecode with src; anchored inline image xref'd elsewhere; image inside a list item; image in a plain paragraph (recovery serialises).

🤖
