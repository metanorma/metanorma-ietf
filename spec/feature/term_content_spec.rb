require "spec_helper"

# Fix-wave specs for metanorma-ietf#300 (terms gaps). Term sources use
# the CURRENT semantic element name <source> (standoc's termsource
# converter emits xml.source; the grammar's "termsource" define is
# named <source>), which the model maps and the full pipeline carries.
# The LEGACY element name <termsource> (older semantic vintages) is
# not aliased by the 0.2.9 model — pending spec at the bottom.
RSpec.describe "IETF term content (#300)" do
  def term_convert(body)
    input = <<~INPUT
      #{BLANK_HDR}
      <sections>
      <terms id="T1"><title>Terms</title>
      #{body}
      </terms>
      </sections>
      </iso-standard>
    INPUT
    strip_guid(feature_convert(input))
  end

  it "emits a live xref for a bibliographic term source" do
    out = term_convert(<<~T)
      <term id="tm1"><preferred><expression><name>alpha</name></expression></preferred>
      <definition><verbal-definition><p id="d1">Def.</p></verbal-definition></definition>
      <source status="identical"><origin bibitemid="RFC2119" type="inline" citeas="RFC 2119"/></source>
      </term>
    T
    expect(out).to match(%r{\[SOURCE: <xref target="RFC2119"/>\]})
    expect(out).not_to include("&lt;xref")
  end

  it "labels an adapted source" do
    out = term_convert(<<~T)
      <term id="tm1"><preferred><expression><name>alpha</name></expression></preferred>
      <definition><verbal-definition><p id="d1">Def.</p></verbal-definition></definition>
      <source status="adapted"><origin bibitemid="RFC2119" type="inline" citeas="RFC 2119"/>
      <modification><p id="m1">with changes</p></modification></source>
      </term>
    T
    expect(out).to include(", adapted")
  end

  it "keeps the modification note regardless of status" do
    pending "MODEL GAP (metanorma-document 0.2.9): <modification> " \
            "parses as a ParagraphBlock that does not map its nested " \
            "<p>, so the modification TEXT is parse-ghosted for every " \
            "status (metanorma-ietf#300, metanorma-document#46 " \
            "family). The transformer appends it status-independently " \
            "— re-test on the model upgrade."
    out = term_convert(<<~T)
      <term id="tm1"><preferred><expression><name>alpha</name></expression></preferred>
      <definition><verbal-definition><p id="d1">Def.</p></verbal-definition></definition>
      <source status="adapted"><origin bibitemid="RFC2119" type="inline" citeas="RFC 2119"/>
      <modification><p id="m1">with changes</p></modification></source>
      </term>
    T
    expect(out).to include(", adapted — with changes")
  end

  it "merges consecutive term sources into one bracket" do
    out = term_convert(<<~T)
      <term id="tm1"><preferred><expression><name>alpha</name></expression></preferred>
      <definition><verbal-definition><p id="d1">Def.</p></verbal-definition></definition>
      <source status="identical"><origin bibitemid="RFC2119" type="inline" citeas="RFC 2119"/></source>
      <source status="identical"><origin bibitemid="RFC2397" type="inline" citeas="RFC 2397"/></source>
      </term>
    T
    expect(out).to match(%r{\[SOURCE: <xref target="RFC2119"/>; <xref target="RFC2397"/>\]})
    expect(out.scan(/\[SOURCE:/).size).to eq 1
  end

  it "renders one definition with two paragraphs without an ol" do
    out = strip_guid(feature_convert(<<~INPUT))
      #{BLANK_HDR}
      <sections>
      <terms id="T1"><title>Terms</title>
      <term id="tm1"><preferred><expression><name>alpha</name></expression></preferred>
      <definition><verbal-definition><p id="d1">First para.</p><p id="d2">Second para.</p></verbal-definition></definition>
      </term>
      </terms>
      </sections>
      </iso-standard>
    INPUT
    expect(out).to include("First para.")
    expect(out).to include("Second para.")
    expect(out).not_to match(%r{<ol[^>]*>.*First para\.}m)
  end

  it "renders two definitions as an enumeration" do
    out = strip_guid(feature_convert(<<~INPUT))
      #{BLANK_HDR}
      <sections>
      <terms id="T1"><title>Terms</title>
      <term id="tm1"><preferred><expression><name>alpha</name></expression></preferred>
      <definition><verbal-definition><p id="d1">First sense.</p></verbal-definition></definition>
      <definition><verbal-definition><p id="d2">Second sense.</p></verbal-definition></definition>
      </term>
      </terms>
      </sections>
      </iso-standard>
    INPUT
    expect(out).to match(%r{<ol[^>]*>.*First sense\..*Second sense\..*</ol>}m)
  end

  it "renders deprecated designations" do
    out = strip_guid(feature_convert(<<~INPUT))
      #{BLANK_HDR}
      <sections>
      <terms id="T1"><title>Terms</title>
      <term id="tm1"><preferred><expression><name>alpha</name></expression></preferred>
      <deprecates><expression><name>oldalpha</name></expression></deprecates>
      <definition><verbal-definition><p id="d1">Def.</p></verbal-definition></definition>
      </term>
      </terms>
      </sections>
      </iso-standard>
    INPUT
    expect(out).to include("DEPRECATED: oldalpha")
  end

  it "parses the legacy termsource element name" do
    pending "LEGACY-NAME GAP (metanorma-document 0.2.9): the model " \
            "maps the CURRENT element name <source> only; the legacy " \
            "<termsource> of older semantic vintages is not aliased, " \
            "so legacy-shaped inputs lose their term sources " \
            "(metanorma-ietf#300 discussion)."
    out = strip_guid(feature_convert(<<~INPUT))
      #{BLANK_HDR}
      <sections>
      <terms id="T1"><title>Terms</title>
      <term id="tm1"><preferred><expression><name>alpha</name></expression></preferred>
      <definition><verbal-definition><p id="d1">Def.</p></verbal-definition></definition>
      <termsource status="identical"><origin bibitemid="RFC2119" type="inline" citeas="RFC 2119"/></termsource>
      </term>
      </terms>
      </sections>
      </iso-standard>
    INPUT
    expect(out).to include("[SOURCE:")
  end

  it "renders a letter-symbol designation name" do
    pending "MODEL GAP (metanorma-document 0.2.9): Designation maps " \
            "only expression/geographic_area — <letter-symbol> (and " \
            "<graphical-symbol>) designations are parse-ghosted " \
            "(metanorma-ietf#300, metanorma-document#46 family)."
    out = strip_guid(feature_convert(<<~INPUT))
      #{BLANK_HDR}
      <sections>
      <terms id="T1"><title>Terms</title>
      <term id="tm1"><preferred><letter-symbol><name>β</name></letter-symbol></preferred>
      <definition><verbal-definition><p id="d1">Beta def.</p></verbal-definition></definition>
      </term>
      </terms>
      </sections>
      </iso-standard>
    INPUT
    expect(out).to include("β")
  end
end
