require "spec_helper"

RSpec.describe IsoDoc::Ietf::RfcConvert do
  it "processes IsoXML tables" do
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface>
    <foreword>
      <table id="tableD-1" alt="tool tip" summary="long desc">
  <name>Repeatability and reproducibility of <em>husked</em> rice yield</name>
  <thead>
    <tr>
      <td rowspan="2" align="left">Description</td>
      <td colspan="4" align="center">Rice sample</td>
    </tr>
    <tr>
      <td align="left">Arborio</td>
      <td align="center">Drago<fn reference="a">
  <p id="_0fe65e9a-5531-408e-8295-eeff35f41a55">Parboiled rice.</p>
</fn></td>
      <td align="center">Balilla<fn reference="a">
  <p id="_0fe65e9a-5531-408e-8295-eeff35f41a55">Parboiled rice.</p>
</fn></td>
      <td align="center">Thaibonnet</td>
    </tr>
    </thead>
    <tbody>
    <tr>
      <th align="left">Number of laboratories retained after eliminating outliers</th>
      <td align="center">13</td>
      <td align="center">11</td>
      <td align="center">13</td>
      <td align="center">13</td>
    </tr>
    <tr>
      <td align="left">Mean value, g/100 g</td>
      <td align="center">81,2</td>
      <td align="center">82,0</td>
      <td align="center">81,8</td>
      <td align="center">77,7</td>
    </tr>
    </tbody>
    <tfoot>
    <tr>
      <td align="left">Reproducibility limit, <stem type="AsciiMath">R</stem> (= 2,83 <stem type="AsciiMath">s_R</stem>)</td>
      <td align="center">2,89</td>
      <td align="center">0,57</td>
      <td align="center">2,26</td>
      <td align="center">6,06</td>
    </tr>
  </tfoot>
  <dl>
  <dt>Drago</dt>
<dd>A type of rice</dd>
</dl>
<note><p>This is a table about rice</p></note>
</table>

<table id="tableD-2" unnumbered="true">
<tbody><tr><td>A</td></tr></tbody>
</table>
</foreword>
</preface>
</iso-standard>
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
                   <td align='center'>Drago</td>
                   <td align='center'>Balilla</td>
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
             <t>NOTE: This is a table about rice</t>
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
