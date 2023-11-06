require "spec_helper"
require "relaton_iec"
require "fileutils"

RSpec.describe Metanorma::Ietf do
  it "removes empty text elements" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      == {blank}
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
             <sections>
        <clause id="_" inline-header="false" obligation="normative">

      </clause>
      </sections>
      </ietf-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "removes empty abstracts" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}

      [abstract]
      ABC
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
             <sections>
      </sections>
      </ietf-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "moves term domains out of the term definition paragraph" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      == Terms and Definitions

      === Tempus

      domain:[relativity] Time
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
             <sections>
        <terms id="_" obligation="normative">
        <title>Terms and definitions</title>
        <term id="term-_lt_relativity_gt_-Tempus">
        <preferred><expression><name>Tempus</name></expression></preferred>
        <domain>relativity</domain>
        <definition><verbal-definition><p id="_"> Time</p></verbal-definition></definition>
      </term>
      </terms>
      </sections>
      </ietf-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "permits multiple blocks in term definition paragraph" do
    input = <<~INPUT
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :stem:

      == Terms and Definitions

      === stem:[t_90]

      [.definition]
      --
      This paragraph is extraneous

      [stem]
      ++++
      t_A
      ++++
      --
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
               <sections>
           <terms id="_" obligation="normative">
             <title>Terms and definitions</title>
             <term id="term-t_90">
               <preferred>
                 <letter-symbol>
                   <name>
                     <stem type="MathML" block="false">
                       <math xmlns="http://www.w3.org/1998/Math/MathML">
                         <mstyle displaystyle="false">
                           <msub>
                             <mi>t</mi>
                             <mn>90</mn>
                           </msub>
                         </mstyle>
                       </math>
                       <asciimath>t_90</asciimath>
                     </stem>
                   </name>
                 </letter-symbol>
               </preferred>
               <definition>
                 <verbal-definition>
                   <p id="_">This paragraph is extraneous</p>
                   <formula id="_">
                     <stem type="MathML" block="true">
                       <math xmlns="http://www.w3.org/1998/Math/MathML">
                         <mstyle displaystyle="true">
                           <msub>
                             <mi>t</mi>
                             <mi>A</mi>
                           </msub>
                         </mstyle>
                       </math>
                       <asciimath>t_A</asciimath>
                     </stem>
                   </formula>
                 </verbal-definition>
               </definition>
             </term>
           </terms>
         </sections>
       </ietf-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "keeps any initial boilerplate from terms and definitions" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      == Terms and Definitions

      I am boilerplate

      * So am I

      === Time

      This paragraph is extraneous
    INPUT
    output = <<~OUTPUT
             #{BLANK_HDR}
                    <sections>
               <terms id="_" obligation="normative"><title>Terms and definitions</title>
      <p id='_'>I am boilerplate</p>
      <ul id='_'>
        <li>
          <p id='_'>So am I</p>
        </li>
      </ul>
             <term id="term-Time">
             <preferred><expression><name>Time</name></expression></preferred>
               <definition><verbal-definition><p id="_">This paragraph is extraneous</p></verbal-definition></definition>
             </term></terms>
             </sections>
             </ietf-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "converts xrefs to references into erefs" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      <<iso216#123,of,text>>
      <<biblio,format=counter:text1>>

      [[biblio]]
      [bibliography]
      == Normative References
      * [[[iso216,ISO 216:2001]]], _Reference_
    INPUT
    output = <<~OUTPUT
            #{BLANK_HDR}
              <preface><foreword id="_" obligation="informative">
              <title>Foreword</title>
              <p id="_">
              <eref type='inline' displayFormat='of' relative='123' bibitemid='iso216' citeas='ISO&#xa0;216:2001'>text</eref>
      <xref target='biblio' format='counter'>text1</xref>
            </p>
            </foreword></preface><sections>
            </sections><bibliography><references id="biblio" obligation="informative" normative="true">
              <title>Normative References</title>
              <bibitem id="iso216" type="standard">
               <title format="text/plain">Reference</title>
               <docidentifier>ISO 216:2001</docidentifier>
               <docnumber>216</docnumber>
               <date type="published">
                 <on>2001</on>
               </date>
               <contributor>
                 <role type="publisher"/>
                 <organization>
                   <name>ISO</name>
                 </organization>
               </contributor>
             </bibitem>
            </references>
            </bibliography>
            </ietf-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "extracts localities from erefs" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      <<iso216,whole,clause=3,example=9-11,locality:prelude=33,locality:entirety:the reference>>

      [bibliography]
      == Normative References
      * [[[iso216,ISO 216]]], _Reference_
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
      <preface><foreword id="_" obligation="informative">
        <title>Foreword</title>
        <p id="_">
        <eref type="inline" bibitemid="iso216" citeas="ISO&#xa0;216">
        <localityStack>
        <locality type="whole"/><locality type="clause"><referenceFrom>3</referenceFrom></locality><locality type="example"><referenceFrom>9</referenceFrom><referenceTo>11</referenceTo></locality><locality type="locality:prelude"><referenceFrom>33</referenceFrom></locality><locality type="locality:entirety"/>
        </localityStack>the reference</eref>
        </p>
      </foreword></preface><sections>
      </sections><bibliography><references id="_" obligation="informative" normative="true">
        <title>Normative References</title>
        <bibitem id="iso216" type="standard">
         <title format="text/plain">Reference</title>
         <docidentifier>ISO 216</docidentifier>
         <docnumber>216</docnumber>
         <contributor>
           <role type="publisher"/>
           <organization>
             <name>ISO</name>
           </organization>
         </contributor>
       </bibitem>
      </references>
      </bibliography>
      </ietf-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "strips type from xrefs" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      <<iso216>>

      [bibliography]
      == Clause
      * [[[iso216,ISO 216]]], _Reference_
    INPUT
    output = <<~OUTPUT
             #{BLANK_HDR}
             <preface>
             <foreword id="_" obligation="informative">
               <title>Foreword</title>
               <p id="_">
               <eref type="inline" bibitemid="iso216" citeas="ISO&#xa0;216"/>
             </p>
             </foreword></preface><sections>
             </sections><bibliography><references id="_" obligation="informative" normative="false">
        <title>Clause</title>
        <bibitem id="iso216" type="standard">
        <title format="text/plain">Reference</title>
        <docidentifier>ISO 216</docidentifier>
               <docnumber>216</docnumber>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>ISO</name>
          </organization>
        </contributor>
      </bibitem>
      </references></bibliography>
             </ietf-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes localities in term sources" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      == Terms and Definitions

      === Term1

      Definition

      [.source]
      <<ISO2191,section=1>>
    INPUT
    output = <<~OUTPUT
             #{BLANK_HDR}
      <sections>
        <terms id="_" obligation="normative">
        <title>Terms and definitions</title>
        <term id="term-Term1">
        <preferred><expression><name>Term1</name></expression></preferred>
                <definition>
          <verbal-definition>
            <p id='_'>Definition</p>
          </verbal-definition>
        </definition>
        <termsource status='identical' type='authoritative'>
        <origin bibitemid="ISO2191" type="inline" citeas="">
        <localityStack>
       <locality type="section"><referenceFrom>1</referenceFrom></locality>
        </localityStack>
       </origin>
      </termsource>
      </term>
      </terms>
      </sections>
      </ietf-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "removes extraneous material from Normative References" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      [bibliography]
      == Normative References

      This is extraneous information

      * [[[iso216,ISO 216]]], _Reference_
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
      <sections></sections>
      <bibliography><references id="_" obligation="informative" normative="true"><title>Normative References</title>
             <bibitem id="iso216" type="standard">
         <title format="text/plain">Reference</title>
         <docidentifier>ISO 216</docidentifier>
         <docnumber>216</docnumber>
         <contributor>
           <role type="publisher"/>
           <organization>
             <name>ISO</name>
           </organization>
         </contributor>
       </bibitem>
      </references>
      </bibliography>
      </ietf-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "renumbers numeric references in Bibliography sequentially" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}

      == Clause
      <<iso123>>
      <<iso124>>

      [bibliography]
      == Bibliography

      * [[[iso124,ISO 124]]] _Standard 124_
      * [[[iso123,1]]] _Standard 123_
    INPUT
    output = <<~OUTPUT
          #{BLANK_HDR}
      <sections><clause id="_" inline-header="false" obligation="normative">
        <title>Clause</title>
        <p id="_"><eref type="inline" bibitemid="iso123" citeas="[2]"/>
      <eref type="inline" bibitemid="iso124" citeas="ISO&#xa0;124"/></p>
      </clause>
      </sections><bibliography><references id="_" obligation="informative" normative="false">
        <title>Bibliography</title>
        <bibitem id="iso124" type="standard">
        <title format="text/plain">Standard 124</title>
        <docidentifier>ISO 124</docidentifier>
        <docnumber>124</docnumber>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>ISO</name>
          </organization>
        </contributor>
      </bibitem>
        <bibitem id="iso123">
        <formattedref format="application/x-isodoc+xml">
          <em>Standard 123</em>
        </formattedref>
        <docidentifier type="metanorma">[2]</docidentifier>
      </bibitem>
      </references></bibliography>
             </ietf-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "renumbers numeric references in Bibliography subclauses sequentially" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}

      == Clause
      <<iso123>>
      <<iso124>>
      <<iso125>>
      <<iso126>>

      [bibliography]
      == Bibliography

      [bibliography]
      === Clause 1
      * [[[iso124,ISO 124]]] _Standard 124_
      * [[[iso123,1]]] _Standard 123_

      [bibliography]
      === {blank}
      * [[[iso125,ISO 125]]] _Standard 124_
      * [[[iso126,1]]] _Standard 123_

    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
      <sections><clause id="_" inline-header="false" obligation="normative">
           <title>Clause</title>
           <p id="_"><eref type="inline" bibitemid="iso123" citeas="[2]"/>
         <eref type="inline" bibitemid="iso124" citeas="ISO&#xa0;124"/>
         <eref type="inline" bibitemid="iso125" citeas="ISO&#xa0;125"/>
         <eref type="inline" bibitemid="iso126" citeas="[4]"/></p>
         </clause>
         </sections><bibliography><clause id="_" obligation="informative"><title>Bibliography</title><references id="_" obligation="informative" normative="false">
           <title>Clause 1</title>
           <bibitem id="iso124" type="standard">
           <title format="text/plain">Standard 124</title>
           <docidentifier>ISO 124</docidentifier>
           <docnumber>124</docnumber>
           <contributor>
             <role type="publisher"/>
             <organization>
               <name>ISO</name>
             </organization>
           </contributor>
         </bibitem>
           <bibitem id="iso123">
           <formattedref format="application/x-isodoc+xml">
             <em>Standard 123</em>
           </formattedref>
           <docidentifier type="metanorma">[2]</docidentifier>
         </bibitem>
         </references>
         <references id="_" obligation="informative" normative="false">
           <bibitem id="iso125" type="standard">
           <title format="text/plain">Standard 124</title>
           <docidentifier>ISO 125</docidentifier>
           <docnumber>125</docnumber>
           <contributor>
             <role type="publisher"/>
             <organization>
               <name>ISO</name>
             </organization>
           </contributor>
         </bibitem>
           <bibitem id="iso126">
           <formattedref format="application/x-isodoc+xml">
             <em>Standard 123</em>
           </formattedref>
           <docidentifier type="metanorma">[4]</docidentifier>
         </bibitem>
         </references></clause></bibliography>
         </ietf-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "converts boldface BCP to bcp markup if not no-rfc-bold-bcp14" do
    input = <<~INPUT
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib:

      I *MUST NOT* do this.
    INPUT
    output = <<~OUTPUT
              #{BLANK_HDR}
            <sections>
          <p id='_'>
            I
            <bcp14>MUST NOT</bcp14>
             do this.
          </p>
        </sections>
      </ietf-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "does not convert boldface BCP to bcp markup if no-rfc-bold-bcp14" do
    input = <<~INPUT
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib:
      :no-rfc-bold-bcp14:

      I *MUST NOT* do this.
    INPUT
    output = <<~OUTPUT
          #{BLANK_HDR}
            <sections>
          <p id='_'>
            I
            <strong>MUST NOT</strong>
             do this.
          </p>
        </sections>
      </ietf-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes inline cref macro" do
    input = <<~INPUT
      = Document title
      Author
      :docfile: test.adoc
      :draft:

      ABC cref:[def] DEF

      [[def]]
      ****
      What?
      ****

    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR.sub('<language>', '<version> </version><language>')}
      <sections>
      <p id='_'>
        ABC
        <review id='def' reviewer='(Unknown)' date='2000-01-01T00:00:00Z'>
          <p id='_'>What?</p>
        </review>
         DEF
      </p>
      </sections>
      </ietf-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "does not fold notes into preceding blocks" do
    input = <<~INPUT
      = Document title
      Author
      :docfile: test.adoc
      :draft:

      |===
      |A |B

      |C |D
      |===

      [NOTE]
      ====
      That formula does not do much
      ====

    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR.sub('<language>', '<version> </version><language>')}
               <sections>
           <table id="_">
             <thead>
               <tr>
                 <th valign="top" align="left">A</th>
                 <th valign="top" align="left">B</th>
               </tr>
             </thead>
             <tbody>
               <tr>
                 <td valign="top" align="left">C</td>
                 <td valign="top" align="left">D</td>
               </tr>
             </tbody>
             <note id="_">
               <p id="_">That formula does not do much</p>
             </note>
           </table>
         </sections>
       </ietf-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end
end
