require "spec_helper"
require "nokogiri"
RSpec.describe IsoDoc::Ietf::RfcConvert do
  it "cleans up footnotes" do
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({}).cleanup(Nokogiri::XML(<<~"INPUT")).to_s)).to be_equivalent_to xmlpp(<<~"OUTPUT")
<rfc xmlns:xi='http://www.w3.org/2001/XInclude' version='3' prepTime='2000-01-01T05:00:00Z'>
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
<rfc xmlns:xi='http://www.w3.org/2001/XInclude' version='3' prepTime='2000-01-01T05:00:00Z'>
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
<rfc xmlns:xi='http://www.w3.org/2001/XInclude' version='3' prepTime='2000-01-01T05:00:00Z'>
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
<rfc xmlns:xi='http://www.w3.org/2001/XInclude' version='3' prepTime='2000-01-01T05:00:00Z'>
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
<rfc xmlns:xi='http://www.w3.org/2001/XInclude' version='3' prepTime='2000-01-01T05:00:00Z'>
         <front>
           <abstract>
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
               <t anchor='_0fe65e9a-5531-408e-8295-eeff35f41a55'>[a] Parboiled rice.</t>
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
    OUTPUT
  end

  it "cleans up figures" do
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({}).cleanup(Nokogiri::XML(<<~"INPUT")).to_s)).to be_equivalent_to xmlpp(<<~"OUTPUT")
<rfc xmlns:xi='http://www.w3.org/2001/XInclude' version='3' prepTime='2000-01-01T05:00:00Z'>
         <front>
           <abstract>
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
       <rfc xmlns:xi='http://www.w3.org/2001/XInclude' version='3' prepTime='2000-01-01T05:00:00Z'>
         <front>
           <abstract>
             <figure anchor='figureA-1'>
                [a]
               <name>
                  Split-it-right
                 <em>sample</em>
                  divider
               </name>
               <preamble>
                 <t anchor='AAA'>Random text</t>
               </preamble>
               <artwork src='rice_images/rice_image1.png' title='titletxt' anchor='_8357ede4-6d44-4672-bac4-9a85e82ab7f0' type='svg' alt='alttext'/>
               <postamble>
                 <artwork src='rice_images/rice_image1.png' anchor='_8357ede4-6d44-4672-bac4-9a85e82ab7f1' type='svg'/>
                 <artwork src='data:image/gif;base64,R0lGODlhEAAQAMQAAORHHOVSKudfOulrSOp3WOyDZu6QdvCchPGolfO0o/XBs/fNwfjZ0frl3/zy7////wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAkAABAALAAAAAAQABAAAAVVICSOZGlCQAosJ6mu7fiyZeKqNKToQGDsM8hBADgUXoGAiqhSvp5QAnQKGIgUhwFUYLCVDFCrKUE1lBavAViFIDlTImbKC5Gm2hB0SlBCBMQiB0UjIQA7' anchor='_8357ede4-6d44-4672-bac4-9a85e82ab7f2' type='svg'/>
                 <dl>
                   <dt>
                     <p>A</p>
                   </dt>
                   <dd>
                     <t>B</t>
                   </dd>
                 </dl>
                 <t anchor='_ef2c85b8-5a5a-4ecd-a1e6-92acefaaa852'>[a] The time $$ t_90 $$ was estimated to be 18,2 min for this example.</t>
               </postamble>
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
    OUTPUT
  end

end
