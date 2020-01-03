require "spec_helper"

RSpec.describe IsoDoc::Ietf do
  it "processes IsoXML bibliographies" do
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <bibdata>
    </bibdata>
    <preface><foreword>
  <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">
  <eref bibitemid="ISO712"/>
  <eref bibitemid="ISBN"/>
  <eref bibitemid="ISSN"/>
  <eref bibitemid="ISO16634"/>
  <eref bibitemid="ref1"/>
  <eref bibitemid="ref10"/>
  <eref bibitemid="ref12"/>
  </p>
    </foreword></preface>
    <bibliography><references id="_normative_references" obligation="informative"><title>Normative References</title>
<bibitem id="ISO712" type="standard">
  <title format="text/plain">Cereals or cereal products</title>
  <title type="main" format="text/plain">Cereals and cereal products</title>
  <uri>http://www.example.com</uri>
  <docidentifier type="ISO">ISO 712</docidentifier>
  <contributor>
    <role type="publisher"/>
    <organization>
      <name>International Organization for Standardization</name>
    </organization>
  </contributor>
</bibitem>
<bibitem id="ISO16634" type="standard">
  <title language="x" format="text/plain">Cereals, pulses, milled cereal products, xxxx, oilseeds and animal feeding stuffs</title>
  <title language="en" format="text/plain">Cereals, pulses, milled cereal products, oilseeds and animal feeding stuffs</title>
  <uri>http://www.example.com</uri>
  <uri type="RDF">http://www.example.com/rdf</uri>
  <docidentifier type="ISO">ISO 16634:-- (all parts)</docidentifier>
  <date type="published"><on>--</on></date>
  <contributor>
    <role type="publisher"/>
    <organization>
      <abbreviation>ISO</abbreviation>
    </organization>
  </contributor>
  <contributor>
    <role type="editor"/>
    <organization>
      <name>International Supporters of Odium</name>
      <abbreviation>ISO1</abbreviation>
    </organization>
  </contributor>
  <keyword>keyword1</keyword>
  <keyword>keyword2</keyword>
  <abstract><p>This is an abstract</p></abstract>
  <note format="text/plain" reference="1">ISO DATE: Under preparation. (Stage at the time of publication ISO/DIS 16634)</note>
  <extent type="part">
  <referenceFrom>all</referenceFrom>
  </extent>

</bibitem>
<bibitem id="ISO20483" type="standard">
  <title format="text/plain">Cereals and pulses</title>
  <docidentifier type="ISO">ISO 20483:2013-2014</docidentifier>
  <date type="published"><from>2013</from><to>2014</to></date>
  <contributor>
    <role type="publisher"/>
    <organization>
      <name>International Organization for Standardization</name>
    </organization>
  </contributor>
  <contributor>
  <role type="author"/>
  <person>
  <name><completename>Ölaf Nürk</ompletename>
  <surname>Nürk</surname>
  <forename>Ölaf</forename>
  </name>
  </person>
</contributor>
<contributor>
  <role type="author"/>
  <person>
  <surname>Citizen</surname>
  <initial>A.</initial>
  <initial>B.</initial>
  </person>
</contributor>
</bibitem>
<bibitem id="ref1">
  <formattedref format="application/x-isodoc+xml"><smallcap>Standard No I.C.C 167</smallcap>. <em>Determination of the protein content in cereal and cereal products for food and animal feeding stuffs according to the Dumas combustion method</em> (see <link target="http://www.icc.or.at"/>)</formattedref>
  <docidentifier type="ICC">167</docidentifier>
</bibitem>
<note><p>This is an annotation of ISO 20483:2013-2014</p></note>

</references><references id="_bibliography" obligation="informative">
  <title>Bibliography</title>
<bibitem id="ISBN" type="ISBN">
  <title format="text/plain">Chemicals for analytical laboratory use</title>
  <docidentifier type="ISBN">ISBN</docidentifier>
  <docidentifier type="metanorma">[1]</docidentifier>
  <contributor>
    <role type="publisher"/>
    <organization>
      <abbreviation>ISBN</abbreviation>
    </organization>
  </contributor>
</bibitem>
<bibitem id="ISSN" type="ISSN">
  <title format="text/plain">Instruments for analytical laboratory use</title>
  <docidentifier type="ISSN">ISSN</docidentifier>
  <docidentifier type="metanorma">[2]</docidentifier>
  <contributor>
    <role type="publisher"/>
    <organization>
      <abbreviation>ISSN</abbreviation>
    </organization>
  </contributor>
</bibitem>
<note><p>This is an annotation of document ISSN.</p></note>
<note><p>This is another annotation of document ISSN.</p></note>
<bibitem id="ISO3696" type="standard">
  <title format="text/plain">Water for analytical laboratory use</title>
  <docidentifier type="ISO">ISO 3696</docidentifier>
  <contributor>
    <role type="publisher"/>
    <organization>
    <name>International Standards Organization</name>
      <abbreviation>ISO</abbreviation>
    </organization>
  </contributor>
</bibitem>
<bibitem id="ref10">
  <formattedref format="application/x-isodoc+xml"><smallcap>Standard No I.C.C 167</smallcap>. <em>Determination of the protein content in cereal and cereal products for food and animal feeding stuffs according to the Dumas combustion method</em> (see <link target="http://www.icc.or.at"/>)</formattedref>
  <docidentifier type="metanorma">[10]</docidentifier>
</bibitem>
<bibitem id="ref11">
  <title>Internet Calendaring and Scheduling Core Object Specification (iCalendar)</title>
  <docidentifier type="IETF">RFC 10</docidentifier>
  <uri type="xml">https://xml2rfc.tools.ietf.org/10.xml</uri>
</bibitem>
<bibitem id="ref12">
  <formattedref format="application/x-isodoc+xml">CitationWorks. 2019. <em>How to cite a reference</em>.</formattedref>
  <docidentifier type="metanorma">[Citn]</docidentifier>
</bibitem>


</references>
</bibliography>
    </iso-standard>
    INPUT
           #{XML_HDR}
             <t anchor='_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f'>
               <relref target='ISO712'  section=''/>
               <relref target='ISBN'  section=''/>
               <relref target='ISSN'  section=''/>
               <relref target='ISO16634'  section=''/>
               <relref target='ref1'  section=''/>
               <relref target='ref10'  section=''/>
               <relref target='ref12'  section=''/>
             </t>
           </abstract>
         </front>
         <middle/>
         <back>
           <references anchor='_normative_references'>
             <name>Normative References</name>
             <reference target='http://www.example.com' anchor='ISO712'>
               <front>
                 <title>ISO 712, Cereals or cereal products</title>
                 <author>
  <organization ascii='International Organization for Standardization'>International Organization for Standardization</organization>
</author>
               </front>
             </reference>
             <reference target='http://www.example.com' anchor='ISO16634'>
               <front>
                 <title>
                   ISO 16634:-- (all parts), Cereals, pulses, milled cereal products,
                   xxxx, oilseeds and animal feeding stuffs
                 </title>
                 <author>
                   <organization ascii='International Supporters of Odium' abbrev='ISO1'>International Supporters of Odium</organization>
                 </author>
                 <keyword>keyword1</keyword>
                 <keyword>keyword2</keyword>
                 <abstract>
                   <t>This is an abstract</t>
                 </abstract>
               </front>
               <format target='http://www.example.com/rdf' type='RDF'/>
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
                 <author>
  <organization abbrev='ISBN'/>
</author>
               </front>
             </reference>
             <reference anchor='ISSN'>
               <front>
                 <title>2, Instruments for analytical laboratory use</title>
               <author>
  <organization abbrev='ISSN'/>
</author>
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
               <author>
               <organization ascii='International Standards Organization' abbrev='ISO'>International Standards Organization</organization>
</author>
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
    OUTPUT
  end

end
