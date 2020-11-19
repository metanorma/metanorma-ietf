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
    <bibliography><references id="_normative_references" obligation="informative"  normative="true"><title>Normative References</title>
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
  <docidentifier type="DOI">1234</docidentifier>
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
  <abstract>This is an abstract</abstract>
</bibitem>
<bibitem id="ref1">
  <formattedref format="application/x-isodoc+xml"><smallcap>Standard No I.C.C 167</smallcap>. <em>Determination of the protein content in cereal and cereal products for food and animal feeding stuffs according to the Dumas combustion method</em> (see <link target="http://www.icc.or.at"/>)</formattedref>
  <docidentifier type="ICC">167</docidentifier>
</bibitem>
<note><p>This is an annotation of ISO 20483:2013-2014</p></note>

</references><references id="_bibliography" obligation="informative" normative="false">
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
               <relref target='ISO712' section='' relative=''/>
               <relref target='ISBN' section='' relative=''/>
               <relref target='ISSN' section='' relative=''/>
               <relref target='ISO16634' section='' relative=''/>
               <relref target='ref1' section='' relative=''/>
               <relref target='ref10' section='' relative=''/>
               <relref target='ref12' section='' relative=''/>
             </t>
           </abstract>
         </front>
         <middle/>
         <back>
           <references anchor='_normative_references'>
             <name>Normative References</name>
             <reference anchor='ISO712'>
               <front>
                 <title>Cereals or cereal products</title>
                 <author>
                   <organization ascii='International Organization for Standardization'>International Organization for Standardization</organization>
                 </author>
               </front>
               <format target='http://www.example.com'/>
               <refcontent>ISO 712</refcontent>
             </reference>
             <reference anchor='ISO16634'>
               <front>
                 <title>
                   Cereals, pulses, milled cereal products, xxxx, oilseeds and animal
                   feeding stuffs
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
               <format target='http://www.example.com'/>
               <format target='http://www.example.com/rdf' type='RDF'/>
               <refcontent>ISO 16634:-- (all parts)</refcontent>
<seriesInfo value='1234' name='DOI'/>
             </reference>
             <reference anchor='ISO20483'>
               <front>
                 <title>Cereals and pulses</title>
                 <author fullname='&#xD6;laf N&#xFC;rk' asciiFullname='Olaf Nurk' surname='N&#xFC;rk' asciiSurname='Nurk'/>
                 <author>
                   <organization/>
                 </author>
                 <date year='2013'/>
                 <abstract>
                   <t>This is an abstract</t>
                 </abstract>
               </front>
               <refcontent>ISO 20483:2013-2014</refcontent>
             </reference>
             <reference anchor='ref1'>
               <front>
                 <title>
                   Standard No I.C.C 167.
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
               <refcontent>ICC 167</refcontent>
             </reference>
             <aside>
               <t>NOTE: This is an annotation of ISO 20483:2013-2014</t>
             </aside>
           </references>
           <references anchor='_bibliography'>
             <name>Bibliography</name>
             <reference anchor='ISBN'>
               <front>
                 <title>Chemicals for analytical laboratory use</title>
                 <author>
                   <organization abbrev='ISBN'/>
                 </author>
               </front>
             </reference>
             <reference anchor='ISSN'>
               <front>
                 <title>Instruments for analytical laboratory use</title>
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
                 <title>Water for analytical laboratory use</title>
                 <author>
                   <organization ascii='International Standards Organization' abbrev='ISO'>International Standards Organization</organization>
                 </author>
               </front>
               <refcontent>ISO 3696</refcontent>
             </reference>
             <reference anchor='ref10'>
               <front>
                 <title>
                   Standard No I.C.C 167.
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
             <reference anchor='ref11'>
               <front>
                 <title>Internet Calendaring and Scheduling Core Object Specification (iCalendar)</title>
               </front>
               <format target='https://xml2rfc.tools.ietf.org/10.xml' type='xml'/>
               <refcontent>IETF RFC 10</refcontent>
               <seriesInfo value='RFC 10' name='IETF'/>
             </reference>
             <reference anchor='ref12'>
               <front>
                 <title>
                   CitationWorks. 2019.
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

  it "processes IsoXML bibliographies with xincludes" do
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({use_xinclude: "true"}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
    <bibliography><references id="_normative_references" obligation="informative" normative="true"><title>Normative References</title>
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
  <docidentifier type="DOI">1234</docidentifier>
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
  <abstract>This is an abstract</abstract>
</bibitem>
<bibitem id="ref1">
  <formattedref format="application/x-isodoc+xml"><smallcap>Standard No I.C.C 167</smallcap>. <em>Determination of the protein content in cereal and cereal products for food and animal feeding stuffs according to the Dumas combustion method</em> (see <link target="http://www.icc.or.at"/>)</formattedref>
  <docidentifier type="ICC">167</docidentifier>
</bibitem>
<note><p>This is an annotation of ISO 20483:2013-2014</p></note>

</references><references id="_bibliography" obligation="informative" normative="false">
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
               <relref target='ISO712'  section='' relative=''/>
               <relref target='ISBN'  section='' relative=''/>
               <relref target='ISSN'  section='' relative=''/>
               <relref target='ISO16634'  section='' relative=''/>
               <relref target='ref1'  section='' relative=''/>
               <relref target='ref10'  section='' relative=''/>
               <relref target='ref12'  section='' relative=''/>
             </t>
           </abstract>
         </front>
         <middle/>
         <back>
           <references anchor='_normative_references'>
             <name>Normative References</name>
             <reference anchor='ISO712'>
               <front>
                 <title>Cereals or cereal products</title>
                 <author>
                   <organization ascii='International Organization for Standardization'>International Organization for Standardization</organization>
                 </author>
               </front>
               <format target='http://www.example.com'/>
               <refcontent>ISO 712</refcontent>
             </reference>
             <reference anchor='ISO16634'>
               <front>
                 <title>
                   Cereals, pulses, milled cereal products, xxxx, oilseeds and animal
                   feeding stuffs
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
               <format target='http://www.example.com'/>
               <format target='http://www.example.com/rdf' type='RDF'/>
               <refcontent>ISO 16634:-- (all parts)</refcontent>
<seriesInfo value='1234' name='DOI'/>
             </reference>
             <reference anchor='ISO20483'>
               <front>
                 <title>Cereals and pulses</title>
                 <author fullname='&#xD6;laf N&#xFC;rk' asciiFullname='Olaf Nurk' surname='N&#xFC;rk' asciiSurname='Nurk'/>
                 <author>
                   <organization/>
                 </author>
                 <date year='2013'/>
                 <abstract>
                   <t>This is an abstract</t>
                 </abstract>
               </front>
               <refcontent>ISO 20483:2013-2014</refcontent>
             </reference>
             <reference anchor='ref1'>
               <front>
                 <title>
                   Standard No I.C.C 167.
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
               <refcontent>ICC 167</refcontent>
             </reference>
             <aside>
               <t>NOTE: This is an annotation of ISO 20483:2013-2014</t>
             </aside>
           </references>
           <references anchor='_bibliography'>
             <name>Bibliography</name>
             <reference anchor='ISBN'>
               <front>
                 <title>Chemicals for analytical laboratory use</title>
                 <author>
                   <organization abbrev='ISBN'/>
                 </author>
               </front>
             </reference>
             <reference anchor='ISSN'>
               <front>
                 <title>Instruments for analytical laboratory use</title>
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
                 <title>Water for analytical laboratory use</title>
                 <author>
                   <organization ascii='International Standards Organization' abbrev='ISO'>International Standards Organization</organization>
                 </author>
               </front>
               <refcontent>ISO 3696</refcontent>
             </reference>
             <reference anchor='ref10'>
               <front>
                 <title>
                   Standard No I.C.C 167.
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
                   CitationWorks. 2019.
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

    it "processes nested bibliographies" do
          expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
<ietf-standard  xmlns="http://riboseinc.com/isoxml">
<sections><clause id="_clause" inline-header="false" obligation="normative">
<title>Clause</title>
<p id="_c401175c-2d9b-4758-ba27-d4f50ddb062a">A</p>
</clause>
<clause id="_references" inline-header="false" obligation="normative"><title>References</title><references id="_normative_references" normative="true" obligation="informative">
<title>Normative references</title>
<bibitem id="A">
<formattedref format="application/x-isodoc+xml">X</formattedref>
<docidentifier>B</docidentifier>

</bibitem>
</references>
<references id="_informative_references" normative="false" obligation="informative">
<title>Bibliography</title><bibitem id="C">
<formattedref format="application/x-isodoc+xml">Y</formattedref>
<docidentifier>D</docidentifier>

</bibitem>

</references></clause>
<clause id="_references_2" inline-header="false" obligation="normative"><title>References 2</title><p id="_849e5255-ca89-4667-b517-743ab74a032e">Z</p>
<references id="_normative_references_2" normative="false" obligation="informative">
<title>Normative References</title><bibitem id="E">
<formattedref format="application/x-isodoc+xml">X</formattedref>
<docidentifier>F</docidentifier>

</bibitem>

</references>
<references id="_informative_references_2" normative="false" obligation="informative">
<title>Informative References</title><bibitem id="G">
<formattedref format="application/x-isodoc+xml">Y</formattedref>
<docidentifier>H</docidentifier>

</bibitem>

</references></clause></sections>
</ietf-standard>
INPUT
<?xml version='1.0'?>
       <?rfc strict="yes"?>
       <?rfc compact="yes"?>
       <?rfc subcompact="no"?>
       <?rfc tocdepth="4"?>
       <?rfc symrefs="yes"?>
       <?rfc sortrefs="yes"?>
       <rfc xmlns:xi='http://www.w3.org/2001/XInclude' category='std' submissionType='IETF' version='3'>
         <front>
           <seriesInfo value='' name='RFC' asciiName='RFC'/>
         </front>
         <middle>
           <section anchor='_clause'>
             <name>Clause</name>
             <t anchor='_c401175c-2d9b-4758-ba27-d4f50ddb062a'>A</t>
           </section>
           <section anchor='_references_2'>
             <name>References 2</name>
             <t anchor='_849e5255-ca89-4667-b517-743ab74a032e'>Z</t>
           </section>
         </middle>
         <back>
           <references anchor='_normative_references'>
             <name>Normative references</name>
             <reference anchor='A'>
               <front>
                 <title>X</title>
               </front>
               <refcontent>B</refcontent>
             </reference>
           </references>
           <references anchor='_informative_references'>
             <name>Bibliography</name>
             <reference anchor='C'>
               <front>
                 <title>Y</title>
               </front>
               <refcontent>D</refcontent>
             </reference>
           </references>
           <references anchor='_normative_references_2'>
             <name>Normative References</name>
             <reference anchor='E'>
               <front>
                 <title>X</title>
               </front>
               <refcontent>F</refcontent>
             </reference>
           </references>
           <references anchor='_informative_references_2'>
             <name>Informative References</name>
             <reference anchor='G'>
               <front>
                 <title>Y</title>
               </front>
               <refcontent>H</refcontent>
             </reference>
           </references>
         </back>
       </rfc>
OUTPUT
    end

end
