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
       <rfc xmlns:xi='http://www.w3.org/2001/XInclude' version='3' prepTime='2000-01-01T05:00:00Z'>
         <front/>
         <middle>
           <section>
             <t anchor='note1'>
               NOTE: These results are based on a study carried out on three different
               types of kernel.
             </t>
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
    <note>
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a">They are based on a study carried out on three different types of kernel.</p>
</note>
    </clause></sections>
    </iso-standard>
    INPUT
        <rfc xmlns:xi='http://www.w3.org/2001/XInclude' version='3' prepTime='2000-01-01T05:00:00Z'>
         <front/>
         <middle>
           <section>
             <t anchor='_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f'>NOTE: These results are based on a study carried out on three different types of kernel.</t>
             <t anchor='_f06fd0d1-a203-4f3d-a515-0bdba0f8d83a'>They are based on a study carried out on three different types of kernel.</t>
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
    <note>
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
<rfc xmlns:xi='http://www.w3.org/2001/XInclude' version='3' prepTime='2000-01-01T05:00:00Z'>
         <front/>
         <middle>
           <section>
             <t>NOTE: </t>
             <dl>
               <dt>
                 <p>A</p>
               </dt>
               <dd>
                 <t>B</t>
               </dd>
             </dl>
             <ul>
               <li>C</li>
             </ul>
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
<pre>A &lt;
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
               <br/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <div id="figureA-1" class="figure">

         <img src="rice_images/rice_image1.png" height="20" width="30" alt="alttext" title="titletxt"/>
         <img src="rice_images/rice_image1.png" height="20" width="auto"/>
         <img src="data:image/gif;base64,R0lGODlhEAAQAMQAAORHHOVSKudfOulrSOp3WOyDZu6QdvCchPGolfO0o/XBs/fNwfjZ0frl3/zy7////wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAkAABAALAAAAAAQABAAAAVVICSOZGlCQAosJ6mu7fiyZeKqNKToQGDsM8hBADgUXoGAiqhSvp5QAnQKGIgUhwFUYLCVDFCrKUE1lBavAViFIDlTImbKC5Gm2hB0SlBCBMQiB0UjIQA7" height="20" width="auto"/>
         <a href="#_" class="TableFootnoteRef">a</a><aside class="footnote"><div id="fn:_"><span><span id="_" class="TableFootnoteRef">a</span>&#160; </span>
         <p id="_">The time <span class="stem">(#(t_90)#)</span> was estimated to be 18,2 min for this example.</p>
       </div></aside>
         <p><b>Key</b></p><dl><dt><p>A</p></dt><dd><p>B</p></dd></dl>
       <p class="FigureTitle" style="text-align:center;">Figure 1&#160;&#8212; Split-it-right <i>sample</i> divider</p></div>
               <div class="figure" id="figure-B">
<pre>A &lt;
B</pre>
<p class="FigureTitle" style="text-align:center;">Figure 2</p>
</div>
               <div class="figure" id="figure-C">
<pre>A &lt;
B</pre>
<p class="FigureTitle" style="text-align:center;"/>
</div>
               </div>
               <p class="zzSTDTitle1"/>
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
               <br/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <div id="samplecode" class="example">
                 <p class="example-title">EXAMPLE&#160;&#8212; Title</p>
         <p>Hello</p>
                 </div>
               </div>
               <p class="zzSTDTitle1"/>
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
               <br/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <div id="samplecode" class="example">
                 <p class="example-title">EXAMPLE  1</p>
         <p>Hello</p>
                 </div>
                 <div id="samplecode2" class="example">
                 <p class="example-title">EXAMPLE  2&#160;&#8212; Title</p>
                 <p>Hello</p>
                 </div>
                 <div id="samplecode3" class="example">
                 <p class="example-title">EXAMPLE</p>
                 <p>Hello</p>
                 </div>
               </div>
               <p class="zzSTDTitle1"/>
       </abstract></front><middle/><back/></rfc>
    OUTPUT
  end

  it "processes sourcecode" do
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <sourcecode lang="ruby" id="samplecode">
    <name>Ruby <em>code</em></name>
  puts x
</sourcecode>
    </foreword></preface>
    </iso-standard>
    INPUT
        #{XML_HDR}
               <br/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <pre id="samplecode" class="prettyprint lang-rb"><br/>&#160;&#160;&#160; <br/>&#160; puts x<br/><p class="SourceTitle" style="text-align:center;">Ruby <i>code</i></p></pre>
               </div>
               <p class="zzSTDTitle1"/>
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
               <br/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <pre id="samplecode" class="prettyprint "><br/>&#160;&#160;&#160; <br/>&#160; &lt;xml&gt;<br/><p class="SourceTitle" style="text-align:center;">XML code</p></pre>
               </div>
               <p class="zzSTDTitle1"/>
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
               <br/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <pre id="_" class="prettyprint ">puts "Hello, world."  &lt;1&gt;<br/>&#160;&#160; %w{a b c}.each do |x|<br/>&#160;&#160;&#160;&#160; puts x  &lt;2&gt;<br/>&#160;&#160; end<br/><br/>&lt;1&gt; This is one callout<br/>&lt;2&gt; This is another callout</pre>
               </div>
               <p class="zzSTDTitle1"/>
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
               <br/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <div class="Admonition"><p class="AdmonitionTitle" style="text-align:center;">CAUTION</p>
         <p id="_e94663cc-2473-4ccc-9a72-983a74d989f2">Only use paddy or parboiled rice for the determination of husked rice yield.</p>
       </div>
               </div>
               <p class="zzSTDTitle1"/>
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
               <br/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <div class="Admonition"><p class="AdmonitionTitle" style="text-align:center;">Title</p>
         <p id="_e94663cc-2473-4ccc-9a72-983a74d989f2">Only use paddy or parboiled rice for the determination of husked rice yield.</p>
       </div>
               </div>
               <p class="zzSTDTitle1"/>
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
  <dt>
    <stem type="AsciiMath">r</stem>
  </dt>
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
               <br/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <div id="_be9158af-7e93-4ee2-90c5-26d31c181934" class="formula"><p><span class="stem">(#(r = 1 %)#)</span></p></div><p>where</p><dl id="_e4fe94fe-1cde-49d9-b1ad-743293b7e21d"><dt>
           <span class="stem">(#(r)#)</span>
         </dt><dd>
           <p id="_1b99995d-ff03-40f5-8f2e-ab9665a69b77">is the repeatability limit.</p>
         </dd></dl>


           <div id="_83083c7a-6c85-43db-a9fa-4d8edd0c9fc0" class="Note"><p><span class="note_label">NOTE</span>&#160; [durationUnits] is essentially a duration statement without the "P" prefix. "P" is unnecessary because between "G" and "U" duration is always expressed.</p></div>

                 <div id="_be9158af-7e93-4ee2-90c5-26d31c181935" class="formula"><p><span class="stem">(#(r = 1 %)#)</span>&#160; (1)</p></div>
                 </div>
               <p class="zzSTDTitle1"/>
       </abstract></front><middle/><back/></rfc>
    OUTPUT
  end

  it "processes paragraph alignments" do
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <p align="left" id="_08bfe952-d57f-4150-9c95-5d52098cc2a8">Vache Equipment<br/>
Fictitious<br/>
World</p>
    <p align="justify">Justify</p>
    </foreword></preface>
    </iso-standard>
    INPUT
        #{XML_HDR}
               <br/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <p id="_08bfe952-d57f-4150-9c95-5d52098cc2a8" style="text-align:left;">Vache Equipment<br/>
       Fictitious<br/>
       World
           </p>
           <p style="text-align:justify;">Justify</p>
               </div>
               <p class="zzSTDTitle1"/>
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

    </foreword></preface>
    </iso-standard>
    INPUT
    #{XML_HDR}
               <br/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                 <div class="Quote" id="_044bd364-c832-4b78-8fea-92242402a1d1">


         <p id="_d4fd0a61-f300-4285-abe6-602707590e53">This International Standard gives the minimum specifications for rice (<i>Oryza sativa</i> L.) which is subject to international trade. It is applicable to the following types: husked rice and milled rice, parboiled or not, intended for direct human consumption. It is neither applicable to other products derived from rice, nor to waxy rice (glutinous rice).</p>
       <p class="QuoteAttribution">&#8212; ISO, <a href="#ISO7301">ISO 7301:2011, Clause 1</a></p></div>
               </div>
               <p class="zzSTDTitle1"/>
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
    #{XML_HDR}
               <p class="zzSTDTitle1"/>
               <div><h1>1.&#160; Terms and definitions</h1>
       <p class="TermNum" id="_extraneous_matter">1.1.</p><p class="Terms" style="text-align:left;">extraneous matter</p><p class="AltTerms" style="text-align:left;">EM</p>

       <p id="_318b3939-be09-46c4-a284-93f9826b981e">&lt;rice&gt; organic and inorganic components other than whole or broken kernels</p>
       </div>
       </abstract></front><middle/><back/></rfc>
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
       <br/>
      <div>
        <h1 class="ForewordTitle">Foreword</h1>
        <div class="permission"><p class="AdmonitionTitle">Permission 1:<br/>/ogc/recommendation/wfs/2</p>
        <p><i>Subject: user<br/>Control-class: Technical<br/>Priority: P0<br/>Family: System and Communications Protection<br/>Family: System and Communications Protocols</i></p>

  <div class="requirement-inherit">/ss/584/2015/level/1</div>
  <div class="requirement-description">
    <p id="_">I recommend <i>this</i>.</p>
  </div>

  <div class="requirement-description">
    <p id="_">As for the measurement targets,</p>
  </div>
  <div class="requirement-measurement-target">
    <p id="_">The measurement target shall be measured as:</p>
    <div id="_" class="formula"><p><span class="stem">(#(r/1 = 0)#)</span>&#160; (1)</p></div>


  </div>
  <div class="requirement-verification">
    <p id="_">The following code will be run for verification:</p>
    <pre id="_" class="prettyprint ">CoreRoot(success): HttpResponse<br/>&#160;&#160;&#160;&#160;&#160; if (success)<br/>&#160;&#160;&#160;&#160;&#160; recommendation(label: success-response)<br/>&#160;&#160;&#160;&#160;&#160; end<br/>&#160;&#160;&#160; </pre>
  </div>

</div>
      </div>
      <p class="zzSTDTitle1"/>
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
        <br/>
      <div>
        <h1 class="ForewordTitle">Foreword</h1>
        <div class="require"><p class="AdmonitionTitle">Requirement:<br/>/ogc/recommendation/wfs/2. A New Requirement</p><p><i>Subject: user</i></p>

  <div class="requirement-inherit">/ss/584/2015/level/1</div>
  <div class="requirement-description">
    <p id="_">I recommend <i>this</i>.</p>
  </div>

  <div class="requirement-description">
    <p id="_">As for the measurement targets,</p>
  </div>
  <div class="requirement-measurement-target">
    <p id="_">The measurement target shall be measured as:</p>
    <div id="B" class="formula"><p><span class="stem">(#(r/1 = 0)#)</span>&#160; (1)</p></div>


  </div>
  <div class="requirement-verification">
    <p id="_">The following code will be run for verification:</p>
    <pre id="_" class="prettyprint ">CoreRoot(success): HttpResponse<br/>&#160;&#160;&#160;&#160;&#160; if (success)<br/>&#160;&#160;&#160;&#160;&#160; recommendation(label: success-response)<br/>&#160;&#160;&#160;&#160;&#160; end<br/>&#160;&#160;&#160; </pre>
  </div>

</div>
      </div>
      <p class="zzSTDTitle1"/>
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
       <br/>
      <div>
        <h1 class="ForewordTitle">Foreword</h1>
<div class="recommend"><p class="AdmonitionTitle">Recommendation 1:<br/>/ogc/recommendation/wfs/2</p><p><i>Obligation: shall,could<br/>Subject: user<br/>Type: text<br/>Language: BASIC</i></p>
  <div class="requirement-inherit">/ss/584/2015/level/1</div>
  <div class="requirement-description">
    <p id="_">I recommend <i>this</i>.</p>
  </div>

  <div class="requirement-description">
    <p id="_">As for the measurement targets,</p>
  </div>
  <div class="requirement-measurement-target">
    <p id="_">The measurement target shall be measured as:</p>
    <div id="_" class="formula"><p><span class="stem">(#(r/1 = 0)#)</span>&#160; (1)</p></div>


  </div>
  <div class="requirement-verification">
    <p id="_">The following code will be run for verification:</p>
    <pre id="_" class="prettyprint ">CoreRoot(success): HttpResponse<br/>&#160;&#160;&#160;&#160;&#160; if (success)<br/>&#160;&#160;&#160;&#160;&#160; recommendation(label: success-response)<br/>&#160;&#160;&#160;&#160;&#160; end<br/>&#160;&#160;&#160; </pre>
  </div>

</div>
      </div>
      <p class="zzSTDTitle1"/>
</abstract></front><middle/><back/></rfc>
    OUTPUT
  end

 it "processes pseudocode" do
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
<itu-standard xmlns="http://riboseinc.com/isoxml">
    <bibdata>
    <language>en</language>
    </bibdata>
        <preface><foreword>
  <figure id="_" class="pseudocode"><name>Label</name><p id="_">  <strong>A</strong><br/>
        <smallcap>B</smallcap></p>
<p id="_">  <em>C</em></p></figure>
</preface></itu-standard>
INPUT
    #{XML_HDR}
             <br/>
             <div>
               <h1 class="ForewordTitle">Foreword</h1>
               <div id="_" class="pseudocode"><p id="_">&#160;&#160;<b>A</b><br/>
       &#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;<span style="font-variant:small-caps;">B</span></p>
       <p id="_">&#160;&#160;<i>C</i></p><p class="SourceTitle" style="text-align:center;">Label</p></div>
             </div>
             <p class="zzSTDTitle1"/>
</abstract></front><middle/><back/></rfc>
OUTPUT
  end

end
