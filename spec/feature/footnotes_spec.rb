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
    # WS3 migration: the old expectation captured the released path's
    # DEBUG (pre-cleanup) output — inline <fn>/<fnref>, which are not
    # RFC 7991 vocabulary; the released cleanup itself converts them
    # to back-matter endnotes (footnote_cleanup/make_endnotes), which
    # is the pipeline's final form asserted here. Reused footnotes
    # share a number ([1] twice); numbering is first-use-sequential.
    output = <<~OUTPUT
      #{FEATURE_HDR}
                   <t>A. [1]</t>
                   <t>B. [1]</t>
                   <t>C. [2]</t>
                 </abstract>
               </front>
               <middle/>
               <back>
                 <section anchor="endnotes">
                   <name>Endnotes</name>
                   <t anchor="_">[1] Formerly denoted as 15 % (m/m).</t>
                   <t anchor="_">[2] Hello! denoted as 15 % (m/m).</t>
                 </section>
               </back>
             </rfc>
    OUTPUT
    expect(strip_guid(feature_convert(input)))
      .to be_xml_equivalent_to output
  end

  it "processes IsoXML reviewer notes" do
    pending "annotation-container/annotation of this vintage parses " \
            "to zero annotations in the model (metanorma-document " \
            "0.2.9), so no crefs can be built; <bookmark> is likewise " \
            "unmapped — see qa-plan WS3 note"
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
    expect(strip_guid(feature_convert(input)))
      .to be_xml_equivalent_to output
    input1 = input.sub("<preface>", <<~XML)
      <metanorma-extension><presentation-metadata><render-document-annotations>true</render-document-annotations></presentation-metadata></metanorma-extension><preface>
    XML
    expect(strip_guid(feature_convert(input1)))
      .to be_xml_equivalent_to output_annotated
    input2 = input.sub("<preface>", <<~XML)
      <bibdata><ext><notedraftinprogress/></ext></bibdata><preface>
    XML
    expect(strip_guid(feature_convert(input2)))
      .to be_xml_equivalent_to output_annotated
  end
end
