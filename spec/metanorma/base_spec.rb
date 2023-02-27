require "spec_helper"
require "fileutils"

RSpec.describe Metanorma::Ietf do
  it "has a version number" do
    expect(Metanorma::Ietf::VERSION).not_to be nil
  end

  it "processes a blank document" do
    VCR.use_cassette "workgroup_fetch" do
      input = <<~INPUT
        = Document title
        Author
        :docfile: test.adoc
        :nodoc:
        :novalid:
        :no-isobib:
        :flush-caches: true
      INPUT
      output = <<~OUTPUT
        #{BLANK_HDR}
        <sections/>
        </ietf-standard>
      OUTPUT
      expect(xmlpp(Asciidoctor.convert(input, *OPTIONS)))
        .to be_equivalent_to xmlpp(output)
    end
  end

  it "converts a blank document" do
    FileUtils.rm_f "test.rfc.xml"
    input = <<~INPUT
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
    INPUT
    output = <<~OUTPUT
          #{BLANK_HDR}
      <sections/>
      </ietf-standard>
    OUTPUT
    expect(xmlpp(Asciidoctor.convert(input, *OPTIONS)))
      .to be_equivalent_to xmlpp(output)
    expect(File.exist?("test.rfc.xml")).to be true
  end

  it "processes default metadata" do
    input = <<~INPUT
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
      :publisher: Hanna Barbera; Cartoon Network
      :copyright-holder: Cartoon Network
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
      :derived-from: https://datatracker.ietf.org/doc/draft-DER1;https://datatracker.ietf.org/doc/draft-DER2
      :instance: EQ1;EQ2
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
      :show-on-front-page: false
      :artworkdelimiter: 1
      :artworklines: 2
      :authorship: 3
      :autobreaks: 4
      :background: 5
      :colonspace: 6
      :comments: 7
      :docmapping: 8
      :editing: 9
      :emoticonic: 10
      :footer: 11
      :header: 12
      :inline: 13
      :iprnotified: 14
      :linkmailto: 15
      :linefile: 16
      :notedraftinprogress: 17
      :private: 18
      :refparent: 19
      :rfcedstyle: 20
      :slides: 21
      :text-list-symbols: 22
      :tocappendix: 23
      :tocindent: 24
      :tocnarrow: 25
      :tocompact: 26
      :topblock: 27
      :useobject: 28
      :strict: 29
      :compact: 30
      :subcompact: 31
      :toc: 32
      :tocdepth: 33
      :symrefs: 34
      :sortrefs: 35
    INPUT
    output = <<~OUTPUT
          <?xml version='1.0' encoding='UTF-8'?>
             <ietf-standard xmlns='https://www.metanorma.org/ns/ietf' type="semantic" version="#{Metanorma::Ietf::VERSION}">
               <bibdata type='standard'>
                 <title language='en' format='text/plain' type='main'>Main Title - Title</title>
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
                     <docidentifier>https://datatracker.ietf.org/doc/draft-DER1</docidentifier>
                   </bibitem>
                 </relation>
                 <relation type='derivedFrom'>
                   <bibitem>
                     <title>--</title>
                     <docidentifier>https://datatracker.ietf.org/doc/draft-DER2</docidentifier>
                   </bibitem>
                 </relation>
                 <relation type='instance'>
                   <bibitem>
                     <title>--</title>
                     <docidentifier>EQ1</docidentifier>
                   </bibitem>
                 </relation>
                 <relation type='instance'>
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
                 <doctype>rfc</doctype>
      <editorialgroup>
        <workgroup number='3' type='C'>WG</workgroup>
        <workgroup number='31' type='C1'>WG1</workgroup>
      </editorialgroup>
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
                   <showOnFrontPage>false</showOnFrontPage>
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
                        <metanorma-extension>
           <presentation-metadata>
             <name>TOC Heading Levels</name>
             <value>2</value>
           </presentation-metadata>
           <presentation-metadata>
             <name>HTML TOC Heading Levels</name>
             <value>2</value>
           </presentation-metadata>
           <presentation-metadata>
             <name>DOC TOC Heading Levels</name>
             <value>2</value>
           </presentation-metadata>
         </metanorma-extension>
               <sections/>
             </ietf-standard>
    OUTPUT
    expect(xmlpp(Asciidoctor.convert(input, *OPTIONS)))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes complex metadata" do
    input = <<~INPUT
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :docnumber: 1000
      :language: el
      :script: Grek
      :publisher: IEC;IETF;ISO
      :intended-series: BCP 111
      :sortrefs: 35

      [abstract]
      == Abstract
      This is the abstract of the document

      This is the second paragraph of the abstract of the document.

      [NOTE,remove-in-rfc=true]
      .Note Title
      ====
      Note contents
      ====

      [language=en]
      == Clause 1
    INPUT
    output = <<~OUTPUT
           <?xml version='1.0' encoding='UTF-8'?>
             <ietf-standard xmlns='https://www.metanorma.org/ns/ietf' type="semantic" version="#{Metanorma::Ietf::VERSION}">
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
                   <p>This is the abstract of the document</p>
                   <p>This is the second paragraph of the abstract of the document.</p>
                   <note removeInRFC='true'>
        <name>Note Title</name>
        <p>Note contents</p>
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
        <doctype>internet-draft</doctype>
        <ipr>trust200902</ipr>
        <pi>
        <tocinclude>yes</tocinclude>
      </pi>
      </ext>
               </bibdata>
                        <metanorma-extension>
           <presentation-metadata>
             <name>TOC Heading Levels</name>
             <value>2</value>
           </presentation-metadata>
           <presentation-metadata>
             <name>HTML TOC Heading Levels</name>
             <value>2</value>
           </presentation-metadata>
           <presentation-metadata>
             <name>DOC TOC Heading Levels</name>
             <value>2</value>
           </presentation-metadata>
         </metanorma-extension>
               <preface>
                 <abstract id='_'>
                 <title>Abstract</title>
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
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "cites drafts of internet drafts" do
    VCR.use_cassette "abarth-02" do
      doc = Asciidoctor.convert(<<~"INPUT", *OPTIONS).gsub(/ schema-version="[^"]+"/, "")
        = Document title
        Author
        :docfile: test.adoc

        <<I-D.abarth-cake>>

        [bibliography]
        == References
        * [[[I-D.abarth-cake,IETF(I-D.draft-abarth-cake-01)]]], _Title_
      INPUT
      expect(doc).to include '<eref type="inline" bibitemid="I-D.abarth-cake" citeas="Internet-Draft draft-abarth-cake-01"/>'
      expect(doc).to include '<bibitem id="I-D.abarth-cake" type="standard">'
      expect(doc).to include '<uri type="TXT">https://www.ietf.org/archive/id/draft-abarth-cake-01.txt</uri>'
    end
  end

  it "processes clause attributes" do
    input = <<~INPUT
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:

      [numbered=true,removeInRFC=true,toc=true]
      == Clause

      [appendix,numbered=true,removeInRFC=true,toc=true]
      == Appendix

    INPUT
    output = <<~OUTPUT
       #{BLANK_HDR}
        <sections>
          <clause id='_' numbered='true' removeInRFC='true' toc='true' inline-header='false' obligation='normative'>
            <title>Clause</title>
          </clause>
        </sections>
        <annex id='_' numbered='true' removeInRFC='true' toc='true' inline-header='false' obligation='normative'>
          <title>Appendix</title>
        </annex>
      </ietf-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end
end
