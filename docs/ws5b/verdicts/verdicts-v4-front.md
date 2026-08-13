# WS5b verification wave — V4 front matter verdicts (banked 2026-08-06 22:05)
Probe script: scratchpad/ws5b/probes/a1_probes.rb (end-to-end: Asciidoctor ietf backend → presentation → Transformer.convert).

- A1.1 showOnFrontPage never emitted — CONFIRMED (semantic ext carries <showOnFrontPage>false</showOnFrontPage>; RFC org element has no attribute)
- A1.2 org-only author loses <address> — CONFIRMED (organization only; formattedAddress/phone/email/uri all vanish)
- A1.3 intended-series value hardcoded "" — CONFIRMED (`<seriesInfo name="" value="" status="BCP"/>`; the "14" lost; old emitted value="14")
- A1.4 authored initials overridden — CONFIRMED (initials="B." vs authored "B. X."; forename branch wins over initials accessor)
- A1.8 docnumber rfc- prefix strip lost — CONFIRMED (`<rfc number="rfc-8341">` + seriesInfo value="rfc-8341"; old normalized to 8341)
- A1.9 foreword note lost when abstract present — CONFIRMED (abstract+foreword: note absent; control foreword-only: note present — machinery works, container selection `abstract || foreword` is the bug)

Score: 6 CONFIRMED, 0 REFUTED.
Running totals across wave so far: V2 6C/1R, V4 6C/0R.
