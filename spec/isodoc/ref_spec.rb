require "spec_helper"

RSpec.describe IsoDoc::Ietf do
  it "processes IsoXML bibliographies" do
    FileUtils.rm_f "test.rfc.xml"
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata>
          <title language="en" format="text/plain" type="main">The Holy Hand Grenade of Antioch</title>
          <docidentifier>draft-camelot-holy-grenade-01</docidentifier><docnumber>10</docnumber><contributor><role type="author"/><person>
          <name><completename>Arthur son of Uther Pendragon</completename></name></person></contributor>
          <ext><ipr>trust200902</ipr></ext>
          </bibdata>
          <preface><foreword>
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">
        <eref bibitemid="ISO712"/>
        <eref bibitemid="ISBN"/>
        <eref bibitemid="ISSN"/>
        <eref bibitemid="ISO16634"/>
        <eref bibitemid="ref11"/>
        </p>
          </foreword></preface>
          <sections><clause id="A"><title>A-title</title><p>A</p></clause></sections>
          <bibliography><references id="_normative_references" obligation="informative"  normative="true"><title>Normative References</title>
          <bibitem id="RFC2119" type="standard" schema-version="v1.2.4">  <fetched>2023-11-06</fetched>
          <title type="main" format="text/plain">Key words for use in RFCs to Indicate Requirement Levels</title>
            <uri type="src">https://www.rfc-editor.org/info/rfc2119</uri>  <docidentifier type="IETF" primary="true">RFC 2119</docidentifier>  <docidentifier type="DOI">10.17487/RFC2119</docidentifier>  <docnumber>RFC2119</docnumber>  <date type="published">    <on>1997-03</on>  </date>  <contributor>    <role type="author"/>    <person>
          <name>        <completename language="en" script="Latn">S. Bradner</completename>      </name>
              </person>  </contributor>  <contributor>    <role type="publisher"/>    <organization>
          <name>RFC Publisher</name>
              </organization>  </contributor>  <contributor>    <role type="authorizer"/>    <organization>
          <name>RFC Series</name>
              </organization>  </contributor>  <language>en</language>  <script>Latn</script>  <abstract format="text/html" language="en" script="Latn">    <p id="_349eae68-a8a3-0c01-e665-a6dc84c36d2e">In many standards track documents several words are used to signify the requirements in the specification. These words are often capitalized. This document defines these words as they should be interpreted in IETF documents. This document specifies an Internet Best Current Practices for the Internet Community, and requests discussion and suggestions for improvements.</p>
            </abstract>  <series>
          <title format="text/plain">BCP</title>
              <number>14</number>  </series>  <series>
          <title format="text/plain">RFC</title>
              <number>2119</number>  </series>  <series type="stream">
          <title format="text/plain">IETF</title>
            </series>  <keyword>Standards</keyword>  <keyword>Track</keyword>  <keyword>Documents</keyword></bibitem>
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
        <role type="editor"/>
        <person>
        <name>
        <surname>Citizen</surname>
        <formatted-initials>A. B.</formatted-initials>
        </name>
        </person>
      </contributor>
        <abstract>This is an abstract</abstract>
      </bibitem>

      <bibitem id="ISO20484" type="standard">
        <title format="text/plain">Cereals and pulses II</title>
        <docidentifier type="ISO">ISO 20484:2013-2014</docidentifier>
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
        <name>
        <surname>Citizen</surname>
        <formatted-initials>A. B.</formatted-initials>
        </name>
        </person>
      </contributor>
      <contributor>
        <role type="editor"/>
        <person>
        <name>
        <surname>Third</surname>
        <formatted-initials>Th.</formatted-initials>
        </name>
        </person>
      </contributor>
        <abstract>This is an abstract</abstract>
      </bibitem>


      </references><references id="_bibliography" obligation="informative" normative="false">
        <title>Bibliography</title>
      <bibitem id="ISBN" type="book">
        <title format="text/plain">Chemicals for analytical laboratory use</title>
        <docidentifier type="ISBN">ISBN</docidentifier>
        <docidentifier type="metanorma">[1]</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>International SBN</name>
            <abbreviation>ISBN</abbreviation>
          </organization>
        </contributor>
      </bibitem>
      <bibitem id="ISSN" type="journal">
        <title format="text/plain">Instruments for analytical laboratory use</title>
        <docidentifier type="ISSN">ISSN</docidentifier>
        <docidentifier type="metanorma">[2]</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>International SSN</name>
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
      <bibitem id="ref11">
        <title>Internet Calendaring and Scheduling Core Object Specification (iCalendar)</title>
        <docidentifier type="IETF">RFC 10</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
          <name>Internet Engineering Task Force</name>
            <abbreviation>IETF</abbreviation>
          </organization>
        </contributor>
        <uri type="xml">https://xml2rfc.tools.ietf.org/10.xml</uri>
      </bibitem>
      <bibitem id="I-D.aboba-context-802" type="standard">  <fetched>2021-09-19</fetched>  <title format="text/plain" language="en" script="Latn">A Model for Context Transfer in IEEE 802</title>  <uri type="xml">https://raw.githubusercontent.com/relaton/relaton-data-ietf/master/data/reference.I-D.aboba-context-802.xml</uri>  <uri type="TXT">http://www.ietf.org/internet-drafts/draft-aboba-context-802-00.txt</uri>  <docidentifier type="IETF">I-D.aboba-context-802</docidentifier>  <docidentifier type="rfc-anchor">I-D.aboba-context-802</docidentifier>  <docidentifier type="Internet-Draft">draft-aboba-context-802-00</docidentifier>  <date type="published">    <on>2003-10</on>  </date>  <contributor>    <role type="author"/>    <person>      <name>        <completename language="en">Bernard Aboba</completename>      </name>      <affiliation>        <organization>          <name>Internet Engineering Task Force</name>          <abbreviation>IETF</abbreviation>        </organization>      </affiliation>    </person>  </contributor>  <contributor>    <role type="publisher"/>    <organization>      <name>Internet Engineering Task Force</name>      <abbreviation>IETF</abbreviation>    </organization>  </contributor>  <language>en</language>  <script>Latn</script>  <series type="main">    <title format="text/plain" language="en" script="Latn">Internet-Draft</title>    <number>draft-aboba-context-802-00</number>  </series>  <place>Fremont, CA</place></bibitem>
      </references>
      </bibliography>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
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
          <author fullname="Arthur son of Uther Pendragon">
            <address>
              <postal/>
              <email/>
              <uri/>
            </address>
          </author>
          <abstract>
            <t anchor="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">
              <relref target="ISO712" section="" relative=""/>
              <relref target="ISBN" section="" relative=""/>
              <relref target="ISSN" section="" relative=""/>
              <relref target="ISO16634" section="" relative=""/>
              <relref target="ref11" section="" relative=""/>
            </t>
          </abstract>
        </front>
        <middle>
          <section anchor="A">
            <name>A-title</name>
            <t>A</t>
          </section>
        </middle>
        <back>
          <references anchor='_normative_references'>
            <name>Normative References</name>
               <reference target="https://www.rfc-editor.org/info/rfc2119" anchor="RFC2119">
               <front>
                 <title>Key words for use in RFCs to Indicate Requirement Levels</title>
                 <author fullname="S. Bradner" asciiFullname="S. Bradner"/>
                 <date month="March" year="1997"/>
                 <keyword>Standards</keyword>
                 <keyword>Track</keyword>
                 <keyword>Documents</keyword>
                 <abstract>
                   <t anchor="_349eae68-a8a3-0c01-e665-a6dc84c36d2e">In many standards track documents several words are used to signify the requirements in the specification. These words are often capitalized. This document defines these words as they should be interpreted in IETF documents. This document specifies an Internet Best Current Practices for the Internet Community, and requests discussion and suggestions for improvements.</t>
                 </abstract>
               </front>
               <format target="https://www.rfc-editor.org/info/rfc2119" type="src"/>
               <seriesInfo value=" 10.17487/RFC2119" name="DOI"/>
               <seriesInfo value="14" name="BCP"/>
              <seriesInfo value="2119" name="RFC"/>
             </reference>
            <reference anchor='ISO712'>
              <front>
                <title>Cereals and cereal products</title>
                <author>
                  <organization ascii='International Organization for Standardization'>International Organization for Standardization</organization>
                </author>
              </front>
              <format target='http://www.example.com' type="HTML"/>
              <refcontent>ISO&#xa0;712</refcontent>
            </reference>
            <reference anchor='ISO16634'>
              <front>
                <title>
                  Cereals, pulses, milled cereal products, oilseeds and animal
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
              <format target='http://www.example.com' type='HTML'/>
              <format target='http://www.example.com/rdf' type='RDF'/>
             <seriesInfo value='1234' name='DOI'/>
              <refcontent>ISO 16634:-- (all parts)</refcontent>
            </reference>
            <reference anchor='ISO20483'>
              <front>
                <title>Cereals and pulses</title>
                <author surname='N&#xFC;rk' asciiSurname='Nurk' initials="Ö." asciiInitials="O."/>
                <author surname="Citizen" asciiSurname="Citizen" initials="A.B." asciiInitials="A.B."/>
                <date year='2013'/>
                <abstract>
                  <t>This is an abstract</t>
                </abstract>
              </front>
              <refcontent>ISO&#xa0;20483:2013-2014</refcontent>
            </reference>
            <reference anchor="ISO20484">
              <front><title>Cereals and pulses II</title>
               <author surname="Nürk" asciiSurname="Nurk" initials="Ö." asciiInitials="O."/>
               <author surname="Citizen" asciiSurname="Citizen" initials="A.B." asciiInitials="A.B."/>
               <author surname="Third" asciiSurname="Third" initials="Th." asciiInitials="Th."/>
               <date year="2013"/><abstract><t>This is an abstract</t></abstract></front>
              <refcontent>ISO 20484:2013-2014</refcontent>
            </reference>

          </references>
          <references anchor='_bibliography'>
            <name>Bibliography</name>
            <reference anchor='ISBN'>
              <front>
                <title>Chemicals for analytical laboratory use</title>
                <author>
                  <organization ascii="International SBN" abbrev="ISBN">International SBN</organization>
                </author>
              </front>
            </reference>
            <reference anchor='ISSN'>
              <front>
                <title>Instruments for analytical laboratory use</title>
                <author>
                  <organization ascii="International SSN" abbrev="ISSN">International SSN</organization>
                </author>
              </front>
            <annotation>
              NOTE: This is an annotation of document ISSN.
            </annotation>
            <annotation>
              NOTE: This is another annotation of document ISSN.
            </annotation>
            </reference>
            <reference anchor='ISO3696'>
              <front>
                <title>Water for analytical laboratory use</title>
                <author>
                  <organization ascii='International Standards Organization' abbrev='ISO'>International Standards Organization</organization>
                </author>
              </front>
              <refcontent>ISO&#xa0;3696</refcontent>
            </reference>
            <reference anchor='ref11'>
              <front>
                <title>Internet Calendaring and Scheduling Core Object Specification (iCalendar)</title>
                <author>
               <organization ascii="Internet Engineering Task Force" abbrev="IETF">Internet Engineering Task Force</organization>
             </author>
              </front>
              <format target='https://xml2rfc.tools.ietf.org/10.xml' type='xml'/>
              <seriesInfo value='10' name='RFC'/>
            </reference>
            <reference anchor='I-D.aboba-context-802'>
              <front>
                <title>A Model for Context Transfer in IEEE 802</title>
                <author fullname='Bernard Aboba' asciiFullname='Bernard Aboba'/>
                <date month='October' year='2003'/>
              </front>
              <format target='https://raw.githubusercontent.com/relaton/relaton-data-ietf/master/data/reference.I-D.aboba-context-802.xml' type='xml'/>
              <format target='http://www.ietf.org/internet-drafts/draft-aboba-context-802-00.txt' type='TXT'/>
              <seriesInfo value='aboba-context-802' name='Internet-Draft'/>
            </reference>
          </references>
        </back>
      </rfc>

    OUTPUT
    IsoDoc::Ietf::RfcConvert.new({})
      .convert("test", input, false)
    expect(File.exist?("test.rfc.xml")).to be true
    xml = File.read("test.rfc.xml")
    expect(xmlpp(xml)).to be_equivalent_to xmlpp(output)
  end

  it "processes IsoXML bibliographies with xincludes" do
    FileUtils.rm_f "test.rfc.xml"
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
              <bibdata>
          <title language="en" format="text/plain" type="main">The Holy Hand Grenade of Antioch</title>
          <docidentifier>draft-camelot-holy-grenade-01</docidentifier><docnumber>10</docnumber><contributor><role type="author"/><person>
          <name><completename>Arthur son of Uther Pendragon</completename></name></person></contributor>
          <ext><ipr>trust200902</ipr></ext>
          </bibdata>
          <preface><foreword>
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">
        <eref bibitemid="ISO712"/>
        <eref bibitemid="ISBN"/>
        <eref bibitemid="ISSN"/>
        <eref bibitemid="ISO16634"/>
        <eref bibitemid="ref11"/>
        </p>
          </foreword></preface>
          <sections><clause id="A"><title>A-title</title><p>A</p></clause></sections>
          <bibliography><references id="_normative_references" obligation="informative" normative="true"><title>Normative References</title>
      <bibitem id="ISO712" type="standard">
        <title format="text/plain">Cereals or cereal products</title>
        <title type="main" format="text/plain">Cereals and cereal products</title>
        <uri>http://www.example.com</uri>
        <docidentifier type="ISO">ISO&#xa0;712</docidentifier>
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
        <name>
        <surname>Citizen</surname>
        <formatted-initials>A. B.</formatted-initials>
        </name>
        </person>
      </contributor>
        <abstract>This is an abstract</abstract>
      </bibitem>

      </references><references id="_bibliography" obligation="informative" normative="false">
        <title>Bibliography</title>
      <bibitem id="ISBN" type="book">
        <title format="text/plain">Chemicals for analytical laboratory use</title>
        <docidentifier type="ISBN">ISBN</docidentifier>
        <docidentifier type="metanorma">[1]</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>International SBN</name>
            <abbreviation>ISBN</abbreviation>
          </organization>
        </contributor>
      </bibitem>
      <bibitem id="ISSN" type="journal">
        <title format="text/plain">Instruments for analytical laboratory use</title>
        <docidentifier type="ISSN">ISSN</docidentifier>
        <docidentifier type="metanorma">[2]</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>International SSN</name>
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
      <bibitem id="ref11">
        <title>Internet Calendaring and Scheduling Core Object Specification (iCalendar)</title>
        <docidentifier type="IETF">RFC 10</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
          <name>Internet Engineering Task Force</name>
            <abbreviation>IETF</abbreviation>
          </organization>
        </contributor>
        <uri type="xml">https://xml2rfc.tools.ietf.org/10.xml</uri>
      </bibitem>


      </references>
      </bibliography>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
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
           <author fullname="Arthur son of Uther Pendragon">
             <address>
               <postal/>
               <email/>
               <uri/>
             </address>
           </author>
           <abstract>
             <t anchor="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">
               <relref target="ISO712" section="" relative=""/>
               <relref target="ISBN" section="" relative=""/>
               <relref target="ISSN" section="" relative=""/>
               <relref target="ISO16634" section="" relative=""/>
               <relref target="ref11" section="" relative=""/>
             </t>
           </abstract>
         </front>
         <middle>
           <section anchor="A">
             <name>A-title</name>
             <t>A</t>
           </section>
         </middle>
         <back>
           <references anchor='_normative_references'>
             <name>Normative References</name>
             <reference anchor='ISO712'>
               <front>
                 <title>Cereals and cereal products</title>
                 <author>
                   <organization ascii='International Organization for Standardization'>International Organization for Standardization</organization>
                 </author>
               </front>
               <format target='http://www.example.com' type="HTML"/>
               <refcontent>ISO&#xa0;712</refcontent>
             </reference>
             <reference anchor='ISO16634'>
               <front>
                 <title>
                   Cereals, pulses, milled cereal products, oilseeds and animal
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
               <format target='http://www.example.com' type="HTML"/>
               <format target='http://www.example.com/rdf' type='RDF'/>
              <seriesInfo value='1234' name='DOI'/>
               <refcontent>ISO 16634:-- (all parts)</refcontent>
             </reference>
             <reference anchor='ISO20483'>
               <front>
                 <title>Cereals and pulses</title>
                  <author surname="Nürk" asciiSurname="Nurk" initials="Ö." asciiInitials="O."/>
                  <author surname="Citizen" asciiSurname="Citizen" initials="A.B." asciiInitials="A.B."/>
                 <date year='2013'/>
                 <abstract>
                   <t>This is an abstract</t>
                 </abstract>
               </front>
               <refcontent>ISO&#xa0;20483:2013-2014</refcontent>
             </reference>
           </references>
           <references anchor='_bibliography'>
             <name>Bibliography</name>
             <reference anchor='ISBN'>
               <front>
                 <title>Chemicals for analytical laboratory use</title>
                 <author>
                   <organization ascii="International SBN" abbrev="ISBN">International SBN</organization>
                 </author>
               </front>
             </reference>
             <reference anchor='ISSN'>
               <front>
                 <title>Instruments for analytical laboratory use</title>
                 <author>
                   <organization ascii="International SSN" abbrev="ISSN">International SSN</organization>
                 </author>
               </front>
             <annotation>
               NOTE: This is an annotation of document ISSN.
             </annotation>
             <annotation>
               NOTE: This is another annotation of document ISSN.
             </annotation>
             </reference>
             <reference anchor='ISO3696'>
               <front>
                 <title>Water for analytical laboratory use</title>
                 <author>
                   <organization ascii='International Standards Organization' abbrev='ISO'>International Standards Organization</organization>
                 </author>
               </front>
               <refcontent>ISO&#xa0;3696</refcontent>
             </reference>
             <reference anchor='ref11'>
        <front>
          <title>Internet Calendaring and Scheduling Core Object Specification (iCalendar)</title>
          <author>
            <organization ascii="Internet Engineering Task Force" abbrev="IETF">Internet Engineering Task Force</organization>
          </author>
        </front>
        <format target='https://xml2rfc.tools.ietf.org/10.xml' type='xml'/>
        <seriesInfo value='10' name='RFC'/>
      </reference>
           </references>
         </back>
         </rfc>

    OUTPUT
    IsoDoc::Ietf::RfcConvert.new({ use_xinclude: "true" })
      .convert("test", input, false)
    expect(File.exist?("test.rfc.xml")).to be true
    xml = File.read("test.rfc.xml")
    expect(xmlpp(xml)).to be_equivalent_to xmlpp(output)
  end

  it "processes nested bibliographies" do
    input = <<~INPUT
      <ietf-standard  xmlns="http://riboseinc.com/isoxml">
      <sections><clause id="_clause" inline-header="false" obligation="normative">
      <title>Clause</title>
      <p id="_c401175c-2d9b-4758-ba27-d4f50ddb062a">A</p>
      </clause>
      <clause id="_references" inline-header="false" obligation="normative"><title>References</title><references id="_normative_references" normative="true" obligation="informative">
      <title>Normative references</title>
      <bibitem id="A">
      <title>X</title>
      <docidentifier>B</docidentifier>

      </bibitem>
      </references>
      <references id="_informative_references" normative="false" obligation="informative">
      <title>Bibliography</title><bibitem id="C">
      <title>Y</title>
      <docidentifier>D</docidentifier>

      </bibitem>

      </references></clause>
      <clause id="_references_2" inline-header="false" obligation="normative"><title>References 2</title><p id="_849e5255-ca89-4667-b517-743ab74a032e">Z</p>
      <references id="_normative_references_2" normative="false" obligation="informative">
      <title>Normative References</title><bibitem id="E">
      <title>X</title>
      <docidentifier>F</docidentifier>

      </bibitem>

      </references>
      <references id="_informative_references_2" normative="false" obligation="informative">
      <title>Informative References</title><bibitem id="G">
      <title>Y</title>
      <docidentifier>H</docidentifier>

      </bibitem>

      </references></clause></sections>
      </ietf-standard>
    INPUT
    output = <<~OUTPUT
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
               </middle>
               <back>
                 <references anchor='_references'>
                   <name>References</name>
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
                 </references>
                 <references anchor='_references_2'>
                   <name>References 2</name>
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
                   <t anchor='_849e5255-ca89-4667-b517-743ab74a032e'>Z</t>
                 </references>
               </back>
             </rfc>
    OUTPUT
    expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({}).convert("test", input,
                                                          true))).to be_equivalent_to xmlpp(output)
  end
end
