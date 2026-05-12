       <?xml version="1.0" encoding="UTF-8"?>
       <?rfc strict="yes"?>
       <?rfc compact="yes"?>
       <?rfc subcompact="no"?>
       <?rfc tocdepth="4"?>
       <?rfc symrefs="yes"?>
       <?rfc sortrefs="yes"?>
       <rfc xmlns:xi="http://www.w3.org/2001/XInclude" number="10" category="std" ipr="trust200902" submissionType="IETF" version="3">
         <front>
           <title>The Holy Hand Grenade of Antioch</title>
           <seriesInfo value="10" name="RFC" asciiName="RFC"/>
           <author fullname="Arthur son of Uther Pendragon"/>
           <date day="1" year="2000" month="January"/>
         </front>
         <middle>
           <section anchor="F">
             <name>Foreword</name>
             <sourcecode anchor="S" type="ruby" name="sourcecode1.rb" markers="true"><![CDATA[                puts "Hello, world." %w{a b c}.each do |x| puts x end
                       RFC 4918, Section 
                       Hello
                       RFC 4918, Section 14.24
                       Hello
                       http://www.example.com
                       example
                       Bibliography
                       Goodbye
                    ]]></sourcecode>
           </section>
         </middle>
         <back>
           <references anchor="A">
             <name>Bibliography</name>
             <reference anchor="RFC4918">
               <front>
                 <title>[NO INFORMATION AVAILABLE]</title>
                 <author surname="Unknown"/>
               </front>
             </reference>
           </references>
         </back>
       </rfc>
    OUTPUT
    IsoDoc::Ietf::RfcConvert.new({}).convert("test", input, false)
    expect(File.read("test.rfc.xml"))
      .to be_xml_equivalent_to output
  end

  it "cleans up annotated bibliography" do
    input = <<~INPUT
      <rfc xmlns:xi='http://www.w3.org/2001/XInclude' xml:lang='en' version='3'>
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
    output = <<~OUTPUT
      <rfc xmlns:xi="http://www.w3.org/2001/XInclude" xml:lang="en" version="3">
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
                     <author fullname="Ölaf Nürk" asciiFullname="Olaf Nurk" surname="Nürk" asciiSurname="Nurk"/>
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
      #{'             '}
                     Determination of the protein content in cereal and cereal products
                     for food and animal feeding stuffs according to the Dumas
                     combustion method
      #{'             '}
                    (see
                   http://www.icc.or.at
                   )
                 </title>
                     <author surname="Unknown"/>
                  </front>
                  <annotation>
               NOTE: This is an annotation of ISO 20483:2013-2014
             </annotation>
               </reference>
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
             </annotation>
                  <annotation>
               NOTE: This is another annotation of document ISSN.
             </annotation>
               </reference>
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
      #{'             '}
                     Determination of the protein content in cereal and cereal products
                     for food and animal feeding stuffs according to the Dumas
                     combustion method
      #{'             '}
                    (see
                   http://www.icc.or.at
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
    expect(IsoDoc::Ietf::RfcConvert.new({})
      .cleanup(Nokogiri::XML(input)).to_s)
      .to be_xml_equivalent_to output
  end

  it "cleans up definition lists" do
    input = <<~INPUT
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
    output = <<~OUTPUT
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
    expect(IsoDoc::Ietf::RfcConvert.new({})
      .cleanup(Nokogiri::XML(input)).to_s)
      .to be_xml_equivalent_to output
  end

  it "reports parsing errors on RFC XML output" do
    FileUtils.rm_f "test.rfc.xml"
    input = <<~INPUT
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
    expect do
      IsoDoc::Ietf::RfcConvert.new({})
        .convert("test", input, false)
    end.to output(/RFC XML: Line/).to_stderr
  end

  it "inserts u tags to wrap unicode" do
    input = <<~INPUT
      <rfc xmlns:xi='http://www.w3.org/2001/XInclude' version='3'>
               <front>
                 <abstract>
                 <author>Hello &lt;"Χello</author>
                 <t>Hello &lt;"Χello</t>
                 </abstract>
               </front>
               <middle/>
               <back/>
             </rfc>
    INPUT
    output = <<~OUTPUT
      <rfc xmlns:xi='http://www.w3.org/2001/XInclude' version='3'>
      <front>
      <abstract>
      <author>
        Hello &lt;"&#x3A7;ello
      </author>
      <t>
        Hello
        &lt;"<u>&#x3A7;</u>
        ello
      </t>
      </abstract> </front> <middle/> <back/> </rfc>
    OUTPUT
    expect(IsoDoc::Ietf::RfcConvert.new({})
      .cleanup(Nokogiri::XML(input)).to_s)
      .to be_xml_equivalent_to output
  end

  it "cleans up lists with single paragraphs" do
    input = <<~INPUT
      <rfc xmlns:xi='http://www.w3.org/2001/XInclude' version='3'>
               <front>
                 <abstract>
                 <ol>
                 <li><t>ABC</t></li>
                 <li><t>DEF</t><t>GHI</t></li>
                 <li><figure>A</figure></li>
                 <li>JKL</li>
                 </ol>
                 </abstract>
               </front>
               <middle/>
               <back/>
             </rfc>
    INPUT
    output = <<~OUTPUT
      <rfc xmlns:xi='http://www.w3.org/2001/XInclude' version='3'>
      <front>
      <abstract>
      <ol>
        <li>ABC</li>
        <li>
          <t>DEF</t>
          <t>GHI</t>
        </li>
        <li>
          <figure>A</figure>
        </li>
        <li>JKL</li>
      </ol>
      </abstract> </front> <middle/> <back/> </rfc>
    OUTPUT
    expect(IsoDoc::Ietf::RfcConvert.new({})
      .cleanup(Nokogiri::XML(input)).to_s)
      .to be_xml_equivalent_to output
  end

  it "cleans up crefs" do
    input = <<~INPUT
         <rfc xmlns:xi='http://www.w3.org/2001/XInclude' category='std' submissionType='IETF' version='3'>
         <front>
            <seriesInfo value="" name="RFC" asciiName="RFC"/>
            <abstract anchor="_">
               <t anchor="A">A.</t>
               <t anchor="B">B.</t>
               <bookmark anchor="C"/>
               <t>C.</t>
            </abstract>
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
    INPUT
    output = <<~OUTPUT
      <rfc xmlns:xi="http://www.w3.org/2001/XInclude" category="std" submissionType="IETF" version="3">
         <front>
            <seriesInfo value="" name="RFC" asciiName="RFC"/>
            <abstract anchor="_">
               <t anchor="A">
                  <cref anchor="_" display="false" source="ISO">
                     Title A Foreword shall appear in each document. The generic text is shown here. It does not contain requirements, recommendations or permissions. For further information on the Foreword, see
                     <strong>ISO/IEC Directives, Part 2, 2016, Clause 12.</strong>
                  </cref>
                  <cref anchor="_" source="ISO">
               Second note.
            </cref>
                  A.
               </t>
               <t anchor="B">B.</t>
               <t>
                  <cref anchor="_" source="ISO">
               Third note.
            </cref>
               </t>
               <t>C.</t>
            </abstract>
         </front>
         <middle/>
         <back>
      #{'      '}
      #{'      '}
      #{'      '}
         </back>
      </rfc>
    OUTPUT
    expect(IsoDoc::Ietf::RfcConvert.new({})
      .cleanup(Nokogiri::XML(input)).to_s)
      .to be_xml_equivalent_to output
  end
end
