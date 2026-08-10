<!-- TICKET DRAFT 16 (WS5c row 7). Repo: metanorma/metanorma-ietf. Assignee: opoudjis. -->
<!-- Title: Carry image width/height through to artwork -->

Refs https://github.com/metanorma/metanorma-ietf/issues/291

## Enhancement

`image::foo.png[width=300,height=200]` sizing never reaches `artwork/@width`/`@height` — in either the retired renderer or the transformer (this is a grammar-completeness find, not a port regression). RFC XML v3 defines both attributes on `artwork` and xml2rfc honours them in HTML/PDF output; the presentation XML carries `image/@width`/`@height`, and `transform_image` (figure_transformer.rb) currently maps type/src/alt/title/content only.

## Specs required

Sized image → `artwork` carries width/height; unsized image unchanged.

🤖
