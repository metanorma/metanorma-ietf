require "spec_helper"

# WS3 port of spec/isodoc/metadata_spec.rb: same inputs, the full
# default pipeline in place of IsoDoc::Ietf::RfcConvert;
# expectations regenerated (the old ones captured the released
# path's DEBUG pre-cleanup output). See per-example comments for
# the adjudications and 0.2.9 model-gap ledger entries.
RSpec.describe "IETF metadata rendering (WS3)" do
  it "processes IsoXML metadata" do
    # Adjudications (WS3): links follow the released rel2iana mapping
    # with raw hrefs; category/number/consensus/status per the
    # released rfc_attributes; postal renders as postalLine — the
    # presentation stage itself collapses structured addresses into
    # formattedAddress, and the corpus baselines confirm the released
    # FINAL path emits postalLine (the structured street/city
    # expectation was DEBUG-only). Fax phones are dropped: RFC 7991
    # removed <facsimile> from v3. MODEL GAPS (0.2.9 ledger): ext maps
    # only area/consensus/doctype/ipr, so indexInclude/iprExtract/
    # sortRefs/symRefs/tocInclude/tocDepth cannot be emitted; pi keeps
    # 8 legacy keys only; explicit <initial> is parse-ghosted, so
    # initials are computed from the forename.
    input = <<~INPUT
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
                           <street>6A Rubble Way</street>
                           <city>Bedrock</ciy>
                           <state>CA</state>
                           <country>USA</country>
                           <postcode>90210</postcode>
                         </address>
                       </organization>
                     </affiliation>
                     <phone>123c</phone>
                      <phone type='fax'>123d</phone>
                     <email>barney@rockhead.example.com</email>
                     <email>barney2@rockhead.example.com</email>
                   </person>
                 </contributor>
                 <contributor><role type="author"><description>committee</description></role><organization>
                <name>Internet Engineering Task Force</name>
                <subdivision type="Workgroup">
                <name>WG</name>
                </subdivision><abbreviation>IETF</abbreviation></organization></contributor>
                 <contributor><role type="author"><description>committee</description></role><organization>
                <name>Internet Engineering Task Force</name>
                <subdivision type="Workgroup">
                <name>WG1</name>
                </subdivision><abbreviation>IETF</abbreviation></organization></contributor>
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
                 <relation type='instanceOf'>
                   <bibitem>
                     <title>--</title>
                     <docidentifier>EQ1</docidentifier>
                   </bibitem>
                 </relation>
                 <relation type='instanceOf'>
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
        <title>FYI</title>
                 </series>
                 <keyword>a</keyword>
                 <keyword>b</keyword>
                 <keyword>c</keyword>
                 <ext>
                 <doctype>RFC</doctype>
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
                                <pi>
        <artworkdelimiter>1</artworkdelimiter>
        <artworklines>2</artworklines>
        <authorship>3</authorship>
        <autobreaks>4</autobreaks>
        <background>5</background>
        <colonspace>6</colonspace>
        <comments>7</comments>
        <docmapping>8</docmapping>
        <editing>9</editing>
        <emoticonic>10</emoticonic>
        <footer>11</footer>
        <header>12</header>
        <inline>13</inline>
        <iprnotified>14</iprnotified>
        <linkmailto>15</linkmailto>
        <linefile>16</linefile>
        <notedraftinprogress>17</notedraftinprogress>
        <private>18</private>
        <refparent>19</refparent>
        <rfcedstyle>20</rfcedstyle>
        <slides>21</slides>
        <text-list-symbols>22</text-list-symbols>
        <tocappendix>23</tocappendix>
        <tocindent>24</tocindent>
        <tocnarrow>25</tocnarrow>
        <tocompact>26</tocompact>
        <topblock>27</topblock>
        <useobject>28</useobject>
        <strict>29</strict>
        <compact>30</compact>
        <subcompact>31</subcompact>
        <tocinclude>no</tocinclude>
        <tocdepth>9</tocdepth>
        <symrefs>false</symrefs>
        <sortrefs>false</sortrefs>
      </pi>
                 </ext>
               </bibdata>
               <sections/>
             </ietf-standard>
    INPUT
    output = <<~OUTPUT
      <?xml version="1.0" encoding="utf-8"?>
      <?rfc sortrefs="false"?>
      <?rfc symrefs="false"?>
      <?rfc tocdepth="9"?>
      <?rfc subcompact="31"?>
      <?rfc compact="30"?>
      <?rfc strict="29"?>
      <?rfc notedraftinprogress="17"?>
      <?rfc comments="7"?>
      <rfc number="1000" obsoletes="OB1, OB2" updates="UPD1, UPD2" category="info" consensus="false" ipr="noModificationTrust200902,pre5378Trust200902" submissionType="IRTF" version="3" xml:lang="en">
        <link href="INC1" rel="item"/>
        <link href="INCL2" rel="item"/>
        <link href="DESC1" rel="describedby"/>
        <link href="DESC2" rel="describedby"/>
        <link href="DER1" rel="convertedfrom"/>
        <link href="DER2" rel="convertedfrom"/>
        <link href="EQ1" rel="alternate"/>
        <link href="EQ2" rel="alternate"/>
        <front>
          <title abbrev="Abbreviated Title" ascii="Ascii Title">Main Title?~@~I?~@~T?~@~ITitle</title>
          <seriesInfo name="RFC" value="1000" asciiName="RFC" status="10" stream="IRTF"/>
          <seriesInfo name="" value="" status="FYI"/>
          <author fullname="Fred Flintstone">
            <organization>Slate Rock and Gravel Company</organization>
            <address>
              <postal>
                <postalLine>6 Rubble Way, Bedrock</postalLine>
              </postal>
              <phone>123</phone>
              <uri>http://slate.example.com</uri>
            </address>
          </author>
          <author initials="B." surname="Rubble" fullname="Barney Rubble" role="editor">
            <organization>Rockhead and Quarry Cave Construction Company</organization>
            <address>
              <postal>
                <postalLine>6A Rubble Way</postalLine>
                <postalLine>Bedrock</postalLine>
                <postalLine>CA</postalLine>
                <postalLine>USA 90210</postalLine>
              </postal>
              <phone>123c</phone>
              <email>barney@rockhead.example.com</email>
              <email>barney2@rockhead.example.com</email>
            </address>
          </author>
          <date day="1" month="January" year="1000"/>
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
    expect(strip_guid(feature_convert(input)))
      .to be_xml_equivalent_to strip_guid(output)
  end

  it "processes IsoXML metadata (Internet-Draft)" do
    # The abstract note (removeInRFC) renders as a front <note>, its
    # v3 home — the old DEBUG expectation kept it as an aside inside
    # <abstract>, which the v3 content model does not admit.
    input = <<~INPUT
         <ietf-standard xmlns='https://open.ribose.com/standards/ietf'>
               <bibdata type='standard'>
                 <title language='en' type="main" format='text/plain'>Dócument title</title>
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
                       <completename>Fréd Flintstone</completename>
                     </name>
                     <affiliation>
                       <organization>
                         <name>Sláte Rock and Gravel Company</name>
                         <address>
                           <formattedAddress>6 Rubble Way<br/>Bedrock</formattedAddress>
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
                   <p id='P1'>This is the abstract of the document</p>
                   <p id='P2'>This is the second paragraph of the abstract of the document.</p>
                   <note removeInRFC='true' id='N1'>
        <name>Note Title</name>
        <p id='P3'>Note contents</p>
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
                 <abstract id='A1'>
                   <p id='PA1'>This is the abstract of the document</p>
                   <p id='PA2'>This is the second paragraph of the abstract of the document.</p>
                   <note removeInRFC='true' id='NA1'>
        <name>Note Title</name>
        <p id='PA3'>Note contents</p>
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
    output = <<~OUTPUT
      <?xml version="1.0" encoding="utf-8"?>
      <?rfc sortrefs="yes"?>
      <?rfc symrefs="yes"?>
      <?rfc tocdepth="4"?>
      <?rfc subcompact="no"?>
      <?rfc compact="yes"?>
      <?rfc strict="yes"?>
      <rfc category="bcp" ipr="trust200902" submissionType="IETF" docName="1000" version="3" xml:lang="el">
        <front>
          <title ascii="Document title">Dócument title</title>
          <seriesInfo name="Internet-Draft" value="1000" asciiName="Internet-Draft" status="Published" stream="IETF"/>
          <seriesInfo name="" value="" status="BCP"/>
          <author fullname="Fréd Flintstone" asciiFullname="Fred Flintstone">
            <organization ascii="Slate Rock and Gravel Company">Sláte Rock and Gravel Company</organization>
            <address>
              <postal>
                <postalLine>6 Rubble Way</postalLine>
                <postalLine>Bedrock</postalLine>
              </postal>
              <phone>123</phone>
              <uri>http://slate.example.com</uri>
            </address>
          </author>
          <date day="1" month="January" year="2000"/>
          <abstract anchor="A1">
            <t anchor="PA1">This is the abstract of the document</t>
            <t anchor="PA2">This is the second paragraph of the abstract of the document.</t>
          </abstract>
          <note removeInRFC="true">
            <name>Note Title</name>
            <t anchor="PA3">Note contents</t>
          </note>
        </front>
        <middle>
          <section anchor="_">
            <name>Clause 1</name>
          </section>
        </middle>
        <back/>
      </rfc>
    OUTPUT
    expect(strip_guid(feature_convert(input)))
      .to be_xml_equivalent_to strip_guid(output)
  end

  it "emits RFC seriesInfo for lowercase doctype rfc (#268)" do
    # Standoc emits <doctype>rfc</doctype> (lowercase); the base metadata
    # class capitalises it to "Rfc", which used to miss the exact "RFC"
    # comparison gating rfc_seriesinfo, dropping the document's own
    # seriesInfo and with it the "Request for Comments" masthead line
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata type="standard">
      <title language="en" format="text/plain" type="main">Date and Time on the Internet</title>
      <docidentifier>RFC 3339</docidentifier>
      <docnumber>3339</docnumber>
      <ext><doctype>rfc</doctype><ipr>trust200902</ipr></ext>
      </bibdata>
      <sections><clause id="A"><title>A-title</title><p>A</p></clause></sections>
      </iso-standard>
    INPUT
    out = feature_convert(input)
    xml = Nokogiri::XML(out)
    si = xml.at("//front/seriesInfo[@name = 'RFC']")
    expect(si).not_to be_nil
    expect(si["value"]).to eq "3339"
    expect(xml.root["number"]).to eq "3339"
  end
end
