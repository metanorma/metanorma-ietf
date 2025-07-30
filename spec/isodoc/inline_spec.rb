require "spec_helper"

RSpec.describe IsoDoc::Ietf::RfcConvert do
  it "respect &lt; &gt;" do
    FileUtils.rm_f "test.rfc.xml"
    input = <<~INPUT
      #{BLANK_HDR}
      <preface><foreword>
      <p>&lt;pizza&gt;</p>
      </foreword></preface>
      <sections>
      </iso-standard>
    INPUT
    IsoDoc::Ietf::RfcConvert.new({})
      .convert("test", input, false)
    expect(Canon.format_xml(strip_guid(File.read("test.rfc.xml"))))
      .to be_equivalent_to Canon.format_xml(<<~OUTPUT)
        <rfc xmlns:xi="http://www.w3.org/2001/XInclude" category="std" ipr="trust200902" submissionType="IETF" xml:lang="en" version="3">
           <front>
              <title>Document title</title>
              <seriesInfo value="" status="Published" stream="IETF" name="Internet-Draft" asciiName="Internet-Draft"/>
              <abstract>
                 <t>&lt;pizza&gt;</t>
              </abstract>
              <date day="1" year="2000" month="January"/>
           </front>
           <middle/>
           <back/>
        </rfc>
      OUTPUT
  end

  it "processes inline formatting" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface><foreword>
      <p>
      <em>A</em> <strong>B</strong> <sup>C</sup> <sub>D</sub> <tt>E</tt>
      <strike>F</strike> <smallcap>G</smallcap> <keyword>I</keyword>
      <span class="bcp14">must</span> <span class="random">would</span> <br/> <hr/>
      <bookmark id="H"/> <pagebreak/>
      </p>
      </foreword></preface>
      <sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
          #{XML_HDR}
          <t>
        <em>A</em>
        <strong>B</strong>
        <sup>C</sup>
        <sub>D</sub>
        <tt>E</tt>
         F G I
        <bcp14>must</bcp14>
        would
        <br/>
        <bookmark anchor='H'/>
      </t>
      </abstract>
      <date day="1" year="2000" month="January"/>
      </front><middle/><back/></rfc>
    OUTPUT
    expect(Canon.format_xml(strip_guid(IsoDoc::Ietf::RfcConvert.new({})
      .convert("test", input, true))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes embedded inline formatting" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface><foreword>
      <p>
      <em><strong>&lt;</strong></em> <tt><link target="B"/></tt> <xref target="http_1_1" format="title" relative="#abc"><display-text>Requirement <tt>/req/core/http</tt></display-text></xref> <eref type="inline" bibitemid="ISO712" citeas="ISO 712"><display-text>Requirement <tt>/req/core/http</tt></display-text></eref> <eref type="inline" bibitemid="ISO712" displayFormat="of" citeas="ISO 712" relative="xyz"><locality type="section"><referenceFrom>3.1</referenceFrom></locality></eref>
      </p>
      </foreword></preface>
      <sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
          #{XML_HDR}
          <t>
                     <em>
                       <strong>&lt;</strong>
                     </em>
                     <tt>
                       <eref target='B'/>
                     </tt>
                     <xref target='http_1_1' format='title' relative='#abc'>
                       Requirement
                       <tt>/req/core/http</tt>
                     </xref>
                     <xref target='ISO712' section='' relative=''>
                       Requirement
                       <tt>/req/core/http</tt>
                     </xref>
                     <xref target='ISO712' section='3.1' sectionFormat="of" relative="xyz"/>
                   </t>
      </abstract>
      <date day="1" year="2000" month="January"/>
      </front><middle/><back/></rfc>
    OUTPUT
    expect(Canon.format_xml(strip_guid(IsoDoc::Ietf::RfcConvert.new({})
      .convert("test", input, true))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes index terms" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
       <preface><foreword>
       <p>D<index>
       <primary>A<sub>B</sub></primary>
       <secondary>A<sub>B</sub></secondary>
       <tertiary>A<sub>B</sub></tertiary>
       </index>.<index primary="true">
       <primary>D</primary></index></p>
       </foreword></preface>
       <sections>
       </iso-standard>
    INPUT
    output = <<~OUTPUT
      #{XML_HDR}
      <t>D
                  <iref item='AB' subitem='AB'/>
                  .
                  <iref item='D' primary="true"/></t>
      </abstract>
      <date day="1" year="2000" month="January"/>
      </front><middle/><back/></rfc>
    OUTPUT
    expect(Canon.format_xml(strip_guid(IsoDoc::Ietf::RfcConvert.new({})
      .convert("test", input, true))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes inline images" do
    input = <<~INPUT
        <iso-standard xmlns="http://riboseinc.com/isoxml">
        <preface><foreword>
        <p>
      <image src="rice_images/rice_image1.png" height="20" width="30" id="A" mimetype="image/png" alt="alttext" title="titletxt"/>
      </p>
      </foreword></preface>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
          #{XML_HDR}
          <t>
                     <artwork src='rice_images/rice_image1.png' title='titletxt' anchor='A' type='svg' alt='alttext'/>
                   </t>
      </abstract>
      <date day="1" year="2000" month="January"/>
      </front><middle/><back/></rfc>
    OUTPUT
    expect(Canon.format_xml(strip_guid(IsoDoc::Ietf::RfcConvert.new({})
      .convert("test", input, true))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes links" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface><foreword>
      <p>
      <link target="http://example.com"/>
      <link target="http://example.com">example</link>
      <link target="http://example.com" alt="tip">example</link>
      <link target="mailto:fred@example.com"/>
      <link target="mailto:fred@example.com">mailto:fred@example.com</link>
      <link target="http://example.com" style="angle">example</link>
      </p>
      </foreword></preface>
      <sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
          #{XML_HDR}
          <t>
                     <eref target='http://example.com'/>
                     <eref target='http://example.com'>example</eref>
                     <eref target='http://example.com'>example</eref>
                     <eref target='mailto:fred@example.com'/>
                     <eref target='mailto:fred@example.com'>mailto:fred@example.com</eref>
                     <eref target="http://example.com" brackets="angle">example</eref>
                   </t>
      </abstract>
      <date day="1" year="2000" month="January"/>
      </front><middle/><back/></rfc>
    OUTPUT
    expect(Canon.format_xml(strip_guid(IsoDoc::Ietf::RfcConvert.new({})
      .convert("test", input, true))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes unrecognised markup" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface><foreword>
      <p>
      <barry fred="http://example.com">example</barry>
      </p>
      </foreword></preface>
      <sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
          #{XML_HDR}
      <t>
        <t>&lt;barry fred="http://example.com"&gt;example&lt;/barry&gt;</t>
      </t>
      </abstract>
      <date day="1" year="2000" month="January"/>
      </front><middle/><back/></rfc>
    OUTPUT
    expect(Canon.format_xml(strip_guid(IsoDoc::Ietf::RfcConvert.new({})
      .convert("test", input, true))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes AsciiMath and MathML" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface><foreword>
      <p>
      <stem type="AsciiMath">&lt;A&gt;</stem>
      <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mstyle displaystyle="true"><mi>X</mi></mstyle></math></stem>
      <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mstyle displaystyle="true"><mi>X</mi></mstyle></math><asciimath>XYZ</asciimath></stem>
      <stem type="None">Latex?</stem>
      </p>
      </foreword></preface>
      <sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
          #{XML_HDR}
          <t>
      $$ &lt;A&gt; $$
      $$ X $$
      $$ XYZ $$
      $$ Latex? $$
      </t>
      </abstract>
      <date day="1" year="2000" month="January"/>
      </front><middle/><back/></rfc>
    OUTPUT
    expect(Canon.format_xml(strip_guid(IsoDoc::Ietf::RfcConvert.new({})
      .convert("test", input, true))
      .sub(/<html/, "<html xmlns:m='m'")))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "overrides AsciiMath delimiters" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface><foreword>
      <p>
      <stem type="AsciiMath">A</stem>
      $$Hello$$$
      </p>
      </foreword></preface>
      <sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
          #{XML_HDR}
          <t> $$$$ A $$$$ $$Hello$$$ </t>
      </abstract>
      <date day="1" year="2000" month="January"/>
      </front><middle/><back/></rfc>
    OUTPUT
    expect(Canon.format_xml(strip_guid(IsoDoc::Ietf::RfcConvert.new({})
      .convert("test", input, true))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "cross-references notes" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface>
          <foreword>
          <p>
          <xref target="N1">note</xref>
          <xref target="N2"/>
          <xref target="N"/>
          <xref target="note1"/>
          <xref target="note2">note</xref>
          <xref target="AN"/>
          <xref target="Anote1">note</xref>
          <xref target="Anote2"/>
          </p>
          </foreword>
          <introduction id="intro">
          <note id="N1">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83e">These results are based on a study carried out on three different types of kernel.</p>
      </note>
      <clause id="xyz"><title>Preparatory</title>
          <note id="N2">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83d">These results are based on a study carried out on three different types of kernel.</p>
      </note>
      </clause>
          </introduction>
          </preface>
          <sections>
          <clause id="scope"><title>Scope</title>
          <note id="N">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
      </note>
      <p><xref target="N"/></p>
          </clause>
          <terms id="terms"/>
          <clause id="widgets"><title>Widgets</title>
          <clause id="widgets1">
          <note id="note1">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
      </note>
          <note id="note2">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a">These results are based on a study carried out on three different types of kernel.</p>
      </note>
      <p>    <xref target="note1"/> <xref target="note2"/> </p>
          </clause>
          </clause>
          </sections>
          <annex id="annex1">
          <clause id="annex1a">
          <note id="AN">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
      </note>
          </clause>
          <clause id="annex1b">
          <note id="Anote1">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
      </note>
          <note id="Anote2">
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a">These results are based on a study carried out on three different types of kernel.</p>
      </note>
          </clause>
          </annex>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
      #{XML_HDR}
               <t>
                 <xref target='N1'>note</xref>
                 <xref target='N2'/>
                 <xref target='N'/>
                 <xref target='note1'/>
                 <xref target='note2'>note</xref>
                 <xref target='AN'/>
                 <xref target='Anote1'>note</xref>
                 <xref target='Anote2'/>
               </t>
             </abstract>
             <date day="1" year="2000" month="January"/>
           </front>
           <middle>
             <section anchor='intro'>
               <aside anchor='N1'>
                 <t>
                   NOTE: These results are based on a study carried out on three
                   different types of kernel.
                 </t>
               </aside>
               <section anchor='xyz'>
                 <name>Preparatory</name>
                 <aside anchor='N2'>
                   <t>
                     NOTE: These results are based on a study carried out on three
                     different types of kernel.
                   </t>
                 </aside>
               </section>
             </section>
             <section anchor='scope'>
               <name>Scope</name>
               <aside anchor='N'>
                 <t>
                   NOTE: These results are based on a study carried out on three
                   different types of kernel.
                 </t>
               </aside>
               <t>
                 <xref target='N'/>
               </t>
             </section>
             <section anchor='terms'/>
             <section anchor='widgets'>
               <name>Widgets</name>
               <section anchor='widgets1'>
                 <aside anchor='note1'>
                   <t>
                     NOTE 1: These results are based on a study carried out on three
                     different types of kernel.
                   </t>
                 </aside>
                 <aside anchor='note2'>
                   <t>
                     NOTE 2: These results are based on a study carried out on three
                     different types of kernel.
                   </t>
                 </aside>
                 <t>
                   <xref target='note1'/>
                   <xref target='note2'/>
                 </t>
               </section>
             </section>
           </middle>
           <back>
             <section anchor='annex1'>
               <section anchor='annex1a'>
                 <aside anchor='AN'>
                   <t>
                     NOTE: These results are based on a study carried out on three
                     different types of kernel.
                   </t>
                 </aside>
               </section>
               <section anchor='annex1b'>
                 <aside anchor='Anote1'>
                   <t>
                     NOTE 1: These results are based on a study carried out on three
                     different types of kernel.
                   </t>
                 </aside>
                 <aside anchor='Anote2'>
                   <t>
                     NOTE 2: These results are based on a study carried out on three
                     different types of kernel.
                   </t>
                 </aside>
               </section>
             </section>
           </back>
         </rfc>
    OUTPUT
    expect(Canon.format_xml(strip_guid(IsoDoc::Ietf::RfcConvert.new({})
      .convert("test", input, true))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes eref attributes" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <p>
          <eref type="inline" bibitemid="ISO712" citeas="ISO 712" relative="#abc" displayFormat="of">A</stem>
          </p>
          </foreword></preface>
          <bibliography><references id="_normative_references" obligation="informative" normative="true"><title>Normative References</title>
      <bibitem id="ISO712" type="standard">
        <title format="text/plain">Cereals and cereal products</title>
        <docidentifier>ISO 712</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>International Organization for Standardization</name>
            <abbreviation>ISO</abbreviation>
          </organization>
        </contributor>
      </bibitem>
          </references>
          </bibliography>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
          #{XML_HDR}
          <t>
        <xref target='ISO712' section='' sectionFormat='of' relative="#abc">A</xref>
      </t>
      </abstract>
      <date day="1" year="2000" month="January"/>
        </front><middle/>
      <back>
        <references anchor="_normative_references">
          <name>Normative References</name>
          <reference anchor='ISO712'>
            <front>
        <title>Cereals and cereal products</title>
        <author>
          <organization ascii="International Organization for Standardization" abbrev="ISO">International Organization for Standardization</organization>
        </author>
      </front>
      <refcontent>ISO&#xa0;712</refcontent>
          </reference>
        </references>
      </back>
      </rfc>
    OUTPUT
    expect(Canon.format_xml(strip_guid(IsoDoc::Ietf::RfcConvert.new({})
      .convert("test", input, true))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes eref content" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <p>
          <eref type="inline" bibitemid="ISO712" citeas="ISO 712"/>
          <eref type="inline" bibitemid="ISO712"/>
          <eref type="inline" bibitemid="ISO712"><locality type="table"><referenceFrom>1</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO712"><locality type="table"><referenceFrom>1</referenceFrom><referenceTo>1</referenceTo></locality></eref>
          <eref type="inline" bibitemid="ISO712"><locality type="clause"><referenceFrom>1</referenceFrom></locality><locality type="table"><referenceFrom>1</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO712"><locality type="clause"><referenceFrom>1</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO712"><locality type="clause"><referenceFrom>1.5</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO712"><locality type="table"><referenceFrom>1</referenceFrom></locality>A</eref>
          <eref type="inline" bibitemid="ISO712"><locality type="whole"></locality></eref>
          <eref type="inline" bibitemid="ISO712"><locality type="locality:prelude"><referenceFrom>7</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO712" citeas="ISO 712">A</eref>
          <eref type="inline" bibitemid="ISO712"><localityStack connective="and"><locality type="clause"><referenceFrom>1</referenceFrom></locality></localityStack><localityStack connective="and"><locality type="clause"><referenceFrom>3</referenceFrom></locality></localityStack></eref>
          <eref type="inline" bibitemid="ISO712"><localityStack connective="and"><locality type="clause"><referenceFrom>1</referenceFrom></locality></localityStack><localityStack connective="and"><locality type="table"><referenceFrom>3</referenceFrom></locality></localityStack></eref>
          <eref type="inline" bibitemid="ISO712" citeas="ISO 712"><localityStack connective="and"><locality type="anchor"><referenceFrom>1</referenceFrom></locality></localityStack>A</eref>
          <eref type="inline" bibitemid="ISO712"><localityStack connective="and"><locality type="clause"><referenceFrom>1</referenceFrom></locality><locality type="anchor"><referenceFrom>xyz</referenceFrom></locality></localityStack><localityStack connective="and"><locality type="clause"><referenceFrom>9</referenceFrom></locality></localityStack></eref>
          <eref type="inline" bibitemid="ISO712"><locality type="clause"><referenceFrom>1</referenceFrom></locality><locality type="anchor"><referenceFrom>1</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO712"><locality type="clause"><referenceFrom>1.5</referenceFrom></locality><locality type="anchor"><referenceFrom>1</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO712"><locality type="table"><referenceFrom>1</referenceFrom></locality><locality type="anchor"><referenceFrom>1</referenceFrom></locality>A</eref>
          <eref type="inline" bibitemid="ISO712"><locality type="whole"></locality><locality type="anchor"><referenceFrom>1</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO712"><locality type="locality:prelude"><referenceFrom>7</referenceFrom></locality><locality type="anchor"><referenceFrom>1</referenceFrom></locality></eref>
          </p>
          </foreword></preface>
          <bibliography><references id="_normative_references" obligation="informative" normative="true"><title>Normative References</title>
      <bibitem id="ISO712" type="standard">
        <title format="text/plain">Cereals and cereal products</title>
        <docidentifier>ISO 712</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>International Organization for Standardization</name>
            <abbreviation>ISO</abbreviation>
          </organization>
        </contributor>
      </bibitem>
          </references>
          </bibliography>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
          #{XML_HDR}
          <t>
                         <xref target='ISO712' section='' relative=''/>
               <xref target='ISO712' section='' relative=''/>
               <xref target='ISO712' section='Table 1' relative=''/>
               <xref target='ISO712' section='Table 1&#x2013;1' relative=''/>
               <xref target='ISO712' section='1, Table 1' relative=''/>
               <xref target='ISO712' section='1' relative=''/>
               <xref target='ISO712' section='1.5' relative=''/>
               <xref target='ISO712' section='Table 1' relative=''>A</xref>
               <xref target='ISO712' section='Whole of text' relative=''/>
               <xref target='ISO712' section='Prelude 7' relative=''/>
               <xref target='ISO712' section='' relative=''>A</xref>
               <xref target='ISO712' section='1 and 3' relative=''/>
               <xref target='ISO712' section='1 and Table 3' relative=''/>
               <xref target='ISO712' section='' relative='1'>A</xref>
               <xref target='ISO712' section='1 and Clause 9' relative='xyz'/>
               <xref target='ISO712' section='1' relative='1'/>
               <xref target='ISO712' section='1.5' relative='1'/>
               <xref target='ISO712' section='Table 1' relative='1'>A</xref>
               <xref target='ISO712' section='Whole of text' relative='1'/>
               <xref target='ISO712' section='Prelude 7' relative='1'/>
      </t>
      </abstract>
      <date day="1" year="2000" month="January"/>
      </front><middle/>
      <back>
        <references anchor="_normative_references">
          <name>Normative References</name>
          <reference anchor='ISO712'>
            <front>
        <title>Cereals and cereal products</title>
        <author>
          <organization ascii="International Organization for Standardization" abbrev="ISO">International Organization for Standardization</organization>
        </author>
      </front>
      <refcontent>ISO&#xa0;712</refcontent>
          </reference>
        </references>
      </back>
      </rfc>
    OUTPUT
    expect(Canon.format_xml(strip_guid(IsoDoc::Ietf::RfcConvert.new({})
      .convert("test", input, true))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes passthrough content" do
    FileUtils.rm_f "test.rfc.xml"
    IsoDoc::Ietf::RfcConvert.new({}).convert("test", <<~"INPUT", false)
      #{BLANK_HDR}
      <preface><foreword>
      <p>
      <passthrough>&lt;abc&gt;X &amp;gt; Y</passthrough>
      A
      <passthrough>&lt;/abc&gt;</passthrough>
      </p>
      </preface>
      </iso-standard>
    INPUT
    expect(Canon.format_xml(strip_guid(File.read("test.rfc.xml"))))
      .to be_equivalent_to Canon.format_xml(<<~OUTPUT)
           <?xml version="1.0"?>
        <?rfc strict="yes"?>
        <?rfc compact="yes"?>
        <?rfc subcompact="no"?>
        <?rfc tocdepth="4"?>
        <?rfc symrefs="yes"?>
        <?rfc sortrefs="yes"?>
        <rfc xmlns:xi="http://www.w3.org/2001/XInclude" category="std" ipr="trust200902" submissionType="IETF" xml:lang="en" version="3" >
          <front>
            <title>Document title</title>
            <seriesInfo value="" status="Published" stream="IETF" name="Internet-Draft" asciiName="Internet-Draft"></seriesInfo>
            <abstract>
        <t>
        <abc>X &#x3e; Y
        A
        </abc>
        </t>
        </abstract>
        <date day="1" year="2000" month="January"/>
          </front>
          <middle></middle>
          <back></back>
        </rfc>
      OUTPUT
  end

  it "processes concept markup" do
    input = <<~INPUT
             <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <p>
          <ul>
          <li><concept><refterm>term</refterm>
              <xref target='clause1'/>
            </concept></li>
            <li><concept><refterm>term</refterm>
              <renderterm>term</renderterm>
              <xref target='clause1'/>
            </concept></li>
          <li><concept><refterm>term</refterm>
              <renderterm>w[o]rd</renderterm>
              <xref target='clause1'>Clause #1</xref>
            </concept></li>
            <li><concept><refterm>term</refterm>
              <renderterm>term</renderterm>
              <eref bibitemid="ISO712" type="inline" citeas="ISO 712"/>
            </concept></li>
            <li><concept><refterm>term</refterm>
              <renderterm>word</renderterm>
              <eref bibitemid="ISO712" type="inline" citeas="ISO 712">The Aforementioned Citation</eref>
            </concept></li>
            <li><concept><refterm>term</refterm>
              <renderterm>word</renderterm>
              <eref bibitemid="ISO712" type="inline" citeas="ISO 712">
                <locality type='clause'>
                  <referenceFrom>3.1</referenceFrom>
                </locality>
                <locality type='figure'>
                  <referenceFrom>a</referenceFrom>
                </locality>
              </eref>
            </concept></li>
            <li><concept><refterm>term</refterm>
              <renderterm>word</renderterm>
              <eref bibitemid="ISO712" type="inline" citeas="ISO 712">
              <localityStack connective="and">
                <locality type='clause'>
                  <referenceFrom>3.1</referenceFrom>
                </locality>
              </localityStack>
              <localityStack connective="and">
                <locality type='figure'>
                  <referenceFrom>b</referenceFrom>
                </locality>
              </localityStack>
              </eref>
            </concept></li>
            <li><concept><refterm>term</refterm>
              <renderterm>word</renderterm>
              <eref bibitemid="ISO712" type="inline" citeas="ISO 712">
              <localityStack connective="and">
                <locality type='clause'>
                  <referenceFrom>3.1</referenceFrom>
                </locality>
              </localityStack>
              <localityStack connective="and">
                <locality type='figure'>
                  <referenceFrom>b</referenceFrom>
                </locality>
              </localityStack>
              The Aforementioned Citation
              </eref>
            </concept></li>
            <li><concept><refterm>term</refterm>
              <renderterm>word</renderterm>
              <termref base='IEV' target='135-13-13'/>
            </concept></li>
            <li><concept><refterm>term</refterm>
              <renderterm>word</renderterm>
              <termref base='IEV' target='135-13-13'>The IEV database</termref>
            </concept></li>
            <li><concept><strong>term <tt>participant's</tt> not resolved via ID <tt>participant__x2019_s</tt></strong></concept></li>
            </ul>
          </p>
          </foreword></preface>
          <sections>
          <clause id="clause1"><title>Clause 1</title></clause>
          </sections>
          <bibliography><references id="_normative_references" obligation="informative" normative="true"><title>Normative References</title>
          <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
      <bibitem id="ISO712" type="standard">
        <title format="text/plain">Cereals or cereal products</title>
        <title type="main" format="text/plain">Cereals and cereal products</title>
        <docidentifier type="ISO">ISO 712</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>International Organization for Standardization</name>
          </organization>
        </contributor>
      </bibitem>
      </references></bibliography>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
      <rfc xmlns:xi="http://www.w3.org/2001/XInclude" category="std" submissionType="IETF" version="3">
          <front>
             <seriesInfo value="" name="RFC" asciiName="RFC"/>
             <abstract>
                <t>
                   <ul>
                      <li>
                         [term defined in
                         <xref target="clause1"/>
                         ]
                      </li>
                      <li>
                         <em>term</em>
                         [term defined in
                         <xref target="clause1"/>
                         ]
                      </li>
                      <li>
                         <em>w[o]rd</em>
                         [term defined in
                         <xref target="clause1">Clause #1</xref>
                         ]
                      </li>
                      <li>
                         <em>term</em>
                         [term defined in
                         <xref target="ISO712" section="" relative=""/>
                         ]
                      </li>
                      <li>
                         <em>word</em>
                         [term defined in
                         <xref target="ISO712" section="" relative="">The Aforementioned Citation</xref>
                         ]
                      </li>
                      <li>
                         <em>word</em>
                         [term defined in
                         <xref target="ISO712" section="3.1, Figure a" relative="">


               </xref>
                         ]
                      </li>
                      <li>
                         <em>word</em>
                         [term defined in
                         <xref target="ISO712" section="3.1 and Figure b" relative="">


               </xref>
                         ]
                      </li>
                      <li>
                         <em>word</em>
                         [term defined in
                         <xref target="ISO712" section="3.1 and Figure b" relative="">


               The Aforementioned Citation
               </xref>
                         ]
                      </li>
                      <li>
                         <em>word</em>
                         [term defined in Termbase IEV, term ID 135-13-13]
                      </li>
                      <li>
                         <em>word</em>
                         [term defined in The IEV database]
                      </li>
                      <li>
                         <strong>
                            term
                            <tt>participant's</tt>
                            not resolved via ID
                            <tt>participant__x2019_s</tt>
                         </strong>
                      </li>
                   </ul>
                </t>
             </abstract>
             <date day="1" year="2000" month="January"/>
          </front>
          <middle>
             <section anchor="clause1">
                <name>Clause 1</name>
             </section>
          </middle>
          <back>
             <references anchor="_normative_references">
                <name>Normative References</name>
                <t>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</t>
                <reference anchor="ISO712">
                   <front>
                      <title>Cereals and cereal products</title>
                      <author>
                         <organization ascii="International Organization for Standardization">International Organization for Standardization</organization>
                      </author>
                   </front>
                   <refcontent>ISO 712</refcontent>
                </reference>
             </references>
          </back>
       </rfc>
    OUTPUT
    expect(Canon.format_xml(strip_guid(IsoDoc::Ietf::RfcConvert.new({})
      .convert("test", input, true))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes multiple-target xrefs" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata/>
        <sections>
       <clause id="A" inline-header="false" obligation="normative">
       <title>Section</title>
       <p id="A"><xref target="ref1"><location target="ref1" connective="from"/><location target="ref2" connective="to"/></xref>
       <xref target="ref1"><location target="ref1" connective="from"/><location target="ref2" connective="to"/>text</xref>
       <xref target="ref1"><location target="ref1" connective="and"/><location target="ref2" connective="and"/></xref>
       <xref target="ref1"><location target="ref1" connective="and"/><location target="ref2" connective="and"/><location target="ref3" connective="and"/></xref>
       <xref target="ref1"><location target="ref1" connective="and"/><location target="ref2" connective="and"/>text</xref>
       <xref target="ref1"><location target="ref1" connective="and"/><location target="ref2" connective="or"/></xref>
       <xref target="ref1"><location target="ref1" connective="and"/><location target="ref2" connective="or"/><location target="ref3" connective="or"/></xref>
       <xref target="ref1"><location target="ref1" connective="from"/><location target="ref2" connective="to"/><location target="ref3" connective="and"/><location target="ref4" connective="to"/></xref></p>
       </clause>
       <clause id="ref1"/>
       <clause id="ref2"/>
       <clause id="ref3"/>
       <clause id="ref4"/>
         </sections>
       </iso-standard>
    INPUT
    output = <<~OUTPUT
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
           <date day="1" year="2000" month="January"/>
         </front>
         <middle>
           <section anchor='A'>
             <name>Section</name>
             <t anchor='A'>
               <xref target='ref1'/>
               <xref target='ref1'>text</xref>
               <xref target='ref1'/>
               <xref target='ref1'/>
               <xref target='ref1'>text</xref>
               <xref target='ref1'/>
               <xref target='ref1'/>
               <xref target='ref1'/>
             </t>
           </section>
           <section anchor='ref1'/>
           <section anchor='ref2'/>
           <section anchor='ref3'/>
           <section anchor='ref4'/>
         </middle>
         <back/>
       </rfc>
    OUTPUT
    expect(Canon.format_xml(IsoDoc::Ietf::RfcConvert.new({})
      .convert("test", input, true)))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "combines locality stacks with connectives" do
    input = <<~INPUT
      <itu-standard xmlns="https://www.calconnect.org/standards/itu">
        <sections>
       <clause id="A" inline-header="false" obligation="normative">
       <title>Section</title>
                  <p id='_'>
              <eref type='inline' bibitemid='ref1' citeas='XYZ'>
                <localityStack connective='from'>
                  <locality type='clause'>
                    <referenceFrom>3</referenceFrom>
                  </locality>
                </localityStack>
                <localityStack connective='to'>
                  <locality type='clause'>
                    <referenceFrom>5</referenceFrom>
                  </locality>
                </localityStack>
              </eref>
              <eref type='inline' bibitemid='ref1' citeas='XYZ'>
                <localityStack connective='from'>
                  <locality type='clause'>
                    <referenceFrom>3</referenceFrom>
                  </locality>
                </localityStack>
                <localityStack connective='to'>
                  <locality type='clause'>
                    <referenceFrom>5</referenceFrom>
                  </locality>
                  <locality type="table">
                    <referenceFrom>2</referenceFrom>
                  </locality>
                  </locality>
                </localityStack>
                text
              </eref>
              <eref type='inline' bibitemid='ref1' citeas='XYZ'>
                <localityStack connective='and'>
                  <locality type='clause'>
                    <referenceFrom>3</referenceFrom>
                  </locality>
                </localityStack>
                <localityStack connective='and'>
                  <locality type='clause'>
                    <referenceFrom>5</referenceFrom>
                  </locality>
                </localityStack>
              </eref>
              <eref type='inline' bibitemid='ref1' citeas='XYZ'>
                <localityStack connective='and'>
                  <locality type='clause'>
                    <referenceFrom>3</referenceFrom>
                  </locality>
                </localityStack>
                <localityStack connective='and'>
                  <locality type='clause'>
                    <referenceFrom>5</referenceFrom>
                  </locality>
                </localityStack>
                <localityStack connective='and'>
                  <locality type='clause'>
                    <referenceFrom>7</referenceFrom>
                  </locality>
                </localityStack>
              </eref>
              <eref type='inline' bibitemid='ref1' citeas='XYZ'>
                <localityStack connective='and'>
                  <locality type='clause'>
                    <referenceFrom>3</referenceFrom>
                  </locality>
                </localityStack>
                <localityStack connective='and'>
                  <locality type='annex'>
                    <referenceFrom>5</referenceFrom>
                  </locality>
                </localityStack>
              </eref>
              <eref type='inline' bibitemid='ref1' citeas='XYZ'>
                <localityStack connective='and'>
                  <locality type='clause'>
                    <referenceFrom>3</referenceFrom>
                  </locality>
                </localityStack>
                <localityStack connective='or'>
                  <locality type='clause'>
                    <referenceFrom>5</referenceFrom>
                  </locality>
                </localityStack>
                text
              </eref>
              <eref type='inline' bibitemid='ref1' citeas='XYZ'>
                <localityStack connective='from'>
                  <locality type='clause'>
                    <referenceFrom>3</referenceFrom>
                  </locality>
                </localityStack>
                <localityStack connective='to'>
                  <locality type='clause'>
                    <referenceFrom>5</referenceFrom>
                  </locality>
                </localityStack>
                <localityStack connective='and'>
                  <locality type='clause'>
                    <referenceFrom>8</referenceFrom>
                  </locality>
                </localityStack>
                <localityStack connective='to'>
                  <locality type='clause'>
                    <referenceFrom>10</referenceFrom>
                  </locality>
                </localityStack>
              </eref>
            </p>
          </clause>
        </sections>
        <bibliography>
          <references id='_' normative='false' obligation='informative'>
            <title>Bibliography</title>
            <bibitem id='ref1'>
              <formattedref format='application/x-isodoc+xml'>
                <em>Standard</em>
              </formattedref>
              <docidentifier>XYZ</docidentifier>
            </bibitem>
          </references>
        </bibliography>
      </itu-standard>
    INPUT
    output = <<~OUTPUT
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
           <date day="1" year="2000" month="January"/>
         </front>
                 <middle>
           <section anchor="A">
             <name>Section</name>
             <t anchor="_"><xref target="ref1" section="3 to 5" relative=""/><xref target="ref1" section="3 to Clause 5, Table 2" relative=""/>
                 text
               </t>
             <xref target="ref1" section="3 and 5" relative=""/>
             <xref target="ref1" section="3, 5, and 7" relative=""/>
             <xref target="ref1" section="3 and Annex 5" relative=""/>
             <xref target="ref1" section="3 or 5" relative="">


                 text
               </xref>
             <xref target="ref1" section="3 to 5 and 8 to 10" relative=""/>
           </section>
         </middle>
         <back/>
       </rfc>
    OUTPUT
    expect(Canon.format_xml(IsoDoc::Ietf::RfcConvert.new({})
      .convert("test", input, true)))
      .to be_equivalent_to Canon.format_xml(output)
  end
end
