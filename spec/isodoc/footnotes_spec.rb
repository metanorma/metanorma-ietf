require "spec_helper"
require "fileutils"

RSpec.describe IsoDoc do
  it "processes IsoXML footnotes" do
    input = <<~INPUT
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
    output = <<~OUTPUT
      #{XML_HDR}
                   <t>
                     A.
                     <fnref>2</fnref>
                     <fn>
                       <t anchor='_'>
                         <ref>2</ref>
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
                       <t anchor='_'>
                         <ref>1</ref>
                         Hello! denoted as 15 % (m/m).
                       </t>
                     </fn>
                   </t>
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

  it "processes IsoXML reviewer notes" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface>
          <foreword>
          <p id="A">A.</p>
          <p id="B">B.</p>
          <bookmark id="C"/>
          <p>C.</p>
          </foreword>
          </preface>
          <annotation-container>
          <annotation reviewer="ISO" id="_4f4dff63-23c1-4ecb-8ac6-d3ffba93c711" date="20170101T0000" from="A" to="B" display="false">
      <name>Title</name><p id="_c54b9549-369f-4f85-b5b2-9db3fd3d4c07">A Foreword shall appear in each document. The generic text is shown here. It does not contain requirements, recommendations or permissions.</p>
      <p id="_f1a8b9da-ca75-458b-96fa-d4af7328975e">For further information on the Foreword, see <strong>ISO/IEC Directives, Part 2, 2016, Clause 12.</strong></p></annotation>
            <annotation reviewer="ISO" id="_4f4dff63-23c1-4ecb-8ac6-d3ffba93c712" date="20170108T0000" from="A" to="C"><p id="_c54b9549-369f-4f85-b5b2-9db3fd3d4c08">Second note.</p></annotation>
          <annotation reviewer="ISO" id="_4f4dff63-23c1-4ecb-8ac6-d3ffba93c712" date="20170108T0000" from="C" to="C"><p id="_c54b9549-369f-4f85-b5b2-9db3fd3d4c08">Third note.</p></annotation>
          </annotation-container>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
      #{XML_HDR}
                <t anchor="A">A.</t>
                <t anchor="B">B.</t>
                <bookmark anchor="C"/>
                <t>C.</t>
             </abstract>
             <date day="1" year="2000" month="January"/>
          </front>
          <middle/>
          <back/>
       </rfc>
    OUTPUT
    output_annotated = <<~OUTPUT
      #{XML_HDR}
                <t anchor="A">A.</t>
                <t anchor="B">B.</t>
                <bookmark anchor="C"/>
                <t>C.</t>
             </abstract>
             <date day="1" year="2000" month="January"/>
          </front>
          <middle/>
          <back>
             <cref anchor="_" display="false" source="ISO" from="A">
                Title
                <t anchor="_">A Foreword shall appear in each document. The generic text is shown here. It does not contain requirements, recommendations or permissions.</t>
                <t anchor="_">
                   For further information on the Foreword, see
                   <strong>ISO/IEC Directives, Part 2, 2016, Clause 12.</strong>
                </t>
             </cref>
             <cref anchor="_" source="ISO" from="A">
                <t anchor="_">Second note.</t>
             </cref>
             <cref anchor="_" source="ISO" from="C">
                <t anchor="_">Third note.</t>
             </cref>
          </back>
       </rfc>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::Ietf::RfcConvert.new({})
      .convert("test", input, true))))
      .to be_equivalent_to Xml::C14n.format(output)
    input1 = input.sub("<preface>", <<~XML)
      <metanorma-extension><presentation-metadata><render-document-annotations>true</render-document-annotations></presentation-metadata></metanorma-extension><preface>
    XML
    expect(Xml::C14n.format(strip_guid(IsoDoc::Ietf::RfcConvert.new({})
      .convert("test", input1, true))))
      .to be_equivalent_to Xml::C14n.format(output_annotated)
    input2 = input.sub("<preface>", <<~XML)
      <bibdata><ext><notedraftinprogress/></ext></bibdata><preface>
    XML
    expect(Xml::C14n.format(strip_guid(IsoDoc::Ietf::RfcConvert.new({})
      .convert("test", input2, true))))
      .to be_equivalent_to Xml::C14n.format(output_annotated)
  end
end
