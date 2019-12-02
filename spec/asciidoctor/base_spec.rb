require "spec_helper"
require "fileutils"

RSpec.describe Asciidoctor::Ietf do
  it "has a version number" do
    expect(Metanorma::Ietf::VERSION).not_to be nil
  end

  it "processes a blank document" do
    expect(xmlpp(Asciidoctor.convert(<<~"INPUT", backend: :ietf, header_footer: true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    #{ASCIIDOC_BLANK_HDR}
    INPUT
    #{BLANK_HDR}
<sections/>
</ietf-standard>
    OUTPUT
  end

  it "converts a blank document" do
    FileUtils.rm_f "test.rfc.xml"
    expect(xmlpp(Asciidoctor.convert(<<~"INPUT", backend: :ietf, header_footer: true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
    INPUT
    #{BLANK_HDR}
<sections/>
</ietf-standard>
    OUTPUT
    expect(File.exist?("test.rfc.xml")).to be true
  end

  it "processes default metadata" do
    expect(xmlpp(Asciidoctor.convert(<<~"INPUT", backend: :ietf, header_footer: true))).to be_equivalent_to xmlpp(<<~'OUTPUT')
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :docnumber: 1000
      :edition: 2
      :revdate: 2000-01-01
      :published-date: 1000-01-01
      :accessed-date: 1001-01-01
      :created-date: 1002-01-01
      :implemented-date: 1003-01-01
      :obsoleted-date: 1004-01-01
      :confirmed-date: 1005-01-01
      :updated-date: 1006-01-01
      :issued-date: 1007-01-01
      :circulated-date: 1008-01-01
      :unchanged-date: 1009-01-01
      :date: Fred 1010-01-01
      :date_2: Jack 1010-01-01
      :draft: 3.4
      :technical-committee: TC
      :technical-committee-number: 1
      :technical-committee-type: A
      :subcommittee: SC
      :subcommittee-number: 2
      :subcommittee-type: B
      :workgroup: WG
      :workgroup-number: 3
      :workgroup-type: C
      :technical-committee_2: TC1
      :technical-committee-number_2: 11
      :technical-committee-type_2: A1
      :subcommittee_2: SC1
      :subcommittee-number_2: 21
      :subcommittee-type_2: B1
      :workgroup_2: WG1
      :workgroup-number_2: 31
      :workgroup-type_2: C1
      :secretariat: SECRETARIAT
      :copyright-year: 2001
      :docstage: 10
      :docsubstage: 20
      :iteration: 3
      :language: en
      :title: Main Title -- Title
      :library-ics: 1,2,3
      :fullname: Fred Flintstone
      :role: author
      :affiliation: Slate Rock and Gravel Company
      :address: 6 Rubble Way, Bedrock
      :contributor-uri: http://slate.example.com
      :surname_2: Rubble
      :givenname_2: Barney
      :initials_2: B. X.
      :role_2: editor
      :affiliation_2: Rockhead and Quarry Cave Construction Company
      :address_2: 6A Rubble Way, Bedrock
      :email_2: barney@rockhead.example.com
      :publisher: Hanna Barbera, Cartoon Network
      :part-of: ABC
      :translated-from: DEF,GHI;JKL MNO,PQR
      :keywords: a, b, c
      :submission-type: IRTF
      :ipr: noModificationTrust200902,pre5378Trust200902
      :consensus: false
      :index-include: false
      :ipr-extract: Section 3
      :sort-refs: false
      :sym-refs: false
      :toc-include: false
      :toc-depth: 9
      :included-in: INC1;INCL2
      :described-by: DESC1;DESC2
      :derived-from: DER1;DER2
      :equivalent: EQ1;EQ2
      :obsoletes: OB1;OB2
      :updates: UPD1;UPD2
      :abbrev: Abbreviated Title
      :asciititle: Ascii Title
      :intended-series: BCP
      :area: A, B, C
      :doctype: RFC
      :phone: 123
      :fax: 123b
      :phone_2: 123c
      :fax_2: 123d
    INPUT
    <?xml version='1.0' encoding='UTF-8'?>
       <ietf-standard xmlns='https://open.ribose.com/standards/ietf'>
         <bibdata type='standard'>
           <title language='en' format='text/plain' type='main'>Main Title — Title</title>
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
    OUTPUT
  end

  it "processes complex metadata" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :ietf, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :docnumber: 1000
      :language: el
      :script: Grek
      :publisher: IEC,IETF,ISO
      :intended-series: BCP 111

      [abstract]
      == Abstract
      This is the abstract of the document

      This is the second paragraph of the abstract of the document.

      [NOTE,removeInRFC=true]
      .Note Title
      ====
      Note contents
      ====

      [language=en]
      == Clause 1
    INPUT
     <?xml version='1.0' encoding='UTF-8'?>
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
    OUTPUT
  end

end



