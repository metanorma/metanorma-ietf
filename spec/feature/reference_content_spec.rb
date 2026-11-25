require "spec_helper"

# Fix-wave specs for metanorma-ietf#301 (references gaps). The
# item-6 precedence (formattedref wins over a co-present title,
# adjudicated 2026-08-11) was superseded on 2026-11-25 per the owner's
# direction on metanorma-ietf#375: a structured title wins when one
# co-exists, matching the released renderers (v2.5.1 through the
# 1.15.x-era 3.7.0) — xml2rfc renders authors, date and series from
# the other elements, so the full citation spliced into <title>
# duplicates them.
RSpec.describe "IETF reference content (#301)" do
  # reference_export: false — these examples spec the INTERNAL
  # renderer, which since the relaton-bib#125 adoption (2026-08-13)
  # is the fallback lane (presentation-free runs, source-less
  # bibitems, exporter errors); the exporter lane has its own example
  # below and the relaton-bib corpus spec (their #126)
  def biblio_convert(bibitems)
    input = <<~INPUT
      #{BLANK_HDR}
      <sections><clause id="c1"><title>Body</title><p id="p1">T.</p></clause></sections>
      <bibliography><references id="R1" normative="true"><title>Normative References</title>
      #{bibitems}
      </references></bibliography>
      </metanorma>
    INPUT
    strip_guid(Metanorma::Ietf::Transformer.convert(
                 input, reference_export: false,
               ))
  end

  it "excludes hidden bibitems" do
    out = biblio_convert(<<~B)
      <bibitem id="VISIBLE" type="standard"><title>Visible Title</title>
      <docidentifier type="W3C">W3C VIS</docidentifier></bibitem>
      <bibitem id="GHOST" hidden="true" type="standard"><title>Hidden Title</title>
      <docidentifier type="W3C">W3C GHOST</docidentifier></bibitem>
    B
    expect(out).to include("Visible Title")
    expect(out).not_to include("Hidden Title")
  end

  it "accepts an HTML-typed uri as the reference target" do
    out = biblio_convert(<<~B)
      <bibitem id="HB" type="standard"><title>Linked Title</title>
      <uri type="HTML">https://example.com/doc.html</uri>
      <docidentifier type="W3C">W3C HB</docidentifier></bibitem>
    B
    expect(out).to match(/<reference[^>]* target="https:\/\/example\.com\/doc\.html"/)
  end

  it "cascades to an issued-only date" do
    out = biblio_convert(<<~B)
      <bibitem id="ISS" type="standard"><title>Issued Title</title>
      <docidentifier type="W3C">W3C ISS</docidentifier>
      <date type="issued"><on>2019-03</on></date></bibitem>
    B
    expect(out).to match(/<date month="March" year="2019"\/>/)
  end

  it "joins all eligible identifiers into refcontent" do
    out = biblio_convert(<<~B)
      <bibitem id="MULTI" type="standard"><title>Multi Title</title>
      <docidentifier type="ISO">ISO 2002</docidentifier>
      <docidentifier type="IEEE">IEEE 802.2002</docidentifier>
      <docidentifier type="ISBN">978-0-000-00000-0</docidentifier></bibitem>
    B
    expect(out).to include("<refcontent>ISO 2002, IEEE 802.2002</refcontent>")
    expect(out).not_to include("978-0-000-00000-0")
  end

  it "renders references through the relaton-bib v3 exporter by default" do
    input = <<~INPUT
      #{BLANK_HDR}
      <sections><clause id="c1"><title>Body</title><p id="p1">T.</p></clause></sections>
      <bibliography><references id="R1" normative="true"><title>Normative References</title>
      <bibitem id="EXP" type="standard"><title>Exported Title</title>
      <docidentifier type="W3C">W3C EXP</docidentifier>
      <docidentifier type="metanorma-ordinal">[9]</docidentifier>
      <date type="published"><on>2019-03</on></date></bibitem>
      </references></bibliography>
      </metanorma>
    INPUT
    out = strip_guid(feature_convert(input))
    # the exporter's signature shape: seriesInfo/refcontent inside
    # front is not asserted here — the markers are the exporter date
    # rendering and the ordinal identifier WE strip pre-export
    expect(out).to match(%r{<reference anchor="EXP">})
    expect(out).to include("<refcontent>W3C EXP</refcontent>")
    expect(out).not_to include("[9]")
    expect(out).to match(/<date month="March" year="2019"\/>/)
  end

  it "lets a structured title win over a co-present formattedref" do
    out = biblio_convert(<<~B)
      <bibitem id="FR" type="standard">
      <formattedref format="application/x-isodoc+xml">Full Citation, 1st edition, 2001.</formattedref>
      <title>Fetched Title</title>
      <docidentifier type="W3C">W3C FR</docidentifier></bibitem>
    B
    expect(out).to include("Fetched Title")
    expect(out).not_to include("Full Citation, 1st edition, 2001.")
  end

  it "renders a translator-only contributor instead of Unknown" do
    out = biblio_convert(<<~B)
      <bibitem id="TR" type="standard"><title>Translated Title</title>
      <docidentifier type="W3C">W3C TR</docidentifier>
      <contributor><role type="translator"/><person>
      <name><surname>Vertaler</surname><forename>Taal</forename></name>
      </person></contributor></bibitem>
    B
    expect(out).to match(/<author[^>]* surname="Vertaler"/)
    expect(out).not_to match(/surname="Unknown"/)
  end
end
