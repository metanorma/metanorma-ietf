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
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
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
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
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
        <title id="_">Terms and definitions</title>
        <term id="_" anchor="term-_relativity_-Tempus">
        <preferred><expression><name>Tempus</name></expression></preferred>
        <domain>relativity</domain>
        <definition id="_"><verbal-definition id="_"><p id="_"> Time</p></verbal-definition></definition>
      </term>
      </terms>
      </sections>
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
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
             <title id="_">Terms and definitions</title>
             <term id="_" anchor="term-t_90">
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
               <definition id="_">
                 <verbal-definition id="_">
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
       </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
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
               <terms id="_" obligation="normative"><title id="_">Terms and definitions</title>
      <p id='_'>I am boilerplate</p>
      <ul id='_'>
        <li>
          <p id='_'>So am I</p>
        </li>
      </ul>
             <term id="_" anchor="term-Time">
             <preferred><expression><name>Time</name></expression></preferred>
               <definition id="_"><verbal-definition id="_"><p id="_">This paragraph is extraneous</p></verbal-definition></definition>
             </term></terms>
             </sections>
             </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
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
        <title id="_">Foreword</title>
        <p id="_">
        <eref type='inline' displayFormat='of' relative='123' bibitemid='iso216' citeas='ISO&#xa0;216:2001'><display-text>text</display-text></eref>
      <xref target='biblio' format='counter'><display-text>text1</display-text></xref>
      </p>
      </foreword></preface><sections>
      </sections><bibliography><references id="_" anchor="biblio" obligation="informative" normative="true">
        <title id="_">Normative References</title>
        <bibitem id="_" anchor="iso216" type="standard">
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
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
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
        <title id="_">Foreword</title>
        <p id="_">
        <eref type="inline" bibitemid="iso216" citeas="ISO&#xa0;216">
        <localityStack>
        <locality type="whole"/><locality type="clause"><referenceFrom>3</referenceFrom></locality><locality type="example"><referenceFrom>9</referenceFrom><referenceTo>11</referenceTo></locality><locality type="locality:prelude"><referenceFrom>33</referenceFrom></locality><locality type="locality:entirety"/>
        </localityStack><display-text>the reference</display-text></eref>
        </p>
      </foreword></preface><sections>
      </sections>
      <bibliography><references id="_" obligation="informative" normative="true">
        <title id="_">Normative References</title>
        <bibitem id="_" anchor="iso216" type="standard">
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
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
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
               <title id="_">Foreword</title>
               <p id="_">
               <eref type="inline" bibitemid="iso216" citeas="ISO&#xa0;216"/>
             </p>
             </foreword></preface><sections>
             </sections>
             <bibliography><references id="_" obligation="informative" normative="false">
        <title id="_">Clause</title>
        <bibitem id="_" anchor="iso216" type="standard">
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
             </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
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
        <title id="_">Terms and definitions</title>
        <term id="_" anchor="term-Term1">
        <preferred><expression><name>Term1</name></expression></preferred>
                <definition id="_">
          <verbal-definition id="_">
            <p id='_'>Definition</p>
          </verbal-definition>
        </definition>
        <source status='identical' type='authoritative'>
        <origin bibitemid="ISO2191" type="inline" citeas="">
        <localityStack>
       <locality type="section"><referenceFrom>1</referenceFrom></locality>
        </localityStack>
       </origin>
      </source>
      </term>
      </terms>
      </sections>
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
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
      <bibliography><references id="_" obligation="informative" normative="true">
      <title id="_">Normative References</title>
             <bibitem id="_" anchor="iso216" type="standard">
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
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
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
        <title id="_">Clause</title>
        <p id="_"><eref type="inline" bibitemid="iso123" citeas="[2]"/>
      <eref type="inline" bibitemid="iso124" citeas="ISO&#xa0;124"/></p>
      </clause>
      </sections>
      <bibliography><references id="_" obligation="informative" normative="false">
        <title id="_">Bibliography</title>
        <bibitem id="_" anchor="iso124" type="standard">
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
        <bibitem id="_" anchor="iso123">
        <formattedref format="application/x-isodoc+xml">
          <em>Standard 123</em>
        </formattedref>
        <docidentifier type="metanorma">[2]</docidentifier>
      </bibitem>
      </references></bibliography>
             </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
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
           <title id="_">Clause</title>
           <p id="_"><eref type="inline" bibitemid="iso123" citeas="[2]"/>
         <eref type="inline" bibitemid="iso124" citeas="ISO&#xa0;124"/>
         <eref type="inline" bibitemid="iso125" citeas="ISO&#xa0;125"/>
         <eref type="inline" bibitemid="iso126" citeas="[4]"/></p>
         </clause>
         </sections><bibliography><clause id="_" obligation="informative">
         <title id="_">Bibliography</title>
         <references id="_" obligation="informative" normative="false">
           <title id="_">Clause 1</title>
           <bibitem id="_" anchor="iso124" type="standard">
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
           <bibitem id="_" anchor="iso123">
           <formattedref format="application/x-isodoc+xml">
             <em>Standard 123</em>
           </formattedref>
           <docidentifier type="metanorma">[2]</docidentifier>
         </bibitem>
         </references>
         <references id="_" obligation="informative" normative="false">
           <bibitem id="_" anchor="iso125" type="standard">
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
           <bibitem id="_" anchor="iso126">
           <formattedref format="application/x-isodoc+xml">
             <em>Standard 123</em>
           </formattedref>
           <docidentifier type="metanorma">[4]</docidentifier>
         </bibitem>
         </references></clause></bibliography>
         </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
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
            <span class="bcp14">MUST NOT</span>
             do this.
          </p>
        </sections>
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
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
      </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
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
      #{BLANK_HDR}
          <sections>
             <p id="_">
                <bookmark id="_" anchor="_"/>
                ABC
                <bookmark id="_"/>
                DEF
             </p>
          </sections>
          <annotation-container>
             <annotation id="_" anchor="def" reviewer="(Unknown)" date="2000-01-01T00:00:00Z" type="review" from="_" to="_">
                <p id="_">What?</p>
             </annotation>
          </annotation-container>
       </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
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
      #{BLANK_HDR}
               <sections>
           <table id="_">
             <thead>
               <tr id="_">
                 <th id="_" valign="top" align="left">A</th>
                 <th id="_" valign="top" align="left">B</th>
               </tr>
             </thead>
             <tbody>
               <tr id="_">
                 <td id="_" valign="top" align="left">C</td>
                 <td id="_" valign="top" align="left">D</td>
               </tr>
             </tbody>
             <note id="_">
               <p id="_">That formula does not do much</p>
             </note>
           </table>
         </sections>
       </metanorma>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "moves title footnotes to bibdata" do
    input = <<~INPUT
      = Document title footnote:[ABC] footnote:[DEF]
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib:

    INPUT
    output = <<~OUTPUT
      <metanorma xmlns='https://www.metanorma.org/ns/standoc'  type="semantic" version="#{Metanorma::Ietf::VERSION}" flavor='ietf'>
               <bibdata type="standard">
             <title language="en" format="text/plain" type="main">Document title</title>
             <contributor>
                <role type="publisher"/>
                <organization>
                   <name>Internet Engineering Task Force</name>
                   <abbreviation>IETF</abbreviation>
                </organization>
             </contributor>
             <note type="title-footnote">
                <p>ABC</p>
             </note>
             <note type="title-footnote">
                <p>DEF</p>
             </note>
             <language>en</language>
             <script>Latn</script>
             <status>
                <stage>published</stage>
             </status>
             <copyright>
                <from>2000</from>
                <owner>
                   <organization>
                      <name>Internet Engineering Task Force</name>
                      <abbreviation>IETF</abbreviation>
                   </organization>
                </owner>
             </copyright>
             <series type="stream">
                <title>IETF</title>
             </series>
             <ext>
                <doctype>internet-draft</doctype>
                <flavor>ietf</flavor>
                <ipr>trust200902</ipr>
                <pi>
                   <tocinclude>yes</tocinclude>
                </pi>
             </ext>
          </bibdata>
          <sections> </sections>
       </metanorma>
    OUTPUT
    xml = Nokogiri::XML(Asciidoctor.convert(input, *OPTIONS))
    xml.at("//xmlns:metanorma-extension")&.remove
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)

    input = <<~INPUT
      = XXXX
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib:
      :title-en: Document title footnote:[ABC] footnote:[DEF]

    INPUT
    xml = Nokogiri::XML(Asciidoctor.convert(input, *OPTIONS))
    xml.at("//xmlns:metanorma-extension")&.remove
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(output)
  end
end
