require "spec_helper"

# WS3 port of spec/isodoc/lists_spec.rb. Same inputs except the
# ordered-lists example (adapted, see its comment); expectations
# regenerated against the default pipeline — the old expectations
# captured the released path's DEBUG (pre-cleanup) output.
RSpec.describe "IETF list rendering (WS3)" do
  it "processes unordered lists" do
    # nobullet="true" renders as empty="true", as the released path does
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <ul id="_61961034-0fb1-436b-b281-828857a59ddb" nobullet="true" spacing="compact" indent="5" bare="true">
        <li>
          <p id="_cb370dd3-8463-4ec7-aa1a-96f644e2e9a2">updated normative references;</p>
        </li>
        <li>
          <p id="_60eb765c-1f6c-418a-8016-29efa06bf4f9">deletion of 4.3.</p>
        </li>
      </ul>
      </foreword></preface>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <?xml version="1.0" encoding="utf-8"?>
      <?rfc sortrefs="yes"?>
      <?rfc symrefs="yes"?>
      <?rfc tocdepth="4"?>
      <?rfc subcompact="no"?>
      <?rfc compact="yes"?>
      <?rfc strict="yes"?>
      <rfc category="std" ipr="trust200902" submissionType="IETF" version="3" xml:lang="en">
        <front>
          <title/>
          <seriesInfo name="Internet-Draft" value="" asciiName="Internet-Draft" status="Informational" stream="IETF"/>
          <date day="1" month="January" year="2000"/>
          <abstract anchor="_ed83a3a2-f474-f409-00f5-da0bf4778879">
            <ul anchor="_61961034-0fb1-436b-b281-828857a59ddb" spacing="compact" bare="true" indent="5">
              <li>
                <t anchor="_cb370dd3-8463-4ec7-aa1a-96f644e2e9a2">updated normative references;</t>
              </li>
              <li>
                <t anchor="_60eb765c-1f6c-418a-8016-29efa06bf4f9">deletion of 4.3.</t>
              </li>
            </ul>
          </abstract>
        </front>
        <middle/>
        <back/>
      </rfc>
    OUTPUT
    expect(strip_guid(feature_convert(input)))
      .to be_xml_equivalent_to strip_guid(output)
  end

  it "processes ordered lists" do
    # INPUT ADAPTED (WS3): the original nested <ol> directly inside
    # <ol>, a shape no toolchain emits and RFC 7991 forbids (ol :=
    # li+; the old DEBUG expectation just echoed it). Restructured to
    # the standoc shape: nested list inside the preceding li.
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface><foreword>
      <ol id="_ae34a226-aab4-496d-987b-1aa7b6314026" type="alphabet" start="7" spacing="compact" group="X" indent="5">
        <li>
          <p id="_0091a277-fb0e-424a-aea8-f0001303fe78">all information necessary for the complete identification of the sample;</p>
          <ol>
            <li>
              <p id="_8a7b6299-db05-4ff8-9de7-ff019b9017b2">a reference to this document (i.e. ISO 17301-1);</p>
              <ol>
                <li>
                  <p id="_ea248b7f-839f-460f-a173-a58a830b2abe">the sampling method used;</p>
                </li>
              </ol>
            </li>
          </ol>
        </li>
      </ol>
      </foreword></preface>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <?xml version="1.0" encoding="utf-8"?>
      <?rfc sortrefs="yes"?>
      <?rfc symrefs="yes"?>
      <?rfc tocdepth="4"?>
      <?rfc subcompact="no"?>
      <?rfc compact="yes"?>
      <?rfc strict="yes"?>
      <rfc category="std" ipr="trust200902" submissionType="IETF" version="3" xml:lang="en">
        <front>
          <title/>
          <seriesInfo name="Internet-Draft" value="" asciiName="Internet-Draft" status="Informational" stream="IETF"/>
          <date day="1" month="January" year="2000"/>
          <abstract anchor="_e248a5b0-6f07-cd90-9d9f-538bc3e4cc59">
            <ol anchor="_ae34a226-aab4-496d-987b-1aa7b6314026" type="a" start="7" group="X" spacing="compact" indent="5">
              <li>
                <t anchor="_0091a277-fb0e-424a-aea8-f0001303fe78">all information necessary for the complete identification of the sample;</t>
                <ol type="1">
                  <li>
                    <t anchor="_8a7b6299-db05-4ff8-9de7-ff019b9017b2">a reference to this document (i.e. ISO 17301-1);</t>
                    <ol type="i">
                      <li>
                        <t anchor="_ea248b7f-839f-460f-a173-a58a830b2abe">the sampling method used;</t>
                      </li>
                    </ol>
                  </li>
                </ol>
              </li>
            </ol>
          </abstract>
        </front>
        <middle/>
        <back/>
      </rfc>
    OUTPUT
    expect(strip_guid(feature_convert(input)))
      .to be_xml_equivalent_to strip_guid(output)
  end

  it "processes Roman Upper ordered lists" do
    # roman_upper maps to type="I" (B-6 canonical ol types)
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <ol id="_ae34a226-aab4-496d-987b-1aa7b6314026" type="roman_upper">
        <li anchor="_ae34a226-aab4-496d-987b-1aa7b6314027">
          <p id="_0091a277-fb0e-424a-aea8-f0001303fe78">all information necessary for the complete identification of the sample;</p>
        </li>
        <li>
          <p id="_8a7b6299-db05-4ff8-9de7-ff019b9017b2">a reference to this document (i.e. ISO 17301-1);</p>
        </li>
        <li>
          <p id="_ea248b7f-839f-460f-a173-a58a830b2abe">the sampling method used;</p>
        </li>
      </ol>
      </foreword></preface>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <?xml version="1.0" encoding="utf-8"?>
      <?rfc sortrefs="yes"?>
      <?rfc symrefs="yes"?>
      <?rfc tocdepth="4"?>
      <?rfc subcompact="no"?>
      <?rfc compact="yes"?>
      <?rfc strict="yes"?>
      <rfc category="std" ipr="trust200902" submissionType="IETF" version="3" xml:lang="en">
        <front>
          <title/>
          <seriesInfo name="Internet-Draft" value="" asciiName="Internet-Draft" status="Informational" stream="IETF"/>
          <date day="1" month="January" year="2000"/>
          <abstract anchor="_697ec077-372f-95fa-cbaa-008711519010">
            <ol anchor="_ae34a226-aab4-496d-987b-1aa7b6314026" type="I">
              <li>
                <t anchor="_0091a277-fb0e-424a-aea8-f0001303fe78">all information necessary for the complete identification of the sample;</t>
              </li>
              <li>
                <t anchor="_8a7b6299-db05-4ff8-9de7-ff019b9017b2">a reference to this document (i.e. ISO 17301-1);</t>
              </li>
              <li>
                <t anchor="_ea248b7f-839f-460f-a173-a58a830b2abe">the sampling method used;</t>
              </li>
            </ol>
          </abstract>
        </front>
        <middle/>
        <back/>
      </rfc>
    OUTPUT
    expect(strip_guid(feature_convert(input)))
      .to be_xml_equivalent_to strip_guid(output)
  end

  it "processes definition lists" do
    # MODEL GAP (0.2.9 ledger): the AsciiMath stem in the second <dt>
    # parses empty (<stem type="AsciiMath"/>), so the dt renders
    # empty; re-test on 0.4.x. The dl-attached <note> renders as an
    # unnumbered NOTE paragraph after the list — an <aside> is not
    # admissible in <abstract> ((dl|ol|t|ul)+), and notes are
    # unnumbered by the #233 concession.
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <dl id="_732d3f57-4f88-40bf-9ae9-633891edc395" newline="true" spacing="compact" indent="5">
        <dt id="A">
          W
        </dt>
        <dd id="B">
          <p id="_05d81174-3a41-44af-94d8-c78b8d2e175d">mass fraction of gelatinized kernels, expressed in per cent</p>
        </dd>
        <dt><stem type="AsciiMath">w</stem></dt>
        <dd><p>??</p></dd>
        <note><p>This is a note</p></note>
        </dl>
      </foreword></preface>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <?xml version="1.0" encoding="utf-8"?>
      <?rfc sortrefs="yes"?>
      <?rfc symrefs="yes"?>
      <?rfc tocdepth="4"?>
      <?rfc subcompact="no"?>
      <?rfc compact="yes"?>
      <?rfc strict="yes"?>
      <rfc category="std" ipr="trust200902" submissionType="IETF" version="3" xml:lang="en">
        <front>
          <title/>
          <seriesInfo name="Internet-Draft" value="" asciiName="Internet-Draft" status="Informational" stream="IETF"/>
          <date day="1" month="January" year="2000"/>
          <abstract anchor="_3399f778-d5b4-bd70-c3ff-f2d9458f4614">
            <dl anchor="_732d3f57-4f88-40bf-9ae9-633891edc395" spacing="compact" newline="true" indent="5">
              <dt anchor="A">
          W
        </dt>
              <dd anchor="B">
                <t anchor="_05d81174-3a41-44af-94d8-c78b8d2e175d">mass fraction of gelatinized kernels, expressed in per cent</t>
              </dd>
              <dt/>
              <dd>
                <t>??</t>
              </dd>
            </dl>
            <t>NOTE: This is a note</t>
          </abstract>
        </front>
        <middle/>
        <back/>
      </rfc>
    OUTPUT
    expect(strip_guid(feature_convert(input)))
      .to be_xml_equivalent_to strip_guid(output)
  end

end
