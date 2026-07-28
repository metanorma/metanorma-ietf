require "spec_helper"

# WS3 port of spec/isodoc/section_spec.rb: same inputs, the full
# default pipeline in place of IsoDoc::Ietf::RfcConvert;
# expectations regenerated (the old ones captured the released
# path's DEBUG pre-cleanup output). Notable behaviours asserted:
# introduction subsections (the model maps them as :subsection);
# clause-carried and bibliography references render as back-matter
# <references> trees (v3 admits references only in <back>).
RSpec.describe "IETF section rendering (WS3)" do
  it "processes document with no content" do
    # skeleton systematics: the new-path front (title/, Internet-Draft
    # seriesInfo, ipr/xml:lang defaults)
    input = <<~INPUT
        <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface/>
        <sections/>
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
        </front>
        <middle/>
        <back/>
      </rfc>
    OUTPUT
    expect(strip_guid(feature_convert(input)))
      .to be_xml_equivalent_to strip_guid(output)
  end

  it "processes section names" do
    # foreword -> abstract; introduction/acknowledgements -> middle;
    # clauses carrying <references> (O4/Q2) and the bibliography's
    # references/clauses (R, S/T) relocate to <back> as references
    # trees, in the released path's order; annexes follow as sections
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface>
      <abstract obligation="informative">
       <title>Foreword</title>
      </abstract>
      <foreword obligation="informative">
       <title>Foreword</title>
       <p id="A">This is a preamble</p>
       </foreword>
      <introduction id="B" obligation="informative"><title>Introduction</title><clause id="C" inline-header="false" obligation="informative">
       <title>Introduction Subsection</title>
       </clause>
       </introduction>
       <acknowledgements obligation="informative">
       <title>Acknowledgements</title>
       <p id="A1">This is a preamble</p>
       </acknowledgements>
      </preface><sections>
       <clause id="D" obligation="normative">
       <title>Scope</title>
       <p id="E">Text</p>
       </clause>

       <clause id="H" obligation="normative"><title>Terms, Definitions, Symbols and Abbreviated Terms</title><terms id="I" obligation="normative">
       <title>Normal Terms</title>
       <term id="J">
       <preferred><expression><name>Term2</name></expression></preferred>
       </term>
       </terms>
       <definitions id="K">
       <title>Definitions</title>
       <dl>
       <dt>Symbol</dt>
       <dd>Definition</dd>
       </dl>
       </definitions>
       </clause>
       <definitions id="L">
       <dl>
       <dt>Symbol</dt>
       <dd>Definition</dd>
       </dl>
       </definitions>
       <clause id="M" inline-header="false" obligation="normative"><title>Clause 4</title><clause id="N" inline-header="false" obligation="normative">
       <title>Introduction</title>
       </clause>
       <clause id="O" inline-header="false" obligation="normative">
       <title>Clause 4.2</title>
       </clause>
       <clause id="O1" inline-header="false" obligation="normative">
       </clause>
      </clause>
      <clause id="O4"><title>Refs</title>
      <references id="Q2" normative="false"><title>Annex Bibliography</title></references>
      </clause>

       </sections><annex id="P" inline-header="false" obligation="normative">
       <title>Annex</title>
       <clause id="Q" inline-header="false" obligation="normative">
       <title>Annex A.1</title>
       <clause id="Q1" inline-header="false" obligation="normative">
       <title>Annex A.1a</title>
       </clause>
       </clause>
       </annex><bibliography><references id="R" obligation="informative" normative="true">
       <title>Normative References</title>
       </references><clause id="S" obligation="informative">
       <title>Bibliography</title>
       <references id="T" obligation="informative" normative="false">
       <title>Bibliography Subsection</title>
       </references>
       </clause>
       </bibliography>
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
          <abstract anchor="_d96948c0-ac15-db56-ecc7-cf6a3590a17a"/>
        </front>
        <middle>
          <section anchor="B">
            <name>Introduction</name>
            <section anchor="C">
              <name>Introduction Subsection</name>
            </section>
          </section>
          <section anchor="_edceca78-e9f7-c8ed-b212-6de0fcb9676d">
            <name>Acknowledgements</name>
            <t anchor="A1">This is a preamble</t>
          </section>
          <section anchor="D">
            <name>Scope</name>
            <t anchor="E">Text</t>
          </section>
          <section anchor="H">
            <name>Terms, Definitions, Symbols and Abbreviated Terms</name>
            <section anchor="I">
              <name>Normal Terms</name>
              <section anchor="J">
                <name>Term2</name>
              </section>
            </section>
            <section anchor="K">
              <name>Definitions</name>
              <dl>
                <dt>Symbol</dt>
                <dd>Definition</dd>
              </dl>
            </section>
          </section>
          <section anchor="L">
            <name>Symbols</name>
            <dl>
              <dt>Symbol</dt>
              <dd>Definition</dd>
            </dl>
          </section>
          <section anchor="M">
            <name>Clause 4</name>
            <section anchor="N">
              <name>Introduction</name>
            </section>
            <section anchor="O">
              <name>Clause 4.2</name>
            </section>
            <section anchor="O1"/>
          </section>
        </middle>
        <back>
          <references anchor="O4">
            <name>Refs</name>
            <references anchor="Q2">
              <name>Annex Bibliography</name>
            </references>
          </references>
          <references anchor="R">
            <name>Normative References</name>
          </references>
          <references anchor="S">
            <name>Bibliography</name>
            <references anchor="T">
              <name>Bibliography Subsection</name>
            </references>
          </references>
          <section anchor="P">
            <name>Annex</name>
            <section anchor="Q">
              <name>Annex A.1</name>
              <section anchor="Q1">
                <name>Annex A.1a</name>
              </section>
            </section>
          </section>
        </back>
      </rfc>
    OUTPUT
    expect(strip_guid(feature_convert(input)))
      .to be_xml_equivalent_to strip_guid(output)
  end

  it "processes simple terms & definitions" do
    input = <<~INPUT
             <iso-standard xmlns="http://riboseinc.com/isoxml">
       <sections>
       <terms id="H" obligation="normative"><title>Terms, Definitions, Symbols and Abbreviated Terms</title>
       <term id="J">
       <preferred><expression><name>Term2</name></expression></preferred>
       </term>
      </terms>
      </sections>
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
        </front>
        <middle>
          <section anchor="H">
            <name>Terms, Definitions, Symbols and Abbreviated Terms</name>
            <section anchor="J">
              <name>Term2</name>
            </section>
          </section>
        </middle>
        <back/>
      </rfc>
    OUTPUT
    expect(strip_guid(feature_convert(input)))
      .to be_xml_equivalent_to strip_guid(output)
  end

  it "processes sections without titles" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface>
       <introduction id="M" inline-header="false" obligation="normative"><clause id="N" inline-header="false" obligation="normative">
       <title>Intro</title>
       </clause>
       <clause id="O" inline-header="true" obligation="normative">
       </clause></clause>
       </preface>
       <sections>
       <clause id="M1" inline-header="false" obligation="normative"><clause id="N1" inline-header="false" obligation="normative">
       </clause>
       <clause id="O1" inline-header="true" obligation="normative">
       </clause></clause>
       </sections>

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
        </front>
        <middle>
          <section anchor="M">
            <section anchor="N">
              <name>Intro</name>
            </section>
            <section anchor="O"/>
          </section>
          <section anchor="M1">
            <section anchor="N1"/>
            <section anchor="O1"/>
          </section>
        </middle>
        <back/>
      </rfc>
    OUTPUT
    expect(strip_guid(feature_convert(input)))
      .to be_xml_equivalent_to strip_guid(output)
  end

  it "processes section attributes" do
    input = <<~INPUT
      <ietf-standard xmlns="http://riboseinc.com/isoxml">
         <sections>
       <clause id='_' numbered='true' removeInRFC='true' toc='true' inline-header='false' obligation='normative'>
         <title>Clause</title>
       </clause>
       </sections>
       <annex id='_' numbered='true' removeInRFC='true' toc='true' inline-header='false' obligation='normative'>
       <title>Appendix</title>
       </annex>
      </ietf-standard>
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
        </front>
        <middle>
          <section anchor="_" toc="true">
            <name>Clause</name>
          </section>
        </middle>
        <back>
          <section anchor="_" toc="true">
            <name>Appendix</name>
          </section>
        </back>
      </rfc>
    OUTPUT
    expect(strip_guid(feature_convert(input)))
      .to be_xml_equivalent_to strip_guid(output)
  end

end
