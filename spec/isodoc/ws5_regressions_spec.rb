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

  it "keeps a blank line inside a literal block's artwork (#286)" do
    out = ws5_convert(<<~BODY)
      <sections><clause id="A"><title>C</title>
      <figure id="F"><pre>    LINE ONE

    LINE TWO</pre></figure>
      </clause></sections>
    BODY
    # the squiggly heredoc strips the lines' common indent;
    # the blank line inside the artwork is the point
    expect(out).to include "LINE ONE\n\nLINE TWO"
  end

  it "keeps a literal ampersand in a definition-list term (#287)" do
    out = ws5_convert(<<~BODY)
      <sections><clause id="A"><title>C</title>
      <dl id="D1"><dt>Person &amp; email address: </dt>
      <dd id="DD1"><p id="P2">list</p></dd></dl>
      </clause></sections>
    BODY
    dt = Nokogiri::XML(out).at("//dt")
    expect(dt.text).to eq "Person & email address: "
  end

  STD_BIBITEM = <<~BIB.freeze
    <bibliography><references id="_n" normative="true"><title>Normative References</title>
    <bibitem id="RFC3629" anchor="RFC3629" type="standard">
    <title type="main">UTF-8, a transformation format of ISO 10646</title>
    <uri type="src">https://www.rfc-editor.org/info/rfc3629</uri>
    <docidentifier type="IETF" primary="true">RFC 3629</docidentifier>
    <docidentifier type="DOI">10.17487/RFC3629</docidentifier>
    <date type="published"><on>2003-11</on></date>
    <contributor><role type="author"/><person><name><completename>F. Yergeau</completename></name></person></contributor>
    <contributor><role type="publisher"/><organization><name>RFC Publisher</name></organization></contributor>
    <series><title>STD</title><number>63</number></series>
    <series><title>RFC</title><number>3629</number></series>
    </bibitem>
    </references></bibliography>
  BIB

  it "labels an STD sub-series as STD, not BCP (#282)" do
    out = ws5_convert(<<~BODY, bibliography: STD_BIBITEM)
      <sections><clause id="A"><title>C</title><p id="P">See <eref bibitemid="RFC3629"/>.</p></clause></sections>
    BODY
    ref = Nokogiri::XML(out).at("//reference[@anchor='RFC3629']")
    expect(ref.at(".//seriesInfo[@name='STD']/@value")&.text).to eq "63"
    expect(ref.at(".//seriesInfo[@name='BCP']")).to be_nil
  end

  it "emits seriesInfo for Internet-Draft references (#283)" do
    out = ws5_convert(<<~BODY, bibliography: <<~BIB)
      <sections><clause id="A"><title>C</title><p id="P">See <eref bibitemid="ID1"/>.</p></clause></sections>
    BODY
      <bibliography><references id="_n" normative="true"><title>Normative References</title>
      <bibitem id="ID1" anchor="ID1" type="standard">
      <title type="main">Origin Cookies</title>
      <uri type="src">https://datatracker.ietf.org/doc/html/draft-abarth-cake-01</uri>
      <docidentifier type="Internet-Draft">draft-abarth-cake</docidentifier>
      <docidentifier type="Internet-Draft" primary="true">draft-abarth-cake-01</docidentifier>
      <date type="published"><on>2011-03-05</on></date>
      <contributor><role type="author"/><person><name><completename>A. Barth</completename></name></person></contributor>
      <series type="main"><title>Internet-Draft</title><number>draft-abarth-cake-01</number></series>
      </bibitem>
      </references></bibliography>
    BIB
    ref = Nokogiri::XML(out).at("//reference[@anchor='ID1']")
    si = ref.at(".//seriesInfo[@name='Internet-Draft']")
    expect(si).not_to be_nil
    expect(si["value"]).to eq "draft-abarth-cake-01"
  end
end
