require "spec_helper"

RSpec.describe IsoDoc::Ietf::RfcConvert do
  it "processes document with no content" do
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface/>
          <sections/>
        </iso-standard>
    INPUT
    #{RFC_HDR}
          <middle/>
          <back/>
        </rfc>
    OUTPUT
    end

  it "processes section names" do
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
     <?xml version='1.0'?>
        <?rfc strict="yes"?>
        <?rfc compact="yes"?>
        <?rfc subcompact="no"?>
        <?rfc tocdepth="4"?>
        <?rfc symrefs="yes"?>
        <?rfc sortrefs="yes"?>
        <rfc xmlns:xi='http://www.w3.org/2001/XInclude' category='std' submissionType='IETF' version='3'>
          <front>
            <seriesInfo value='' name='RFC' asciiName='RFC'/>
            <abstract> </abstract>
          </front>
          <middle>
            <section anchor='B'>
              <name>Introduction</name>
              <section anchor='C'>
                <name>Introduction Subsection</name>
              </section>
            </section>
            <section>
  <name>Acknowledgements</name>
  <t anchor='A1'>This is a preamble</t>
</section>
            <section anchor='D'>
              <name>Scope</name>
              <t anchor='E'>Text</t>
            </section>
            <section anchor='H'>
              <name>Terms, Definitions, Symbols and Abbreviated Terms</name>
              <section anchor='I'>
                <name>Normal Terms</name>
                <section anchor='J'>
                  <name>Term2</name>
                </section>
              </section>
              <section anchor='K'>
                <name>Definitions</name>
                <dl>
                  <dt>Symbol</dt>
                  <dd>Definition</dd>
                </dl>
              </section>
            </section>
            <section anchor='L'>
              <dl>
                <dt>Symbol</dt>
                <dd>Definition</dd>
              </dl>
            </section>
            <section anchor='M'>
              <name>Clause 4</name>
              <section anchor='N'>
                <name>Introduction</name>
              </section>
              <section anchor='O'>
                <name>Clause 4.2</name>
              </section>
              <section anchor='O1'> </section>
            </section>
          </middle>
          <back>
          <references anchor='O4'>
  <name>Refs</name>
            <references anchor='Q2'>
              <name>Annex Bibliography</name>
            </references>
            </references>
            <references anchor='R'>
              <name>Normative References</name>
            </references>
            <references anchor='S'>
  <name>Bibliography</name>
            <references anchor='T'>
              <name>Bibliography Subsection</name>
            </references>
            </references>
            <section anchor='P'>
              <name>Annex</name>
              <section anchor='Q'>
                <name>Annex A.1</name>
                <section anchor='Q1'>
                  <name>Annex A.1a</name>
                </section>
              </section>
            </section>
          </back>
        </rfc>
OUTPUT
  end

  it "processes simple terms & definitions" do
        expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
  #{RFC_HDR}
  <middle>
    <section anchor='H'>
      <name>Terms, Definitions, Symbols and Abbreviated Terms</name>
      <section anchor='J'>
        <name>Term2</name>
      </section>
    </section>
  </middle>
  <back/>
</rfc>
    OUTPUT
  end


        it "processes sections without titles" do
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
    #{RFC_HDR}
    <middle>
    <section anchor='M'>
  <section anchor='N'>
    <name>Intro</name>
  </section>
  <section anchor='O'> </section>
</section>
    <section anchor='M1'>
      <section anchor='N1'> </section>
      <section anchor='O1'> </section>
    </section>
  </middle>
  <back/>
</rfc>
OUTPUT
    end

        it "processes section attributes" do
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
    #{RFC_HDR}
  <middle>
    <section anchor='_' numbered='true' removeInRFC='true' toc='true'>
      <name>Clause</name>
    </section>
  </middle>
  <back>
    <section anchor='_' numbered='true' removeInRFC='true' toc='true'>
      <name>Appendix</name>
    </section>
  </back>
</rfc>
OUTPUT
        end


end
