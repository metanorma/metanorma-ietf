require "spec_helper"

RSpec.describe IsoDoc::Ietf::RfcConvert do
  it "processes inline formatting" do
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <p>
    <em>A</em> <strong>B</strong> <sup>C</sup> <sub>D</sub> <tt>E</tt>
    <strike>F</strike> <smallcap>G</smallcap> <keyword>I</keyword> <bcp14>must</bcp14> <br/> <hr/>
    <bookmark id="H"/> <pagebreak/>
    </p>
    </foreword></preface>
    <sections>
    </iso-standard>
    INPUT
    #{XML_HDR}
    <t>
  <em>A</em>
  <strong>B</strong>
  <sup>C</sup>
  <sub>D</sub>
  <tt>E</tt>
   F G I
  <bcp14>must</bcp14>
  <bookmark anchor='H'/>
</t>
</abstract></front><middle/><back/></rfc>
    OUTPUT
  end

  it "processes embedded inline formatting" do
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <p>
    <em><strong>&lt;</strong></em> <tt><link target="B"/></tt> <xref target="_http_1_1" format="title" relative="#abc">Requirement <tt>/req/core/http</tt></xref> <eref type="inline" bibitemid="ISO712" citeas="ISO 712">Requirement <tt>/req/core/http</tt></eref> <eref type="inline" bibitemid="ISO712" displayFormat="of" citeas="ISO 712" relative="xyz"><locality type="section"><referenceFrom>3.1</referenceFrom></locality></eref>
    </p>
    </foreword></preface>
    <sections>
    </iso-standard>
    INPUT
    #{XML_HDR}
    <t>
               <em>
                 <strong>&lt;</strong>
               </em>
               <tt>
                 <eref target='B'/>
               </tt>
               <xref target='_http_1_1' format='title' relative='#abc'>
                 Requirement
                 <tt>/req/core/http</tt>
               </xref>
               <relref target='ISO712' section='' relative=''>
                 Requirement
                 <tt>/req/core/http</tt>
               </relref>
               <relref target='ISO712' section='3.1' displayFormat="of" relative="xyz"/>
             </t>
</abstract></front><middle/><back/></rfc>
    OUTPUT
  end

  it "processes index terms" do
   expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
   <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <p>D<index primary="A" secondary="B" tertiary="C"/>.</p>
    </foreword></preface>
    <sections>
    </iso-standard>
   INPUT
   #{XML_HDR}
   <t>D<iref item='A' subitem='B'/>.</t>
   </abstract></front><middle/><back/></rfc>
   OUTPUT
  end

  it "processes inline images" do
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <p>
  <image src="rice_images/rice_image1.png" height="20" width="30" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png" alt="alttext" title="titletxt"/>
  </p>
  </foreword></preface>
  </iso-standard>
  INPUT
    #{XML_HDR}
    <t>
               <artwork src='rice_images/rice_image1.png' title='titletxt' anchor='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' type='svg' alt='alttext'/>
             </t>
</abstract></front><middle/><back/></rfc>
  OUTPUT
  end


  it "processes links" do
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <p>
    <link target="http://example.com"/>
    <link target="http://example.com">example</link>
    <link target="http://example.com" alt="tip">example</link>
    <link target="mailto:fred@example.com"/>
    <link target="mailto:fred@example.com">mailto:fred@example.com</link>
    </p>
    </foreword></preface>
    <sections>
    </iso-standard>
    INPUT
    #{XML_HDR}
    <t>
               <eref target='http://example.com'/>
               <eref target='http://example.com'>example</eref>
               <eref target='http://example.com'>example</eref>
               <eref target='mailto:fred@example.com'/>
               <eref target='mailto:fred@example.com'>mailto:fred@example.com</eref>
             </t>
</abstract></front><middle/><back/></rfc>
    OUTPUT
  end

  it "processes unrecognised markup" do
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <p>
    <barry fred="http://example.com">example</barry>
    </p>
    </foreword></preface>
    <sections>
    </iso-standard>
    INPUT
    #{XML_HDR}
<t>
  <t>&lt;barry fred="http://example.com"&gt;example&lt;/barry&gt;</t>
</t>
</abstract></front><middle/><back/></rfc>
    OUTPUT
  end

  it "processes AsciiMath and MathML" do
    expect((IsoDoc::Ietf::RfcConvert.new({}).convert("test", <<~"INPUT", true).sub(/<html/, "<html xmlns:m='m'"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml" xmlns:m="mathml">
    <preface><foreword>
    <p>
    <stem type="AsciiMath">&lt;A&gt;</stem>
    <stem type="MathML"><m:math><m:mrow><m:mi>X</m:mi></m:mrow></m:math></stem>
    <stem type="None">Latex?</stem>
    </p>
    </foreword></preface>
    <sections>
    </iso-standard>
    INPUT
    #{XML_HDR}
    <t>
$$ &lt;A&gt; $$
$$ X $$
$$ Latex? $$
</t>
</abstract></front><middle/><back/></rfc>
    OUTPUT
  end

  it "overrides AsciiMath delimiters" do
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
    #{XML_HDR}
    <t> $$$$ A $$$$ $$Hello$$$ </t>
</abstract></front><middle/><back/></rfc>
    OUTPUT
  end

    it "cross-references notes" do
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
    end

  it "processes eref attributes" do
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
      <abbreviation>ISO</abbreviation>
    </organization>
  </contributor>
</bibitem>
    </references>
    </bibliography>
    </iso-standard>
    INPUT
    #{XML_HDR}
    <t>
  <relref target='ISO712' section='' displayFormat='of' relative="#abc">A</relref>
</t>
</abstract></front><middle/>
<back>
  <references anchor='_normative_references'>
    <name>Normative References</name>
    <reference anchor='ISO712'>
      <front>
  <title>Cereals and cereal products</title>
  <author>
    <organization abbrev='ISO'/>
  </author>
</front>
<refcontent>ISO 712</refcontent>
    </reference>
  </references>
</back>
</rfc>
    OUTPUT
  end

  it "processes eref content" do
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
    <eref type="inline" bibitemid="ISO712"><localityStack><locality type="clause"><referenceFrom>1</referenceFrom></locality></localityStack><localityStack><locality type="clause"><referenceFrom>3</referenceFrom></locality></localityStack></eref>
    <eref type="inline" bibitemid="ISO712"><localityStack><locality type="clause"><referenceFrom>1</referenceFrom></locality></localityStack><localityStack><locality type="table"><referenceFrom>3</referenceFrom></locality></localityStack></eref>
    <eref type="inline" bibitemid="ISO712" citeas="ISO 712"><localityStack><locality type="anchor">><referenceFrom>1</referenceFrom></locality></localityStack>A</eref>
    <eref type="inline" bibitemid="ISO712"><localityStack><locality type="clause"><referenceFrom>1</referenceFrom></locality><locality type="anchor"><referenceFrom>xyz</referenceFrom></locality></localityStack><localityStack><locality type="clause"><referenceFrom>3</referenceFrom></locality></localityStack></eref>
    <eref type="inline" bibitemid="ISO712"><locality type="clause"><referenceFrom>1</referenceFrom></locality><locality type="table"><referenceFrom>1</referenceFrom></locality><locality type="anchor">><referenceFrom>1</referenceFrom></locality></eref>
    <eref type="inline" bibitemid="ISO712"><locality type="clause"><referenceFrom>1</referenceFrom></locality><locality type="anchor">><referenceFrom>1</referenceFrom></locality></eref>
    <eref type="inline" bibitemid="ISO712"><locality type="clause"><referenceFrom>1.5</referenceFrom></locality><locality type="anchor">><referenceFrom>1</referenceFrom></locality></eref>
    <eref type="inline" bibitemid="ISO712"><locality type="table"><referenceFrom>1</referenceFrom></locality><locality type="anchor">><referenceFrom>1</referenceFrom></locality>A</eref>
    <eref type="inline" bibitemid="ISO712"><locality type="whole"></locality><locality type="anchor">><referenceFrom>1</referenceFrom></locality></eref>
    <eref type="inline" bibitemid="ISO712"><locality type="locality:prelude"><referenceFrom>7</referenceFrom></locality><locality type="anchor">><referenceFrom>1</referenceFrom></locality></eref>
    </p>
    </foreword></preface>
    <bibliography><references id="_normative_references" obligation="informative" normative="true"><title>Normative References</title>
<bibitem id="ISO712" type="standard">
  <title format="text/plain">Cereals and cereal products</title>
  <docidentifier>ISO 712</docidentifier>
  <contributor>
    <role type="publisher"/>
    <organization>
      <abbreviation>ISO</abbreviation>
    </organization>
  </contributor>
</bibitem>
    </references>
    </bibliography>
    </iso-standard>
    INPUT
    #{XML_HDR}
    <t>
  <relref target='ISO712' section='' relative=''/>
  <relref target='ISO712' section='' relative=''/>
  <relref target='ISO712' section='' relative=''/>
  <relref target='ISO712' section='' relative=''/>
  <relref target='ISO712' section='' relative=''/>
  <relref target='ISO712' section='' relative=''/>
  <relref target='ISO712' section='' relative=''/>
  <relref target='ISO712' section='' relative=''>A</relref>
  <relref target='ISO712' section='' relative=''/>
  <relref target='ISO712' section='' relative=''/>
  <relref target='ISO712' section='' relative=''>A</relref>
  <relref target='ISO712' section='' relative=''/>
  <relref target='ISO712' section='' relative=''/>
  <relref target='ISO712' section='' relative='1'>A</relref>
  <relref target='ISO712' section='1; 3' relative='xyz'/>
  <relref target='ISO712' section='1' relative='1'/>
<relref target='ISO712' section='1' relative='1'/>
<relref target='ISO712' section='1.5' relative='1'/>
<relref target='ISO712' section='' relative='1'>A</relref>
<relref target='ISO712' section='' relative='1'/>
<relref target='ISO712' section='' relative='1'/>
</t>
</abstract></front><middle/>
<back>
  <references anchor='_normative_references'>
    <name>Normative References</name>
    <reference anchor='ISO712'>
      <front>
  <title>Cereals and cereal products</title>
  <author>
    <organization abbrev='ISO'/>
  </author>
</front>
<refcontent>ISO 712</refcontent>
    </reference>
  </references>
</back>
</rfc>
    OUTPUT
  end

  it "processes passthrough content" do
    FileUtils.rm_f "test.rfc.xml"
    IsoDoc::Ietf::RfcConvert.new({}).convert("test", <<~"INPUT", false)
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <p>
    <passthrough>&lt;abc&gt;X &amp;gt; Y</passthrough>
    A
    <passthrough>&lt;/abc&gt;</passthrough>
    </p>
    </preface>
    </iso-standard>
INPUT
    expect( File.read("test.rfc.xml")).to be_equivalent_to xmlpp(<<~"OUTPUT")
    #{XML_HDR}
    <t>
  <abc>X &gt; Y
   A 
   </abc>
</t>
    </abstract></front><middle/><back/></rfc>
OUTPUT
  end
end
