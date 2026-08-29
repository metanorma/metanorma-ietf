require "spec_helper"

# Fix-wave specs for metanorma-ietf#299: numbered/removeInRFC section
# attributes (per-element recovery side-channel), the tocDepth root
# trio (F5-channel siblings), and preface clauses/executive summary.
RSpec.describe "IETF section and root attributes (#299)" do
  def hdr_ext(extra)
    BLANK_HDR.sub("<ipr>trust200902</ipr>", "<ipr>trust200902</ipr>\n#{extra}")
  end

  it "carries numbered=false via the boolean unnumbered mapping" do
    input = <<~INPUT
      #{BLANK_HDR}
      <sections><clause id="c1" unnumbered="true"><title>Unnumbered</title><p id="p1">T.</p></clause></sections>
      </iso-standard>
    INPUT
    out = strip_guid(feature_convert(input))
    expect(out).to match(/<section[^>]* numbered="false"/)
  end

  it "recovers the converter's numbered attribute" do
    input = <<~INPUT
      #{BLANK_HDR}
      <sections><clause id="c1" numbered="false"><title>Unnumbered</title><p id="p1">T.</p></clause></sections>
      </iso-standard>
    INPUT
    out = strip_guid(feature_convert(input))
    expect(out).to match(/<section[^>]* numbered="false"/)
  end

  it "recovers removeInRFC on sections" do
    input = <<~INPUT
      #{BLANK_HDR}
      <sections><clause id="c1" removeInRFC="true"><title>Ephemeral</title><p id="p1">T.</p></clause></sections>
      </iso-standard>
    INPUT
    out = strip_guid(feature_convert(input))
    expect(out).to match(/<section[^>]* removeInRFC="true"/)
  end

  it "carries tocDepth, indexInclude and iprExtract onto the rfc root" do
    input = hdr_ext("<tocDepth>2</tocDepth>\n<indexInclude>false</indexInclude>\n<iprExtract>c1</iprExtract>") + <<~XML
      <sections><clause id="c1"><title>Body</title><p id="p1">T.</p></clause></sections>
      </iso-standard>
    XML
    out = strip_guid(feature_convert(input))
    expect(out).to match(/<rfc[^>]* tocDepth="2"/)
    expect(out).to match(/<rfc[^>]* indexInclude="false"/)
    expect(out).to match(/<rfc[^>]* iprExtract="c1"/)
  end

  it "carries generic preface clauses and the executive summary into middle" do
    input = <<~INPUT
      #{BLANK_HDR}
      <preface>
      <clause id="pc1"><title>Preface Clause</title><p id="pp1">PREFCLAUSEBODY</p></clause>
      <executivesummary id="es1"><title>Executive Summary</title><p id="pe1">EXECSUMBODY</p></executivesummary>
      </preface>
      <sections><clause id="c1"><title>Body</title><p id="p1">T.</p></clause></sections>
      </iso-standard>
    INPUT
    out = strip_guid(feature_convert(input))
    expect(out).to include("PREFCLAUSEBODY")
    expect(out).to include("EXECSUMBODY")
  end
end
