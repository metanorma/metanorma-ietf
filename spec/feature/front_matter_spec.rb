require "spec_helper"

# Fix-wave specs for metanorma-ietf#298 (front-matter gaps). Inputs
# are BLANK_HDR variants built by targeted substitution.
RSpec.describe "IETF front matter (#298)" do
  def hdr_with(bibdata_insert: nil, ext_insert: nil, doctype: nil)
    hdr = BLANK_HDR.dup
    hdr = hdr.sub("<doctype>internet-draft</doctype>",
                  "<doctype>#{doctype}</doctype>") if doctype
    hdr = hdr.sub('<bibdata type="standard">',
                  "<bibdata type=\"standard\">\n#{bibdata_insert}") if bibdata_insert
    hdr = hdr.sub("<ipr>trust200902</ipr>",
                  "<ipr>trust200902</ipr>\n#{ext_insert}") if ext_insert
    hdr
  end

  BODY = <<~XML.freeze
    <sections><clause id="c1"><title>Body</title><p id="p1">T.</p></clause></sections>
    </iso-standard>
  XML

  it "stamps showOnFrontPage on author organizations" do
    input = hdr_with(
      bibdata_insert: <<~B,
        <contributor><role type="author"/>
        <person><name><completename>Fred Flintstone</completename></name>
        <affiliation><organization><name>Slate Rock and Gravel Company</name></organization></affiliation>
        </person></contributor>
      B
      ext_insert: "<showOnFrontPage>false</showOnFrontPage>",
    ) + BODY
    out = strip_guid(feature_convert(input))
    expect(out).to match(/<organization[^>]* showOnFrontPage="false"/)
  end

  it "carries an organizational author's address" do
    input = hdr_with(bibdata_insert: <<~B) + BODY
      <contributor><role type="author"/>
      <organization><name>IETF Tools Team</name>
      <address><formattedAddress>1 Main Street<br/>Springfield</formattedAddress></address>
      <contact><phone>555-0100</phone><email>tools@example.org</email></contact>
      </organization></contributor>
    B
    out = strip_guid(feature_convert(input))
    expect(out).to match(%r{<author>\s*<organization[^>]*>IETF Tools Team</organization>\s*<address>}m)
    expect(out).to include("<postalLine>1 Main Street</postalLine>")
    expect(out).to include("<phone>555-0100</phone>")
    expect(out).to include("<email>tools@example.org</email>")
  end

  it "carries the intended-series number as seriesInfo value" do
    input = hdr_with(doctype: "rfc", bibdata_insert: <<~B) + BODY
      <docnumber>1000</docnumber>
      <series type="intended"><title>BCP</title><number>14</number></series>
    B
    out = strip_guid(feature_convert(input))
    expect(out).to include('<seriesInfo name="" value="14" status="BCP"/>')
  end

  it "prefers authored initials over forename-derived" do
    input = hdr_with(bibdata_insert: <<~B) + BODY
      <contributor><role type="author"/>
      <person><name>
      <forename>Barney</forename><initials>B. X.</initials><surname>Rubble</surname>
      </name></person></contributor>
    B
    out = strip_guid(feature_convert(input))
    expect(out).to match(/<author[^>]* initials="B\. X\."/)
  end

  it "prefers the authored singular initial element" do
    pending "MODEL GAP (metanorma-document 0.2.9): FullName maps only " \
            "the plural <initials>; the singular <initial> the standoc " \
            "converter emits is parse-ghosted (metanorma-ietf#298, " \
            "metanorma-document#46 family). The precedence code is in " \
            "place — re-test on the model upgrade."
    input = hdr_with(bibdata_insert: <<~B) + BODY
      <contributor><role type="author"/>
      <person><name>
      <forename>Barney</forename><initial>B. X.</initial><surname>Rubble</surname>
      </name></person></contributor>
    B
    out = strip_guid(feature_convert(input))
    expect(out).to match(/<author[^>]* initials="B\. X\."/)
  end

  it "strips the legacy rfc- prefix from docnumbers" do
    input = hdr_with(doctype: "rfc", bibdata_insert: "<docnumber>rfc-8341</docnumber>") + BODY
    out = strip_guid(feature_convert(input))
    expect(out).to match(/<rfc[^>]* number="8341"/)
    expect(out).to include('<seriesInfo name="RFC" value="8341"')
  end

  it "collects foreword notes when an abstract coexists" do
    input = hdr_with + <<~XML
      <preface>
      <abstract id="a1"><p id="pa">Abstract text.</p></abstract>
      <foreword id="f1"><p id="pf">Foreword text.</p>
      <note id="n1"><name>Note Title</name><p id="pn">FOREWORDNOTE</p></note>
      </foreword>
      </preface>
      <sections><clause id="c1"><title>Body</title><p id="p1">T.</p></clause></sections>
      </iso-standard>
    XML
    out = strip_guid(feature_convert(input))
    expect(out).to match(%r{<note[^>]*>.*FOREWORDNOTE.*</note>}m)
  end

  it "normalises datetime revdates and omits unparseable dates" do
    input = hdr_with(bibdata_insert: '<date type="published"><on>2003-04-01T00:00:00Z</on></date>') + BODY
    out = strip_guid(feature_convert(input))
    expect(out).to match(/<date day="1" month="April" year="2003"\/>/)

    input2 = hdr_with(bibdata_insert: '<date type="published"><on>circa 2000</on></date>') + BODY
    out2 = strip_guid(feature_convert(input2))
    expect(out2).not_to match(/year="circ/)
  end
end
