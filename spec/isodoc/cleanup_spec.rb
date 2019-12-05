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
end
