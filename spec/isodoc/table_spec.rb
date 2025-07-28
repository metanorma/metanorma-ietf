require "spec_helper"

RSpec.describe IsoDoc::Ietf::RfcConvert do
  it "processes IsoXML tables" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface>
          <foreword>
            <table id="tableD-1" alt="tool tip" summary="long desc" align="right">
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
                 <source status="generalisation">
        <origin bibitemid="ISO2191" type="inline" citeas="">
          <localityStack>
            <locality type="section">
              <referenceFrom>1</referenceFrom>
            </locality>
          </localityStack>
        </origin>
        <modification>
          <p id="_">with adjustments</p>
        </modification>
      </source>
      <note><p>This is a table about rice</p></note>
      </table>
      <table id="tableD-2" unnumbered="true">
      <tbody><tr><td>A</td></tr></tbody>
      </table>
      </foreword>
      </preface>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
          #{XML_HDR}
                   <table anchor='tableD-1' align="right">
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
          <t anchor='_'>[a] Parboiled rice.</t>
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
                     <dt>Drago</dt>
                     <dd>A type of rice</dd>
                   </dl>
                   <t>[SOURCE: <xref target="ISO2191" section="1" relative=""/> &#x2014; with adjustments]</t>
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
                 <date day="1" year="2000" month="January"/>
               </front>
               <middle/>
               <back/>
             </rfc>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::Ietf::RfcConvert.new({})
      .convert("test", input, true))))
      .to be_equivalent_to Xml::C14n.format(output)
  end
end
