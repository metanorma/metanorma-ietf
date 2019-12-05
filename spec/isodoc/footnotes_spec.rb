require "spec_helper"
require "fileutils"

RSpec.describe IsoDoc do
  it "processes IsoXML footnotes" do
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface>
    <foreword>
    <p>A.<fn reference="2">
  <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Formerly denoted as 15 % (m/m).</p>
</fn></p>
    <p>B.<fn reference="2">
  <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Formerly denoted as 15 % (m/m).</p>
</fn></p>
    <p>C.<fn reference="1">
  <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Hello! denoted as 15 % (m/m).</p>
</fn></p>
    </foreword>
    </preface>
    </iso-standard>
    INPUT
    #{XML_HDR}
               <br/>
               <div>
                 <h1 class="ForewordTitle">Foreword</h1>
                <p>A.<a rel="footnote" href="#fn:2"><sup>2</sup></a></p>
                <p>B.<a rel="footnote" href="#fn:2"><sup>2</sup></a></p>
                <p>C.<a rel="footnote" href="#fn:1"><sup>1</sup></a></p>
               </div>
               <p class="zzSTDTitle1"/>
                             <aside id="fn:2" class="footnote">
          <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Formerly denoted as 15 % (m/m).</p>
        </aside>
              <aside id="fn:1" class="footnote">
          <p id="_1e228e29-baef-4f38-b048-b05a051747e4">Hello! denoted as 15 % (m/m).</p>
        </aside>
           </abstract></front><middle/><back/></rfc>
    OUTPUT
  end

  it "processes IsoXML reviewer notes" do
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface>
    <foreword>
    <p id="A">A.</p>
    <p id="B">B.</p>
    <review reviewer="ISO" id="_4f4dff63-23c1-4ecb-8ac6-d3ffba93c711" date="20170101T0000" from="A" to="B" display="false"><p id="_c54b9549-369f-4f85-b5b2-9db3fd3d4c07">A Foreword shall appear in each document. The generic text is shown here. It does not contain requirements, recommendations or permissions.</p>
<p id="_f1a8b9da-ca75-458b-96fa-d4af7328975e">For further information on the Foreword, see <strong>ISO/IEC Directives, Part 2, 2016, Clause 12.</strong></p></review>
    <p id="C">C.</p>
    <review reviewer="ISO" id="_4f4dff63-23c1-4ecb-8ac6-d3ffba93c712" date="20170108T0000" from="C" to="C"><p id="_c54b9549-369f-4f85-b5b2-9db3fd3d4c08">Second note.</p></review>
    </foreword>
    <introduction>
    <review reviewer="ISO" id="_4f4dff63-23c1-4ecb-8ac6-d3ffba93c712" date="20170108T0000" from="A" to="C"><p id="_c54b9549-369f-4f85-b5b2-9db3fd3d4c08">Second note.</p></review>
    </introduction>
    </preface>
    </iso-standard>
    INPUT
    #{XML_HDR}
    <t anchor='A'>A.</t>
             <t anchor='B'>B.</t>
             <cref anchor='_4f4dff63-23c1-4ecb-8ac6-d3ffba93c711' source='ISO' display='false'>
               <t anchor='_c54b9549-369f-4f85-b5b2-9db3fd3d4c07'>
                 A Foreword shall appear in each document. The generic text is shown
                 here. It does not contain requirements, recommendations or
                 permissions.
               </t>
               <t anchor='_f1a8b9da-ca75-458b-96fa-d4af7328975e'>
                 For further information on the Foreword, see
                 <strong>ISO/IEC Directives, Part 2, 2016, Clause 12.</strong>
               </t>
             </cref>
             <t anchor='C'>C.</t>
             <cref anchor='_4f4dff63-23c1-4ecb-8ac6-d3ffba93c712' source='ISO'>
               <t anchor='_c54b9549-369f-4f85-b5b2-9db3fd3d4c08'>Second note.</t>
             </cref>
           </abstract></front><middle/><back/></rfc>
    OUTPUT
  end


end
