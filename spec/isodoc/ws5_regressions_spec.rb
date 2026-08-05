require "spec_helper"

# Regressions surfaced by the metanorma-ietf#233 QA heritage battery
# (issues #282-#287): each example is the minimal repro from the
# corresponding ticket.
RSpec.describe IsoDoc::Ietf do
  HDR = <<~HDR.freeze
    <bibdata>
    <title language="en" format="text/plain" type="main">Test</title>
    <docidentifier>draft-test-00</docidentifier><docnumber>10</docnumber>
    <contributor><role type="author"/><person>
    <name><completename>Arthur son of Uther Pendragon</completename></name></person></contributor>
    <ext><ipr>trust200902</ipr></ext>
    </bibdata>
  HDR

  def ws5_convert(body, bibliography: "")
    FileUtils.rm_f "test.rfc.xml"
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      #{HDR}
      #{body}
      #{bibliography}
      </iso-standard>
    INPUT
    IsoDoc::Ietf::RfcConvert.new({}).convert("test", input, false)
    File.read("test.rfc.xml")
  end

  it "renders every abstract note, not just the first (#285)" do
    out = ws5_convert(<<~BODY)
      <preface><abstract id="_abs">
      <p id="_p1">Abstract text.</p>
      <note id="_n1"><p id="_np1">First note.</p></note>
      <note id="_n2"><p id="_np2">Second note.</p></note>
      </abstract></preface>
      <sections><clause id="A"><title>C</title><p id="P">Body.</p></clause></sections>
    BODY
    notes = Nokogiri::XML(out).xpath("//front/note")
    expect(notes.size).to eq 2
    expect(notes[1].text).to include "Second note."
  end
end
