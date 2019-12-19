require "spec_helper"

RSpec.describe IsoDoc::Ietf::RfcConvert do
  it "processes labelled notes" do
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <sections><clause>
    <note id="note1">
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
</note>
    </clause></sections>
    </iso-standard>
INPUT
#{RFC_HDR}
         <middle>
           <section>
             <aside anchor='note1'>
             <t>
               NOTE: These results are based on a study carried out on three different
               types of kernel.
               </t>
             </aside>
           </section>
         </middle>
         <back/>
       </rfc>
    OUTPUT
  end

  it "processes multi-para notes" do
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <sections><clause>
    <note id="A">
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a">They are based on a study carried out on three different types of kernel.</p>
</note>
    </clause></sections>
    </iso-standard>
    INPUT
#{RFC_HDR}
         <middle>
           <section>
            <aside anchor='A'>
             <t>NOTE: These results are based on a study carried out on three different types of kernel.</t>
             <t anchor='_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a'>They are based on a study carried out on three different types of kernel.</t>
             </aside>
           </section>
         </middle>
         <back/>
       </rfc>
    OUTPUT
  end

  it "processes non-para notes" do
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <sections><clause>
    <note id="A">
    <dl>
    <dt>A</dt>
    <dd><p>B</p></dd>
    </dl>
    <ul>
    <li>C</li></ul>
</note>
    </clause></sections>
    </iso-standard>
    INPUT
    #{RFC_HDR}
         <middle>
           <section>
           <aside anchor="A">
             <t>NOTE: </t>
             <dl>
               <dt>A</dt>
               <dd>
                 <t>B</t>
               </dd>
             </dl>
             <ul>
               <li>C</li>
             </ul>
             </aside>
           </section>
         </middle>
         <back/>
       </rfc>
    OUTPUT
  end

    it "processes note sequences" do
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <sections><clause>
    <note id="A">
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
</note>
<note id="B">
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a">They are based on a study carried out on three different types of kernel.</p>
  </note>
    </clause></sections>
    </iso-standard>
    INPUT
    #{RFC_HDR}
         <middle>
           <section>
           <aside anchor='A'>
           <t>
               NOTE 1: These results are based on a study carried out on three
               different types of kernel.
             </t>
             </aside>
             <aside anchor='B'>
             <t>
               NOTE 2: They are based on a study carried out on three different types
               of kernel.
             </t>
             </aside>
           </section>
         </middle>
         <back/>
       </rfc>
    OUTPUT
  end


  it "processes figures" do
    expect(xmlpp(strip_guid(IsoDoc::Ietf::RfcConvert.new({}).convert("test", <<~"INPUT", true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <figure id="figureA-1">
  <name>Split-it-right <em>sample</em> divider</name>
  <p id="AAA">Random text</p>
  <image src="rice_images/rice_image1.png" height="20" width="30" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f0" mimetype="image/png" alt="alttext" title="titletxt"/>
  <image src="rice_images/rice_image1.png" height="20" width="auto" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f1" mimetype="image/png"/>
  <image src="data:image/gif;base64,R0lGODlhEAAQAMQAAORHHOVSKudfOulrSOp3WOyDZu6QdvCchPGolfO0o/XBs/fNwfjZ0frl3/zy7////wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAkAABAALAAAAAAQABAAAAVVICSOZGlCQAosJ6mu7fiyZeKqNKToQGDsM8hBADgUXoGAiqhSvp5QAnQKGIgUhwFUYLCVDFCrKUE1lBavAViFIDlTImbKC5Gm2hB0SlBCBMQiB0UjIQA7" height="20" width="auto" id="_8357ede4-6d44-4672-bac4-9a85e82ab7f2" mimetype="image/png"/>
  <fn reference="a">
  <p id="_ef2c85b8-5a5a-4ecd-a1e6-92acefaaa852">The time <stem type="AsciiMath">t_90</stem> was estimated to be 18,2 min for this example.</p>
</fn>
  <dl>
  <dt>A</dt>
  <dd><p>B</p></dd>
  </dl>
</figure>
<figure id="figure-B">
<pre id="BC" alt="hello">A &lt;
B</pre>
</figure>
<figure id="figure-C" unnumbered="true">
<pre>A &lt;
B</pre>
</figure>
    </foreword></preface>
    </iso-standard>
    INPUT
        #{XML_HDR}
         <figure anchor='figureA-1'>
               <name>
                 Split-it-right
                 <em>sample</em>
                  divider
               </name>
               <t anchor='AAA'>Random text</t>
               <artwork src='rice_images/rice_image1.png' title='titletxt' anchor='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' type='svg' alt='alttext'/>
               <artwork src='rice_images/rice_image1.png' anchor='_8357ede4-6d44-4672-bac4-9a85e82ab7f1' type='svg'/>
               <artwork src='data:image/gif;base64,R0lGODlhEAAQAMQAAORHHOVSKudfOulrSOp3WOyDZu6QdvCchPGolfO0o/XBs/fNwfjZ0frl3/zy7////wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAkAABAALAAAAAAQABAAAAVVICSOZGlCQAosJ6mu7fiyZeKqNKToQGDsM8hBADgUXoGAiqhSvp5QAnQKGIgUhwFUYLCVDFCrKUE1lBavAViFIDlTImbKC5Gm2hB0SlBCBMQiB0UjIQA7' anchor='_8357ede4-6d44-4672-bac4-9a85e82ab7f2' type='svg'/>
                [a]
               <fn>
                 <t anchor='_ef2c85b8-5a5a-4ecd-a1e6-92acefaaa852'>[a] The time $$ t_90 $$ was estimated to be 18,2 min for this example.</t>
               </fn>
               <dl>
                 <dt>A</dt>
                 <dd>
                   <t>B</t>
                 </dd>
               </dl>
             </figure>
             <figure anchor='figure-B'>
               <artwork anchor='BC' alt='hello' type='ascii-art'><![CDATA[A <
       B]]></artwork>
             </figure>
             <figure anchor='figure-C'>
               <artwork type='ascii-art'><![CDATA[A <
       B]]></artwork>
             </figure>
       </abstract></front><middle/><back/></rfc>
    OUTPUT
  end

  it "processes examples" do
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <example id="samplecode">
    <name>Title</name>
  <p>Hello</p>
</example>
    </foreword></preface>
    </iso-standard>
    INPUT
        #{XML_HDR}
               <t anchor='samplecode'  keepWithNext='true'>EXAMPLE: Title</t>
             <t>Hello</t>
       </abstract></front><middle/><back/></rfc>
    OUTPUT
  end


  it "processes sequences of examples" do
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <example id="samplecode">
  <p>Hello</p>
</example>
    <example id="samplecode2">
    <name>Title</name>
  <p>Hello</p>
</example>
    <example id="samplecode3" unnumbered="true">
  <p>Hello</p>
</example>
    </foreword></preface>
    </iso-standard>
    INPUT
        #{XML_HDR}
        <t anchor='samplecode'  keepWithNext='true'>EXAMPLE 1</t>
             <t>Hello</t>
             <t anchor='samplecode2' keepWithNext='true'>EXAMPLE 2: Title</t>
             <t>Hello</t>
             <t anchor='samplecode3' keepWithNext='true'>EXAMPLE</t>
             <t>Hello</t>
       </abstract></front><middle/><back/></rfc>
    OUTPUT
  end

  it "processes sourcecode" do
    expect((IsoDoc::Ietf::RfcConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to (<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <sourcecode lang="ruby" id="samplecode" markers="true">
    <name>Ruby <em>code</em></name>
  puts x;
  puts y
</sourcecode>
    </foreword></preface>
    </iso-standard>
    INPUT
        #{XML_HDR}
        <figure anchor='samplecode'>
               <name>
                 Ruby
                 <em>code</em>
               </name>
               <sourcecode type='ruby' markers='true'>
         puts x;
         puts y
       </sourcecode>
             </figure>
       </abstract></front><middle/><back/></rfc>
    OUTPUT
  end

  it "processes sourcecode with escapes preserved" do
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <sourcecode id="samplecode">
    <name>XML code</name>
  &lt;xml&gt;
</sourcecode>
    </foreword></preface>
    </iso-standard>
    INPUT
        #{XML_HDR}
        <figure anchor='samplecode'>
               <name>XML code</name>
               <sourcecode> &lt;xml&gt; </sourcecode>
             </figure>
       </abstract></front><middle/><back/></rfc>
    OUTPUT
  end

  it "processes sourcecode with annotations" do
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <sourcecode id="_">puts "Hello, world." <callout target="A">1</callout>
       %w{a b c}.each do |x|
         puts x <callout target="B">2</callout>
       end<annotation id="A">
         <p id="_">This is <em>one</em> callout</p>
       </annotation><annotation id="B">
         <p id="_">This is another callout</p>
       </annotation></sourcecode>
    </foreword></preface>
    </iso-standard>
    INPUT
        #{XML_HDR}
             <figure anchor='_'>
               <sourcecode>
                 puts "Hello, world."  &lt;1&gt;
          %w{a b c}.each do |x|
            puts x  &lt;2&gt;
          end
     
       &lt;1&gt; This is one callout
       &lt;2&gt; This is another callout
               </sourcecode>
             </figure>
       </abstract></front><middle/><back/></rfc>
    OUTPUT
  end

  it "processes admonitions" do
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <admonition id="_70234f78-64e5-4dfc-8b6f-f3f037348b6a" type="caution">
  <p id="_e94663cc-2473-4ccc-9a72-983a74d989f2">Only use paddy or parboiled rice for the determination of husked rice yield.</p>
</admonition>
    </foreword></preface>
    </iso-standard>
    INPUT
        #{XML_HDR}
               <aside anchor='_70234f78-64e5-4dfc-8b6f-f3f037348b6a'>
               <t keepWithNext='true'>CAUTION</t>
               <t anchor='_e94663cc-2473-4ccc-9a72-983a74d989f2'>Only use paddy or parboiled rice for the determination of husked rice yield.</t>
             </aside>
       </abstract></front><middle/><back/></rfc>
    OUTPUT
  end

  it "processes admonitions with titles" do
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <admonition id="_70234f78-64e5-4dfc-8b6f-f3f037348b6a" type="caution">
    <name>Title</name>
  <p id="_e94663cc-2473-4ccc-9a72-983a74d989f2">Only use paddy or parboiled rice for the determination of husked rice yield.</p>
</admonition>
    </foreword></preface>
    </iso-standard>
    INPUT
        #{XML_HDR}
               <aside anchor='_70234f78-64e5-4dfc-8b6f-f3f037348b6a'>
               <t keepWithNext='true'>Title</t>
               <t anchor='_e94663cc-2473-4ccc-9a72-983a74d989f2'>Only use paddy or parboiled rice for the determination of husked rice yield.</t>
             </aside>
       </abstract></front><middle/><back/></rfc>
    OUTPUT
  end


  it "processes formulae" do
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <formula id="_be9158af-7e93-4ee2-90c5-26d31c181934" unnumbered="true">
  <stem type="AsciiMath">r = 1 %</stem>
<dl id="_e4fe94fe-1cde-49d9-b1ad-743293b7e21d">
  <dt><stem type="AsciiMath">r</stem></dt>
  <dd>
    <p id="_1b99995d-ff03-40f5-8f2e-ab9665a69b77">is the repeatability limit.</p>
  </dd>
</dl>
    <note id="_83083c7a-6c85-43db-a9fa-4d8edd0c9fc0">
  <p id="_511aaa98-4116-42af-8e5b-c87cdf5bfdc8">[durationUnits] is essentially a duration statement without the "P" prefix. "P" is unnecessary because between "G" and "U" duration is always expressed.</p>
</note>
    </formula>
    <formula id="_be9158af-7e93-4ee2-90c5-26d31c181935">
  <stem type="AsciiMath">r = 1 %</stem>
  </formula>
    </foreword></preface>
    </iso-standard>
    INPUT
        #{XML_HDR}
        <t anchor='_be9158af-7e93-4ee2-90c5-26d31c181934'>$$ r = 1 % $$</t>
             <t>where</t>
             <dl anchor='_e4fe94fe-1cde-49d9-b1ad-743293b7e21d'>
               <dt>$$ r $$</dt>
               <dd>
                 <t anchor='_1b99995d-ff03-40f5-8f2e-ab9665a69b77'>is the repeatability limit.</t>
               </dd>
             </dl>
             <aside anchor='_83083c7a-6c85-43db-a9fa-4d8edd0c9fc0'>
             <t>
               NOTE: [durationUnits] is essentially a duration statement without the
               "P" prefix. "P" is unnecessary because between "G" and "U" duration is
               always expressed.
             </t>
             </aside>
             <t anchor='_be9158af-7e93-4ee2-90c5-26d31c181935'>$$ r = 1 % $$ (1)</t>
       </abstract></front><middle/><back/></rfc>
    OUTPUT
  end

  it "processes paragraph attributes" do
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <p align="left" id="_08bfe952-d57f-4150-9c95-5d52098cc2a8" keepWithNext="true">Vache Equipment<br/>
Fictitious<br/>
World</p>
    <p align="justify" keepWithPrevious="true">Justify</p>
    </foreword></preface>
    </iso-standard>
    INPUT
        #{XML_HDR}
        <t keepWithNext='true' anchor='_08bfe952-d57f-4150-9c95-5d52098cc2a8'>Vache Equipment Fictitious World</t>
<t keepWithPrevious='true'>Justify</t>
       </abstract></front><middle/><back/></rfc>
    OUTPUT
  end

  it "processes blockquotes" do
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <quote id="_044bd364-c832-4b78-8fea-92242402a1d1">
  <source type="inline" bibitemid="ISO7301" citeas="ISO 7301:2011"><locality type="clause"><referenceFrom>1</referenceFrom></locality></source>
  <author>ISO</author>
  <p id="_d4fd0a61-f300-4285-abe6-602707590e53">This International Standard gives the minimum specifications for rice (<em>Oryza sativa</em> L.) which is subject to international trade. It is applicable to the following types: husked rice and milled rice, parboiled or not, intended for direct human consumption. It is neither applicable to other products derived from rice, nor to waxy rice (glutinous rice).</p>
</quote>
<quote id="_044bd364-c832-4b78-8fea-92242402a1d2">
  <source type="inline">http://www.example.com</source>
  <author>ISO</author>
  <p id="_d4fd0a61-f300-4285-abe6-602707590e53">This International Standard gives the minimum specifications for rice (<em>Oryza sativa</em> L.) which is subject to international trade. It is applicable to the following types: husked rice and milled rice, parboiled or not, intended for direct human consumption. It is neither applicable to other products derived from rice, nor to waxy rice (glutinous rice).</p>
</quote>

    </foreword></preface>
    </iso-standard>
    INPUT
    #{XML_HDR}
    <blockquote quotedFrom='ISO'>
               <t anchor='_d4fd0a61-f300-4285-abe6-602707590e53'>
                 This International Standard gives the minimum specifications for rice
                 (
                 <em>Oryza sativa</em>
                  L.) which is subject to international trade. It is applicable to the
                 following types: husked rice and milled rice, parboiled or not,
                 intended for direct human consumption. It is neither applicable to
                 other products derived from rice, nor to waxy rice (glutinous rice).
               </t>
             </blockquote>
             <blockquote quotedFrom='ISO' cite='http://www.example.com'>
               <t anchor='_d4fd0a61-f300-4285-abe6-602707590e53'>
                 This International Standard gives the minimum specifications for rice
                 (
                 <em>Oryza sativa</em>
                  L.) which is subject to international trade. It is applicable to the
                 following types: husked rice and milled rice, parboiled or not,
                 intended for direct human consumption. It is neither applicable to
                 other products derived from rice, nor to waxy rice (glutinous rice).
               </t>
             </blockquote>
       </abstract></front><middle/><back/></rfc>
    OUTPUT
  end

  it "processes term domains" do
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <sections>
    <terms>
    <term id="_extraneous_matter"><preferred>extraneous matter</preferred><admitted>EM</admitted>
<domain>rice</domain>
<definition><p id="_318b3939-be09-46c4-a284-93f9826b981e">organic and inorganic components other than whole or broken kernels</p></definition>
</term>
    </terms>
    </sections>
    </iso-standard>
    INPUT
         #{RFC_HDR}
         <middle>
           <section>
             <section anchor='_extraneous_matter'>
               <name>extraneous matter</name>
               <t>EM</t>
               <t anchor='_318b3939-be09-46c4-a284-93f9826b981e'>
                 &lt;rice&gt; organic and inorganic components other than whole or
                 broken kernels
               </t>
             </section>
           </section>
         </middle>
         <back/>
       </rfc>
    OUTPUT
  end

  it "processes permissions" do
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <permission id="_">
  <label>/ogc/recommendation/wfs/2</label>
  <inherit>/ss/584/2015/level/1</inherit>
  <subject>user</subject>
  <classification> <tag>control-class</tag> <value>Technical</value> </classification><classification> <tag>priority</tag> <value>P0</value> </classification><classification> <tag>family</tag> <value>System and Communications Protection</value> </classification><classification> <tag>family</tag> <value>System and Communications Protocols</value> </classification>
  <description>
    <p id="_">I recommend <em>this</em>.</p>
  </description>
  <specification exclude="true" type="tabular">
    <p id="_">This is the object of the recommendation:</p>
    <table id="_">
      <tbody>
        <tr>
          <td style="text-align:left;">Object</td>
          <td style="text-align:left;">Value</td>
        </tr>
        <tr>
          <td style="text-align:left;">Mission</td>
          <td style="text-align:left;">Accomplished</td>
        </tr>
      </tbody>
    </table>
  </specification>
  <description>
    <p id="_">As for the measurement targets,</p>
  </description>
  <measurement-target exclude="false">
    <p id="_">The measurement target shall be measured as:</p>
    <formula id="_">
      <stem type="AsciiMath">r/1 = 0</stem>
    </formula>
  </measurement-target>
  <verification exclude="false">
    <p id="_">The following code will be run for verification:</p>
    <sourcecode id="_">CoreRoot(success): HttpResponse
      if (success)
      recommendation(label: success-response)
      end
    </sourcecode>
  </verification>
  <import exclude="true">
    <sourcecode id="_">success-response()</sourcecode>
  </import>
</permission>
    </foreword></preface>
    </iso-standard>
    INPUT
    #{XML_HDR}
    <t keepWithNext='true'>Permission 1:</t>
             <t keepWithNext='true'>/ogc/recommendation/wfs/2</t>
             <ul>
               <li>
                 <em>Subject: user</em>
               </li>
               <li>
                 <em>Control-class: Technical</em>
               </li>
               <li>
                 <em>Priority: P0</em>
               </li>
               <li>
                 <em>Family: System and Communications Protection</em>
               </li>
               <li>
                 <em>Family: System and Communications Protocols</em>
               </li>
             </ul>
             <t>INHERIT: /ss/584/2015/level/1</t>
             <t anchor='_'>
               I recommend
               <em>this</em>
               .
             </t>
             <t anchor='_'>As for the measurement targets,</t>
             <t anchor='_'>The measurement target shall be measured as:</t>
             <t anchor='_'>$$ r/1 = 0 $$ (1)</t>
             <t anchor='_'>The following code will be run for verification:</t>
             <figure anchor='_'>
               <sourcecode>
                 CoreRoot(success): HttpResponse
      if (success)
      recommendation(label: success-response)
      end
               </sourcecode>
             </figure>
</abstract></front><middle/><back/></rfc>
    OUTPUT
  end

    it "processes requirements" do
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <requirement id="A" unnumbered="true">
  <title>A New Requirement</title>
  <label>/ogc/recommendation/wfs/2</label>
  <inherit>/ss/584/2015/level/1</inherit>
  <subject>user</subject>
  <description>
    <p id="_">I recommend <em>this</em>.</p>
  </description>
  <specification exclude="true" type="tabular">
    <p id="_">This is the object of the recommendation:</p>
    <table id="_">
      <tbody>
        <tr>
          <td style="text-align:left;">Object</td>
          <td style="text-align:left;">Value</td>
        </tr>
        <tr>
          <td style="text-align:left;">Mission</td>
          <td style="text-align:left;">Accomplished</td>
        </tr>
      </tbody>
    </table>
  </specification>
  <description>
    <p id="_">As for the measurement targets,</p>
  </description>
  <measurement-target exclude="false">
    <p id="_">The measurement target shall be measured as:</p>
    <formula id="B">
      <stem type="AsciiMath">r/1 = 0</stem>
    </formula>
  </measurement-target>
  <verification exclude="false">
    <p id="_">The following code will be run for verification:</p>
    <sourcecode id="_">CoreRoot(success): HttpResponse
      if (success)
      recommendation(label: success-response)
      end
    </sourcecode>
  </verification>
  <import exclude="true">
    <sourcecode id="_">success-response()</sourcecode>
  </import>
</requirement>
    </foreword></preface>
    </iso-standard>
    INPUT
    #{XML_HDR}
    <t keepWithNext='true'>Requirement:</t>
             <t keepWithNext='true'>/ogc/recommendation/wfs/2. A New Requirement</t>
             <ul>
               <li>
                 <em>Subject: user</em>
               </li>
             </ul>
             <t>INHERIT: /ss/584/2015/level/1</t>
             <t anchor='_'>
               I recommend
               <em>this</em>
               .
             </t>
             <t anchor='_'>As for the measurement targets,</t>
             <t anchor='_'>The measurement target shall be measured as:</t>
             <t anchor='B'>$$ r/1 = 0 $$ (1)</t>
             <t anchor='_'>The following code will be run for verification:</t>
             <figure anchor='_'>
               <sourcecode>
                 CoreRoot(success): HttpResponse
      if (success)
      recommendation(label: success-response)
      end
               </sourcecode>
             </figure>
</abstract></front><middle/><back/></rfc>
    OUTPUT
  end

      it "processes recommendation" do
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <recommendation id="_" obligation="shall,could">
  <label>/ogc/recommendation/wfs/2</label>
  <inherit>/ss/584/2015/level/1</inherit>
  <classification><tag>type</tag><value>text</value></classification>
  <classification><tag>language</tag><value>BASIC</value></classification>
  <subject>user</subject>
  <description>
    <p id="_">I recommend <em>this</em>.</p>
  </description>
  <specification exclude="true" type="tabular">
    <p id="_">This is the object of the recommendation:</p>
    <table id="_">
      <tbody>
        <tr>
          <td style="text-align:left;">Object</td>
          <td style="text-align:left;">Value</td>
        </tr>
        <tr>
          <td style="text-align:left;">Mission</td>
          <td style="text-align:left;">Accomplished</td>
        </tr>
      </tbody>
    </table>
  </specification>
  <description>
    <p id="_">As for the measurement targets,</p>
  </description>
  <measurement-target exclude="false">
    <p id="_">The measurement target shall be measured as:</p>
    <formula id="_">
      <stem type="AsciiMath">r/1 = 0</stem>
    </formula>
  </measurement-target>
  <verification exclude="false">
    <p id="_">The following code will be run for verification:</p>
    <sourcecode id="_">CoreRoot(success): HttpResponse
      if (success)
      recommendation(label: success-response)
      end
    </sourcecode>
  </verification>
  <import exclude="true">
    <sourcecode id="_">success-response()</sourcecode>
  </import>
</recommendation>
    </foreword></preface>
    </iso-standard>
    INPUT
    #{XML_HDR}
    <t keepWithNext='true'>Recommendation 1:</t>
             <t keepWithNext='true'>/ogc/recommendation/wfs/2</t>
             <ul>
               <li>
                 <em>Obligation: shall,could</em>
               </li>
               <li>
                 <em>Subject: user</em>
               </li>
               <li>
                 <em>Type: text</em>
               </li>
               <li>
                 <em>Language: BASIC</em>
               </li>
             </ul>
             <t>INHERIT: /ss/584/2015/level/1</t>
             <t anchor='_'>
               I recommend
               <em>this</em>
               .
             </t>
             <t anchor='_'>As for the measurement targets,</t>
             <t anchor='_'>The measurement target shall be measured as:</t>
             <t anchor='_'>$$ r/1 = 0 $$ (1)</t>
             <t anchor='_'>The following code will be run for verification:</t>
             <figure anchor='_'>
               <sourcecode>
                 CoreRoot(success): HttpResponse
      if (success)
      recommendation(label: success-response)
      end
               </sourcecode>
             </figure>
</abstract></front><middle/><back/></rfc>
    OUTPUT
  end

 it "processes pseudocode" do
    expect((IsoDoc::Ietf::RfcConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to (<<~"OUTPUT")
<itu-standard xmlns="http://riboseinc.com/isoxml">
        <preface><foreword>
  <figure id="_" class="pseudocode"><name>Label</name><p id="_">  <strong>A</strong><br/>
        <smallcap>B</smallcap></p>
<p id="_">  <em>C</em></p></figure>
</preface></itu-standard>
INPUT
    #{XML_HDR}
             <figure anchor='_'>
               <name>Label</name>
               <sourcecode>
                 <t anchor="_">&#xA0;&#xA0;<strong>A</strong>
&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;B</t>
<t anchor="_">&#xA0;&#xA0;<em>C</em></t>
               </sourcecode>
             </figure>
</abstract></front><middle/><back/></rfc>
OUTPUT
  end

end
