require "spec_helper"
require "nokogiri"
RSpec.describe IsoDoc::Ietf::RfcConvert do
  it "cleans up footnotes" do
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({}).cleanup(Nokogiri::XML(<<~"INPUT")).to_s)).to be_equivalent_to xmlpp(<<~"OUTPUT")
<rfc xmlns:xi='http://www.w3.org/2001/XInclude' version='3'>
         <front>
           <abstract>
             <t>
               A.
               <fnref>2</fnref>
               <fn>
                 <t anchor='_1e228e29-baef-4f38-b048-b05a051747e4'><ref>2</ref>
                   Formerly denoted as 15 % (m/m).
                 </t>
               </fn>
             </t>
             <t>
               B.
               <fnref>2</fnref>
             </t>
             <t>
               C.
               <fnref>1</fnref>
               <fn>
                 <t anchor='_1e228e29-baef-4f38-b048-b05a051747e4'><ref>1</ref>
                   Hello! denoted as 15 % (m/m).
                 </t>
               </fn>
             </t>
           </abstract>
         </front>
         <middle/>
         <back/>
       </rfc>
INPUT
<rfc xmlns:xi='http://www.w3.org/2001/XInclude' version='3'>
         <front>
           <abstract>
             <t> A. [1] </t>
             <t> B. [1] </t>
             <t> C. [2] </t>
           </abstract>
         </front>
         <middle/>
         <back>
           <section>
             <name>Endnotes</name>
             <t anchor='_1e228e29-baef-4f38-b048-b05a051747e4'>[1] Formerly denoted as 15 % (m/m). </t>
             <t anchor='_1e228e29-baef-4f38-b048-b05a051747e4'>[2] Hello! denoted as 15 % (m/m). </t>
           </section>
         </back>
       </rfc>
    OUTPUT
  end

  it "cleans up footnotes in a section" do
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({}).cleanup(Nokogiri::XML(<<~"INPUT")).to_s)).to be_equivalent_to xmlpp(<<~"OUTPUT")
<rfc xmlns:xi='http://www.w3.org/2001/XInclude' version='3'>
         <front/>
         <middle>
           <section>
             <t>
               A.
               <fnref>2</fnref>
               <fn>
                 <t anchor='_1e228e29-baef-4f38-b048-b05a051747e4'><ref>2</ref>
                   Formerly denoted as 15 % (m/m).
                 </t>
               </fn>
             </t>
             <section>
             <t>
               B.
               <fnref>2</fnref>
             </t>
             </section>
             </section>
         </middle>
         <back>
         <section>
             <t>
               C.
               <fnref>1</fnref>
               <fn>
                 <t anchor='_1e228e29-baef-4f38-b048-b05a051747e4'><ref>1</ref>
                   Hello! denoted as 15 % (m/m).
                 </t>
               </fn>
             </t>
           </section>
         </back>
       </rfc>
INPUT
<rfc xmlns:xi='http://www.w3.org/2001/XInclude' version='3'>
         <front/>
         <middle>
           <section>
             <t> A. [1] </t>
             <section>
               <t> B. [1] </t>
             </section>
           </section>
         </middle>
         <back>
           <section>
             <t> C. [2] </t>
           </section>
           <section>
             <name>Endnotes</name>
             <t anchor='_1e228e29-baef-4f38-b048-b05a051747e4'>[1] Formerly denoted as 15 % (m/m). </t>
             <t anchor='_1e228e29-baef-4f38-b048-b05a051747e4'>[2] Hello! denoted as 15 % (m/m). </t>
           </section>
         </back>
       </rfc>
    OUTPUT
  end


  it "cleans up table footnotes" do
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({}).cleanup(Nokogiri::XML(<<~"INPUT")).to_s)).to be_equivalent_to xmlpp(<<~"OUTPUT")
    #{XML_HDR}
             <table anchor='tableD-1'>
               <name>
                 Repeatability and reproducibility of
                 <em>husked</em>
                  rice yield
               </name>
               <thead>
                 <tr>
                   <td rowspan='2' align='left'>Description</td>
                   <td colspan='4' align='center'>Rice sample</td>
                 </tr>
                 <tr>
                   <td align='left'>Arborio</td>
                   <td align='center'>
  Drago [a]
  <fn>
    <t anchor='_0fe65e9a-5531-408e-8295-eeff35f41a55'>[a] Parboiled rice.</t>
  </fn>
</td>
<td align='center'>Balilla [a]</td>
                   <td align='center'>Thaibonnet</td>
                 </tr>
               </thead>
               <tbody>
                 <tr>
                   <th align='left'>Number of laboratories retained after eliminating outliers</th>
                   <td align='center'>13</td>
                   <td align='center'>11</td>
                   <td align='center'>13</td>
                   <td align='center'>13</td>
                 </tr>
                 <tr>
                   <td align='left'>Mean value, g/100 g</td>
                   <td align='center'>81,2</td>
                   <td align='center'>82,0</td>
                   <td align='center'>81,8</td>
                   <td align='center'>77,7</td>
                 </tr>
               </tbody>
               <tfoot>
                 <tr>
                 <td align='left'>Reproducibility limit, $$ R $$ (= 2,83 $$ s_R $$)</td>
                   <td align='center'>2,89</td>
                   <td align='center'>0,57</td>
                   <td align='center'>2,26</td>
                   <td align='center'>6,06</td>
                 </tr>
               </tfoot>
             </table>
             <dl>
               <dt>
                 <p>Drago</p>
               </dt>
               <dd>A type of rice</dd>
             </dl>
             <aside>
             <t>NOTE: This is a table about rice</t>
             </aside>
             <table anchor='tableD-2'>
               <tbody>
                 <tr>
                   <td>A</td>
                 </tr>
               </tbody>
             </table>
           </abstract>
         </front>
         <middle/>
         <back/>
       </rfc>
INPUT
    #{XML_HDR}
             <table anchor='tableD-1'>
               <name>
                  Repeatability and reproducibility of
                 <em>husked</em>
                  rice yield
               </name>
               <thead>
                 <tr>
                   <td rowspan='2' align='left'>Description</td>
                   <td colspan='4' align='center'>Rice sample</td>
                 </tr>
                 <tr>
                   <td align='left'>Arborio</td>
                   <td align='center'> Drago [a] </td>
                   <td align='center'>Balilla [a]</td>
                   <td align='center'>Thaibonnet</td>
                 </tr>
               </thead>
               <tbody>
                 <tr>
                   <th align='left'>Number of laboratories retained after eliminating outliers</th>
                   <td align='center'>13</td>
                   <td align='center'>11</td>
                   <td align='center'>13</td>
                   <td align='center'>13</td>
                 </tr>
                 <tr>
                   <td align='left'>Mean value, g/100 g</td>
                   <td align='center'>81,2</td>
                   <td align='center'>82,0</td>
                   <td align='center'>81,8</td>
                   <td align='center'>77,7</td>
                 </tr>
               </tbody>
               <tfoot>
                 <tr>
                   <td align='left'>Reproducibility limit, $$ R $$ (= 2,83 $$ s_R $$)</td>
                   <td align='center'>2,89</td>
                   <td align='center'>0,57</td>
                   <td align='center'>2,26</td>
                   <td align='center'>6,06</td>
                 </tr>
               </tfoot>
             </table>
             <aside>
               <t anchor='_0fe65e9a-5531-408e-8295-eeff35f41a55'>[a] Parboiled rice.</t>
               </aside>
             <dl>
               <dt>
                 <p>Drago</p>
               </dt>
               <dd>A type of rice</dd>
             </dl>
             <aside>
               <t>NOTE: This is a table about rice</t>
             </aside>
             <table anchor='tableD-2'>
               <tbody>
                 <tr>
                   <td>A</td>
                 </tr>
               </tbody>
             </table>
           </abstract>
         </front>
         <middle/>
         <back/>
       </rfc>
    OUTPUT
  end

  it "cleans up figures" do
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({}).cleanup(Nokogiri::XML(<<~"INPUT")).to_s)).to be_equivalent_to xmlpp(<<~"OUTPUT")
<rfc xmlns:xi='http://www.w3.org/2001/XInclude' version='3'>
         <front>
           <abstract>
     <figure anchor='figureA-0'>
     <name>Unnested figure</name>
     <figure anchor="figureA-00">
     <name>Unnested figure 1</name>
     <figure anchor="figureA-000">
     <name>Unnested figure 2</name>
     </figure>
     </figure>
     </figure>
     <figure anchor="figureA-001">
     <aside><t>X</t></aside>
     </figure>
     <artwork src="spec/assets/Example.svg" align="right" anchor="_56cb3ff4-1775-40c6-b75d-d5c2283e8338" type="svg" alt="Orb"/>
     <sourcecode/>
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
                 <dt>
                   <p>A</p>
                 </dt>
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
             </abstract>
         </front>
         <middle/>
         <back/>
       </rfc>
       INPUT
       <rfc xmlns:xi='http://www.w3.org/2001/XInclude' version='3'>
         <front>
           <abstract>
           <figure anchor='figureA-0'>
  <name>Unnested figure</name>
</figure>
<figure anchor='figureA-00'>
  <name>Unnested figure 1</name>
</figure>
<figure anchor='figureA-000'>
  <name>Unnested figure 2</name>
</figure>
<figure anchor='figureA-001'> </figure>
<aside>
  <t>X</t>
</aside>
<figure>
               <artwork src='spec/assets/Example.svg' align='right' anchor='_56cb3ff4-1775-40c6-b75d-d5c2283e8338' type='svg' alt='Orb'/>
             </figure>
             <figure>
  <sourcecode><![CDATA[]]></sourcecode>
</figure>
                 <t anchor='AAA'>Random text</t>
             <figure anchor='figureA-1'>
                [a]
               <name>
                  Split-it-right
                 <em>sample</em>
                  divider
               </name>
               <artwork src='rice_images/rice_image1.png' title='titletxt' anchor='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' type='svg' alt='alttext'/>
               </figure>
               <figure>
                 <artwork src='rice_images/rice_image1.png' anchor='_8357ede4-6d44-4672-bac4-9a85e82ab7f1' type='svg'/>
                 </figure>
                 <figure>
                 <artwork src='data:image/gif;base64,R0lGODlhEAAQAMQAAORHHOVSKudfOulrSOp3WOyDZu6QdvCchPGolfO0o/XBs/fNwfjZ0frl3/zy7////wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAkAABAALAAAAAAQABAAAAVVICSOZGlCQAosJ6mu7fiyZeKqNKToQGDsM8hBADgUXoGAiqhSvp5QAnQKGIgUhwFUYLCVDFCrKUE1lBavAViFIDlTImbKC5Gm2hB0SlBCBMQiB0UjIQA7' anchor='_8357ede4-6d44-4672-bac4-9a85e82ab7f2' type='svg'/>
                 </figure>
                 <dl>
                   <dt>
                     <p>A</p>
                   </dt>
                   <dd>
                     <t>B</t>
                   </dd>
                 </dl>
             <figure anchor='figure-B'>
               <artwork anchor='BC' alt='hello' type='ascii-art'><![CDATA[A <
       B]]></artwork>
             </figure>
             <figure anchor='figure-C'>
               <artwork type='ascii-art'><![CDATA[A <
       B]]></artwork>
             </figure>
           </abstract>
         </front>
         <middle/>
          <back>
           <section>
             <name>Endnotes</name>
             <t anchor='_ef2c85b8-5a5a-4ecd-a1e6-92acefaaa852'>[a] The time $$ t_90 $$ was estimated to be 18,2 min for this example.</t>
           </section>
         </back>
       </rfc>
    OUTPUT
  end

   it "cleans up inline figures" do
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({}).cleanup(Nokogiri::XML(<<~"INPUT")).to_s)).to be_equivalent_to xmlpp(<<~"OUTPUT")
     #{XML_HDR}
    <t>
               <artwork src='rice_images/rice_image1.png' title='titletxt 1' anchor='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' type='svg' alt='alttext'/>
               <artwork src='rice_images/rice_image1.png' title='titletxt 2' anchor='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' type='svg' alt='alttext'/>
             </t>
</abstract></front><middle/><back/></rfc>
    INPUT
     #{XML_HDR}
             <t> [IMAGE 1] [IMAGE 2] </t>
             <figure>
             <artwork src='rice_images/rice_image1.png' title='titletxt 1' anchor='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' type='svg' alt='alttext'/>
             </figure>
             <figure>
             <artwork src='rice_images/rice_image1.png' title='titletxt 2' anchor='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' type='svg' alt='alttext'/>
             </figure>
           </abstract>
         </front>
         <middle/>
         <back/>
       </rfc>
    OUTPUT
   end

   it "cleans up sourcecode" do
      expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({}).cleanup(Nokogiri::XML(<<~"INPUT")).to_s)).to be_equivalent_to (<<~"OUTPUT")
      #{XML_HDR}
             <figure anchor='_'>
               <name>Label</name>
               <sourcecode>
                 <t anchor="_">&#xA0;&#xA0;<strong><em>A</em></strong><br/>
&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;&#xA0;B<br/>B1</t>
<t anchor="_">&#xA0;&#xA0;<em>C &gt; E</em></t>
               </sourcecode>
             </figure>
             <figure anchor='samplecode'>
               <name>
                 Ruby
                 <em>code</em>
               </name>
             <sourcecode type='ruby'>
         puts x;
         puts y;

         puts z
       </sourcecode></figure>
</abstract></front><middle/><back/></rfc>
INPUT
#{XML_HDR}
                    <figure anchor="_">


                    <name>Label</name><sourcecode><![CDATA[  A
        B
B1

  C  E]]></sourcecode></figure>
                    <figure anchor="samplecode">

                    <name>
                        Ruby
                        <em>code</em>
                      </name><sourcecode type="ruby"><![CDATA[         puts x;
         puts y;

         puts z
       ]]></sourcecode></figure>
       </abstract></front><middle/><back/></rfc>
OUTPUT
   end

   it "cleans up annotated bibliography" do
      expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({}).cleanup(Nokogiri::XML(<<~"INPUT")).to_s)).to be_equivalent_to xmlpp(<<~"OUTPUT")
      <rfc xmlns:xi='http://www.w3.org/2001/XInclude' xml:lang='en' version='3'>
         <front>
           <abstract>
             <t anchor='_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f'>
               <relref target='ISO712'/>
               <relref target='ISBN'/>
               <relref target='ISSN'/>
               <relref target='ISO16634'/>
               <relref target='ref1'/>
               <relref target='ref10'/>
               <relref target='ref12'/>
             </t>
           </abstract>
         </front>
         <middle/>
         <back>
           <references anchor='_normative_references'>
             <name>Normative References</name>
             <reference anchor='ISO712'>
               <front>
                 <title>ISO 712, Cereals or cereal products</title>
               </front>
             </reference>
             <reference anchor='ISO16634'>
               <front>
                 <title>
                   ISO 16634:-- (all parts), Cereals, pulses, milled cereal products,
                   xxxx, oilseeds and animal feeding stuffs
                 </title>
                 <author>
                   <organization asciiName='International Supporters of Odium' abbrev='ISO1'>International Supporters of Odium</organization>
                 </author>
                 <keyword>keyword1</keyword>
                 <keyword>keyword2</keyword>
                 <abstract>
                   <t>This is an abstract</t>
                 </abstract>
               </front>
             </reference>
             <reference anchor='ISO20483'>
               <front>
                 <title>ISO 20483:2013-2014, Cereals and pulses</title>
                 <author fullname='&#xD6;laf N&#xFC;rk' asciiFullname='Olaf Nurk' surname='N&#xFC;rk' asciiSurname='Nurk'/>
                 <author>
                   <organization/>
                 </author>
                 <date year='2013'/>
               </front>
             </reference>
             <reference anchor='ref1'>
               <front>
                 <title>
                   ICC 167, Standard No I.C.C 167.
                   <em>
                     Determination of the protein content in cereal and cereal products
                     for food and animal feeding stuffs according to the Dumas
                     combustion method
                   </em>
                    (see
                   <eref target='http://www.icc.or.at'/>
                   )
                 </title>
               </front>
             </reference>
             <aside>
               <t>NOTE: This is an annotation of ISO 20483:2013-2014</t>
             </aside>
           </references>
           <references anchor='_bibliography'>
             <name>Bibliography</name>
             <reference anchor='ISBN'>
               <front>
                 <title>1, Chemicals for analytical laboratory use</title>
               </front>
             </reference>
             <reference anchor='ISSN'>
               <front>
                 <title>2, Instruments for analytical laboratory use</title>
               </front>
             </reference>
             <aside>
               <t>NOTE: This is an annotation of document ISSN.</t>
             </aside>
             <aside>
               <t>NOTE: This is another annotation of document ISSN.</t>
             </aside>
             <reference anchor='ISO3696'>
               <front>
                 <title>ISO 3696, Water for analytical laboratory use</title>
               </front>
             </reference>
             <reference anchor='ref10'>
               <front>
                 <title>
                   10, Standard No I.C.C 167.
                   <em>
                     Determination of the protein content in cereal and cereal products
                     for food and animal feeding stuffs according to the Dumas
                     combustion method
                   </em>
                    (see
                   <eref target='http://www.icc.or.at'/>
                   )
                 </title>
               </front>
             </reference>
             <xi:include href='https://xml2rfc.tools.ietf.org/10.xml'/>
             <reference anchor='ref12'>
               <front>
                 <title>
                   Citn, CitationWorks. 2019.
                   <em>How to cite a reference</em>
                   .
                 </title>
               </front>
             </reference>
           </references>
         </back>
       </rfc>
      INPUT
      <rfc xmlns:xi="http://www.w3.org/2001/XInclude" xml:lang="en" version="3">
          <front>
            <abstract>
              <t anchor="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">
                <relref target="ISO712"/>
                <relref target="ISBN"/>
                <relref target="ISSN"/>
                <relref target="ISO16634"/>
                <relref target="ref1"/>
                <relref target="ref10"/>
                <relref target="ref12"/>
              </t>
            </abstract>
          </front>
          <middle/>
          <back>
            <references anchor="_normative_references">
              <name>Normative References</name>
              <reference anchor="ISO712">
                <front>
                  <title>ISO 712, Cereals or cereal products</title>
                 <author surname="Unknown"/>
                </front>
              </reference>
              <reference anchor="ISO16634">
                <front>
                  <title>
                    ISO 16634:-- (all parts), Cereals, pulses, milled cereal products,
                    xxxx, oilseeds and animal feeding stuffs
                  </title>
                  <author>
                    <organization asciiName="International Supporters of Odium" abbrev="ISO1">International Supporters of Odium</organization>
                  </author>
                  <keyword>keyword1</keyword>
                  <keyword>keyword2</keyword>
                  <abstract>
                    <t>This is an abstract</t>
                  </abstract>
                </front>
              </reference>
              <reference anchor="ISO20483">
                <front>
                  <title>ISO 20483:2013-2014, Cereals and pulses</title>
                  <author fullname="&#xD6;laf N&#xFC;rk" asciiFullname="Olaf Nurk" surname="N&#xFC;rk" asciiSurname="Nurk"/>
                  <author>
                    <organization/>
                  </author>
                  <date year="2013"/>
                </front>
              </reference>
              <reference anchor="ref1">
                <front>
                  <title>
                    ICC 167, Standard No I.C.C 167.

                      Determination of the protein content in cereal and cereal products
                      for food and animal feeding stuffs according to the Dumas
                      combustion method

                     (see

                    )
                  </title>
                 <author surname="Unknown"/>
                </front>
              <annotation>
                NOTE: This is an annotation of ISO 20483:2013-2014
              </annotation></reference>

            </references>
            <references anchor="_bibliography">
              <name>Bibliography</name>
              <reference anchor="ISBN">
                <front>
                  <title>1, Chemicals for analytical laboratory use</title>
                 <author surname="Unknown"/>
                </front>
              </reference>
              <reference anchor="ISSN">
                <front>
                  <title>2, Instruments for analytical laboratory use</title>
                 <author surname="Unknown"/>
                </front>
              <annotation>
                NOTE: This is an annotation of document ISSN.
              </annotation></reference>


              <reference anchor="ISO3696">
                <front>
                  <title>ISO 3696, Water for analytical laboratory use</title>
                 <author surname="Unknown"/>
                </front>
              </reference>
              <reference anchor="ref10">
                <front>
                  <title>
                    10, Standard No I.C.C 167.

                      Determination of the protein content in cereal and cereal products
                      for food and animal feeding stuffs according to the Dumas
                      combustion method

                     (see

                    )
                  </title>
                 <author surname="Unknown"/>
                </front>
              </reference>
              <xi:include href="https://xml2rfc.tools.ietf.org/10.xml"/>
              <reference anchor="ref12">
                <front>
                  <title>
                    Citn, CitationWorks. 2019.
                    How to cite a reference
                    .
                  </title>
                 <author surname="Unknown"/>
                </front>
              </reference>
            </references>
          </back>
        </rfc>
      OUTPUT
   end

     it "cleans up definition lists" do
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({}).cleanup(Nokogiri::XML(<<~"INPUT")).to_s)).to be_equivalent_to xmlpp(<<~"OUTPUT")
<rfc xmlns:xi='http://www.w3.org/2001/XInclude' version='3'>
         <front>
           <abstract>
           <t id="id0"><bookmark anchor="id1"/>A</t>
           <dl>
           <dt><bookmark anchor="id1"/>A</dt>
           <dd><t anchor="id2">B</t></dd>
           <dt><t anchor="id3"><strong>C</strong></t><t anchor="id4">D</t></dt>
           <dd><t anchor="id5">E</t></dd>
           </dl>
           </abstract>
         </front>
         <middle/>
         <back/>
       </rfc>
INPUT
<rfc xmlns:xi='http://www.w3.org/2001/XInclude' version='3'>
  <front>
    <abstract>
    <t id='id0'>A</t>
      <dl>
        <dt anchor='id1'>A</dt>
        <dd>
          <t anchor='id2'>B</t>
        </dd>
        <dt anchor='id3'>
          <strong>C</strong>
          D
        </dt>
        <dd>
          <t anchor='id5'>E</t>
        </dd>
      </dl>
    </abstract>
  </front>
  <middle/>
  <back/>
</rfc>
OUTPUT

end

=begin
      it "cleans up xrefs and relrefs" do
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({}).cleanup(Nokogiri::XML(<<~"INPUT")).to_s)).to be_equivalent_to xmlpp(<<~"OUTPUT")
<rfc xmlns:xi='http://www.w3.org/2001/XInclude' version='3'>
         <front>
           <abstract>
           <t id="id0">
           <xref relative="" section=""/>
           <relref relative="" section=""/>
           </t>
           </abstract>
         </front>
         <middle/>
         <back/>
       </rfc>
INPUT
<rfc xmlns:xi='http://www.w3.org/2001/XInclude' version='3'>
  <front>
    <abstract>
    <t id='id0'>
  <xref/>
  <relref/>
</t>
    </abstract>
  </front>
  <middle/>
  <back/>
</rfc>
OUTPUT

end
=end

      it "reports parsing errors on RFC XML output" do
    FileUtils.rm_f "test.rfc.xml"
    expect { IsoDoc::Ietf::RfcConvert.new({}).convert("test", <<~"INPUT", false) }.to output(/RFC XML: Line/).to_stderr
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
  end


end
