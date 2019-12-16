require "spec_helper"
require "nokogiri"

RSpec.describe IsoDoc::Ietf::RfcConvert do
    it "processes IsoXML metadata" do
expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
<ietf-standard xmlns='https://open.ribose.com/standards/ietf'>
         <bibdata type='standard'>
           <title language='en' format='text/plain' type='main'>Main Title?~@~I?~@~T?~@~ITitle</title>
        <title language='en' format='text/plain' type='abbrev'>Abbreviated Title</title>
        <title language='en' format='text/plain' type='ascii'>Ascii Title</title>
           <docidentifier>1000</docidentifier>
           <docnumber>1000</docnumber>
           <date type='published'>
             <on>1000-01-01</on>
           </date>
           <date type='accessed'>
             <on>1001-01-01</on>
           </date>
           <date type='created'>
             <on>1002-01-01</on>
           </date>
           <date type='implemented'>
             <on>1003-01-01</on>
           </date>
           <date type='obsoleted'>
             <on>1004-01-01</on>
           </date>
           <date type='confirmed'>
             <on>1005-01-01</on>
           </date>
           <date type='updated'>
             <on>1006-01-01</on>
           </date>
           <date type='issued'>
             <on>1007-01-01</on>
           </date>
           <date type='circulated'>
             <on>1008-01-01</on>
           </date>
           <date type='unchanged'>
             <on>1009-01-01</on>
           </date>
           <date type='Fred'>
             <on>1010-01-01</on>
           </date>
           <date type='Jack'>
             <on>1010-01-01</on>
           </date>
           <contributor>
             <role type='author'/>
             <person>
               <name>
                 <completename>Fred Flintstone</completename>
               </name>
               <affiliation>
                 <organization>
                   <name>Slate Rock and Gravel Company</name>
                   <address>
                     <formattedAddress>6 Rubble Way, Bedrock</formattedAddress>
                   </address>
                 </organization>
               </affiliation>
               <phone>123</phone>
<phone type='fax'>123b</phone>
               <uri>http://slate.example.com</uri>
             </person>
           </contributor>
           <contributor>
             <role type='editor'/>
             <person>
               <name>
                 <forename>Barney</forename>
                 <initial>B. X.</initial>
                 <surname>Rubble</surname>
               </name>
               <affiliation>
                 <organization>
                   <name>Rockhead and Quarry Cave Construction Company</name>
                   <address>
                     <formattedAddress>6A Rubble Way, Bedrock</formattedAddress>
                   </address>
                 </organization>
               </affiliation>
               <phone>123c</phone>
<phone type='fax'>123d</phone>
               <email>barney@rockhead.example.com</email>
             </person>
           </contributor>
           <contributor>
             <role type='publisher'/>
             <organization>
               <name>Hanna Barbera</name>
             </organization>
           </contributor>
           <contributor>
             <role type='publisher'/>
             <organization>
               <name>Cartoon Network</name>
             </organization>
           </contributor>
           <edition>2</edition>
           <version>
             <revision-date>2000-01-01</revision-date>
             <draft>3.4</draft>
           </version>
           <language>en</language>
           <script>Latn</script>
           <status>
             <stage>10</stage>
             <substage>20</substage>
             <iteration>3</iteration>
           </status>
           <copyright>
             <from>2001</from>
             <owner>
               <organization>
                 <name>Hanna Barbera</name>
               </organization>
             </owner>
           </copyright>
           <copyright>
             <from>2001</from>
             <owner>
               <organization>
                 <name>Cartoon Network</name>
               </organization>
             </owner>
           </copyright>
           <relation type='includedIn'>
             <bibitem>
               <title>--</title>
               <docidentifier>INC1</docidentifier>
             </bibitem>
           </relation>
           <relation type='includedIn'>
             <bibitem>
               <title>--</title>
               <docidentifier>INCL2</docidentifier>
             </bibitem>
           </relation>
           <relation type='describedBy'>
             <bibitem>
               <title>--</title>
               <docidentifier>DESC1</docidentifier>
             </bibitem>
           </relation>
           <relation type='describedBy'>
             <bibitem>
               <title>--</title>
               <docidentifier>DESC2</docidentifier>
             </bibitem>
           </relation>
           <relation type='derivedFrom'>
             <bibitem>
               <title>--</title>
               <docidentifier>DER1</docidentifier>
             </bibitem>
           </relation>
           <relation type='derivedFrom'>
             <bibitem>
               <title>--</title>
               <docidentifier>DER2</docidentifier>
             </bibitem>
           </relation>
           <relation type='equivalent'>
             <bibitem>
               <title>--</title>
               <docidentifier>EQ1</docidentifier>
             </bibitem>
           </relation>
           <relation type='equivalent'>
             <bibitem>
               <title>--</title>
               <docidentifier>EQ2</docidentifier>
             </bibitem>
           </relation>
           <relation type='obsoletes'>
             <bibitem>
               <title>--</title>
               <docidentifier>OB1</docidentifier>
             </bibitem>
           </relation>
           <relation type='obsoletes'>
             <bibitem>
               <title>--</title>
               <docidentifier>OB2</docidentifier>
             </bibitem>
           </relation>
           <relation type='updates'>
             <bibitem>
               <title>--</title>
               <docidentifier>UPD1</docidentifier>
             </bibitem>
           </relation>
           <relation type='updates'>
             <bibitem>
               <title>--</title>
               <docidentifier>UPD2</docidentifier>
             </bibitem>
           </relation>
           <series type='stream'>
             <title>IRTF</title>
             </series>
<series type='intended'>
  <title>BCP</title>
           </series>
           <keyword>a</keyword>
           <keyword>b</keyword>
           <keyword>c</keyword>
           <ext>
           <doctype>RFC</doctype>
<editorialgroup>
  <workgroup number='3' type='C'>WG</workgroup>
  <workgroup number='31' type='C1'>WG1</workgroup>
</editorialgroup>
<ics>
  <code>1</code>
</ics>
<ics>
  <code>2</code>
</ics>
<ics>
  <code>3</code>
</ics>
<area>A</area>
<area>B</area>
<area>C</area>
             <ipr>noModificationTrust200902,pre5378Trust200902</ipr>
             <consensus>false</consensus>
             <indexInclude>false</indexInclude>
             <iprExtract>Section 3</iprExtract>
             <sortRefs>false</sortRefs>
             <symRefs>false</symRefs>
             <tocInclude>false</tocInclude>
             <tocDepth>9</tocDepth>
           </ext>
         </bibdata>
         <sections/>
       </ietf-standard>
INPUT
<rfc xmlns:xi='http://www.w3.org/2001/XInclude' category='BCP' ipr='noModificationTrust200902,pre5378Trust200902' obsoletes='OB1, OB2' updates='UPD1, UPD2' indexInclude='false' iprExtract='Section 3' sortRefs='false' symRefs='false' tocInclude='false' tocDepth='9' submissionType='IRTF' xml:lang='en' version='3' prepTime='2000-01-01T05:00:00Z'>
         <link href='INC1' rel='item'/>
         <link href='INCL2' rel='item'/>
         <link href='DESC1' rel='describedby'/>
         <link href='DESC2' rel='describedby'/>
         <link href='DER1' rel='convertedfrom'/>
         <link href='DER2' rel='convertedfrom'/>
         <link href='EQ1' rel='alternate'/>
         <link href='EQ2' rel='alternate'/>
         <front>
           <title abbrev='Abbreviated Title' ascii='Ascii Title'>Main Title?~@~I?~@~T?~@~ITitle</title>
           <seriesInfo value='1000' asciiValue='1000' status='10' stream='IRTF' name='RFC' asciiName='RFC'/>
           <seriesInfo name='' status='BCP'/>
            <author>
            <organization ascii='Slate Rock and Gravel Company'>Slate Rock and Gravel Company</organization>
<postalLine ascii='6 Rubble Way, Bedrock'>6 Rubble Way, Bedrock</postalLine>
<phone>123</phone>
<facsimile>123b</facsimile>
<email/>
<uri>http://slate.example.com</uri>
 </author>
 <author>
  <organization ascii='Rockhead and Quarry Cave Construction Company'>Rockhead and Quarry Cave Construction Company</organization>
  <postalLine ascii='6A Rubble Way, Bedrock'>6A Rubble Way, Bedrock</postalLine>
  <phone>123c</phone>
  <facsimile>123d</facsimile>
  <email>barney@rockhead.example.com</email>
  <uri/>
</author>
           <date day='1' year='1000' month='January'/>
           <area>A</area>
           <area>B</area>
           <area>C</area>
           <workgroup>WG</workgroup>
           <workgroup>WG1</workgroup>
           <keyword>a</keyword>
           <keyword>b</keyword>
           <keyword>c</keyword>
         </front>
         <middle/>
         <back/>
       </rfc>
OUTPUT
  end

  it "processes IsoXML metadata" do
  expect(xmlpp(IsoDoc::Ietf::RfcConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
   <ietf-standard xmlns='https://open.ribose.com/standards/ietf'>
         <bibdata type='standard'>
           <title language='en' type="main" format='text/plain'>Document title</title>
           <docidentifier>1000</docidentifier>
           <docnumber>1000</docnumber>
           <contributor>
             <role type='publisher'/>
             <organization>
               <name>IEC</name>
             </organization>
           </contributor>
           <contributor>
             <role type='author'/>
             <person>
               <name>
                 <completename>Fred Flintstone</completename>
               </name>
               <affiliation>
                 <organization>
                   <name>Slate Rock and Gravel Company</name>
                   <address>
                     <formattedAddress>6 Rubble Way, Bedrock</formattedAddress>
                   </address>
                 </organization>
               </affiliation>
               <phone>123</phone>
<phone type='fax'>123b</phone>
               <uri>http://slate.example.com</uri>
             </person>
           </contributor>
           <contributor>
             <role type='publisher'/>
             <organization>
               <name>Internet Engineering Task Force</name>
               <abbreviation>IETF</abbreviation>
             </organization>
           </contributor>
           <contributor>
             <role type='publisher'/>
             <organization>
               <name>ISO</name>
             </organization>
           </contributor>
           <language>el</language>
           <script>Grek</script>
           <abstract>
             <p id='_'>This is the abstract of the document</p>
             <p id='_'>This is the second paragraph of the abstract of the document.</p>
             <note removeInRFC='true' id='_'>
  <name>Note Title</name>
  <p id='_'>Note contents</p>
</note>
           </abstract>
           <status>
             <stage>published</stage>
           </status>
           <copyright>
             <from>2000</from>
             <owner>
               <organization>
                 <name>IEC</name>
               </organization>
             </owner>
           </copyright>
           <copyright>
             <from>2000</from>
             <owner>
               <organization>
                 <name>Internet Engineering Task Force</name>
                 <abbreviation>IETF</abbreviation>
               </organization>
             </owner>
           </copyright>
           <copyright>
             <from>2000</from>
             <owner>
               <organization>
                 <name>ISO</name>
               </organization>
             </owner>
           </copyright>
           <series type='stream'>
             <title>IETF</title>
             </series>
<series type='intended'>
  <title>BCP</title>
  <number>111</number>
           </series>
           <ext>
  <doctype>Internet-Draft</doctype>
  <showOnFrontPage>true</showOnFrontPage>
</ext>
         </bibdata>
         <preface>
           <abstract id='_'>
             <p id='_'>This is the abstract of the document</p>
             <p id='_'>This is the second paragraph of the abstract of the document.</p>
             <note removeInRFC='true' id='_'>
  <name>Note Title</name>
  <p id='_'>Note contents</p>
</note>
           </abstract>
         </preface>
         <sections>
           <clause id='_' language='en' inline-header='false' obligation='normative'>
             <title>Clause 1</title>
           </clause>
         </sections>
       </ietf-standard>
INPUT
        <rfc xmlns:xi='http://www.w3.org/2001/XInclude' category='BCP' submissionType='IETF' xml:lang='el' version='3' prepTime='2000-01-01T05:00:00Z'>
         <front>
           <title>Document title</title>
           <seriesInfo value='1000' asciiValue='1000' status='Published' stream='IETF' name='Internet-Draft' asciiName='Internet-Draft'/>
           <seriesInfo name='' status='BCP'/>
           <author>
  <organization showOnFrontPage='true' ascii='Slate Rock and Gravel Company'>Slate Rock and Gravel Company</organization>
  <postalLine ascii='6 Rubble Way, Bedrock'>6 Rubble Way, Bedrock</postalLine>
  <phone>123</phone>
  <facsimile>123b</facsimile>
  <email/>
  <uri>http://slate.example.com</uri>
</author>
           <abstract anchor='_'>
             <t anchor='_'>This is the abstract of the document</t>
             <t anchor='_'>This is the second paragraph of the abstract of the document.</t>
           </abstract>
           <note removeInRFC='true'>
             <name>Note Title</name>
             <t anchor='_'>Note contents</t>
           </note>
         </front>
         <middle>
           <section anchor='_'>
             <name anchor='_'>Clause 1</name>
           </section>
         </middle>
         <back/>
       </rfc>
OUTPUT
  end

end
