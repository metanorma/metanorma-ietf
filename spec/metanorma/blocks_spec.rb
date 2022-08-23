require "spec_helper"
require "open3"

RSpec.describe Metanorma::Ietf do
  it "processes paragraphs" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}

      [keepWithNext=true,keepWithPrevious=true]
      Hello
    INPUT
       #{BLANK_HDR}
      <sections>
      <p keep-with-next='true' keep-with-previous='true' id='_'>Hello</p>
      </sections>
      </ietf-standard>
    OUTPUT
  end

  it "processes open blocks" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      --
      x

      y

      z
      --
    INPUT
       #{BLANK_HDR}
      <sections><p id="_">x</p>
      <p id="_">y</p>
      <p id="_">z</p></sections>
      </ietf-standard>
    OUTPUT
  end

  it "ignores review blocks unless document is in draft mode" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      [[foreword]]
      .Foreword
      Foreword

      [reviewer=ISO,date=20170101,from=foreword,to=foreword]
      ****
      A Foreword shall appear in each document. The generic text is shown here. It does not contain requirements, recommendations or permissions.

      For further information on the Foreword, see *ISO/IEC Directives, Part 2, 2016, Clause 12.*
      ****
    INPUT
             #{BLANK_HDR}
      <sections><p id="foreword">Foreword</p>
      </sections>
      </ietf-standard>
    OUTPUT
  end

  it "processes review blocks if document is in draft mode" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :draft: 1.2

      [[foreword]]
      .Foreword
      Foreword

      [reviewer=ISO,date=20170101,from=foreword,to=foreword,display=false]
      .Title
      ****
      A Foreword shall appear in each document. The generic text is shown here. It does not contain requirements, recommendations or permissions.

      For further information on the Foreword, see *ISO/IEC Directives, Part 2, 2016, Clause 12.*
      ****
    INPUT
            <ietf-standard xmlns="https://www.metanorma.org/ns/ietf" type="semantic" version="#{Metanorma::Ietf::VERSION}">
             <bibdata type="standard">
               <title language="en" type="main" format="text/plain">Document title</title>
      <contributor>
                   <role type='publisher'/>
                   <organization>
                     <name>Internet Engineering Task Force</name>
                     <abbreviation>IETF</abbreviation>
                   </organization>
                 </contributor>
               <version>
                 <draft>1.2</draft>
               </version>
               <language>en</language>
               <script>Latn</script>
               <status><stage>published</stage></status>
               <copyright>
                 <from>#{Date.today.year}</from>
                 <owner>
                     <organization>
                       <name>Internet Engineering Task Force</name>
                       <abbreviation>IETF</abbreviation>
                     </organization>
                   </owner>
               </copyright>
                <series type='stream'>
                   <title>IETF</title>
                 </series>
               <ext>
        <doctype>internet-draft</doctype>
        <ipr>trust200902</ipr>
        <pi>
        <tocinclude>yes</tocinclude>
      </pi>
      </ext>
             </bibdata>
             <sections><p id="foreword">Foreword</p>
             <review reviewer="ISO" id="_" date="20170101T00:00:00Z" from="foreword" to="foreword" display='false'>
             <name>Title</name>
      <p id="_">A Foreword shall appear in each document. The generic text is shown here. It does not contain requirements, recommendations or permissions.</p>
             <p id="_">For further information on the Foreword, see <strong>ISO/IEC Directives, Part 2, 2016, Clause 12.</strong></p></review></sections>
             </ietf-standard>
    OUTPUT
  end

  it "processes term notes" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      == Terms and Definitions

      === Term1

      NOTE: This is a note
    INPUT
             #{BLANK_HDR}
      <sections>
        <terms id="_" obligation="normative">
        <title>Terms and definitions</title>
        <term id="term-Term1">
        <preferred><expression><name>Term1</name></expression></preferred>
        <termnote id="_">
        <p id="_">This is a note</p>
      </termnote>
      </term>
      </terms>
      </sections>
      </ietf-standard>
    OUTPUT
  end

  it "processes term notes as plain notes in nonterm clauses" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      == Terms and Definitions

      [.nonterm]
      === Term1

      NOTE: This is a note
    INPUT
                    #{BLANK_HDR}
                    <sections>
        <terms id="_" obligation="normative">
        <title>Terms and definitions</title>
        <clause id="_" inline-header="false" obligation="normative">
        <title>Term1</title>
        <note id="_">
        <p id="_">This is a note</p>
      </note>
      </clause>
      </terms>
      </sections>
      </ietf-standard>
    OUTPUT
  end

  it "processes term notes as plain notes in definitions subclauses of terms & definitions" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      == Terms and Definitions

      === Term1

      === Symbols

      NOTE: This is a note
    INPUT
                    #{BLANK_HDR}
                    <sections>
        <terms id="_" obligation="normative"><title>Terms, definitions and symbols</title>
      <term id="term-Term1">
        <preferred><expression><name>Term1</name></expression></preferred>
      </term>
      <definitions id="_" obligation="normative" type="symbols">
        <title>Symbols</title>
        <note id="_">
        <p id="_">This is a note</p>
      </note>
      </definitions></terms>
      </sections>
      </ietf-standard>
    OUTPUT
  end

  it "processes notes" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      NOTE: This is a note

      == Clause 1


      NOTE: This is a note
    INPUT
             #{BLANK_HDR}
             <preface><foreword id="_" obligation="informative">
        <title>Foreword</title>
        <note id="_">
        <p id="_">This is a note</p>
      </note>
      </foreword></preface><sections>
      <clause id="_" inline-header="false" obligation="normative">
        <title>Clause 1</title>
        <note id="_">
        <p id="_">This is a note</p>
      </note>
      </clause></sections>

      </ietf-standard>

    OUTPUT
  end

  it "processes literals" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      [[lit]]
      [align=left,alt=hello]
      ....
      <LITERAL>
      ....
    INPUT
      #{BLANK_HDR}
       <sections>
           <figure id="lit">
        <pre id='_' align='left' alt='hello'>&lt;LITERAL&gt;</pre>
        </figure>
       </sections>
       </ietf-standard>

    OUTPUT
  end

  it "processes simple admonitions with Asciidoc names" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      CAUTION: Only use paddy or parboiled rice for the determination of husked rice yield.
    INPUT
      #{BLANK_HDR}
       <sections>
         <admonition id="_" type="caution">
         <p id="_">Only use paddy or parboiled rice for the determination of husked rice yield.</p>
       </admonition>
       </sections>
       </ietf-standard>

    OUTPUT
  end

  it "processes complex admonitions with non-Asciidoc names" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      [CAUTION,type=Safety Precautions]
      .Precautions
      ====
      While werewolves are hardy community members, keep in mind the following dietary concerns:

      . They are allergic to cinnamon.
      . More than two glasses of orange juice in 24 hours makes them howl in harmony with alarms and sirens.
      . Celery makes them sad.
      ====
    INPUT
      #{BLANK_HDR}
      <sections>
         <admonition id="_" type="safety precautions"><name>Precautions</name><p id="_">While werewolves are hardy community members, keep in mind the following dietary concerns:</p>
       <ol id="_" type="arabic">
         <li>
           <p id="_">They are allergic to cinnamon.</p>
         </li>
         <li>
           <p id="_">More than two glasses of orange juice in 24 hours makes them howl in harmony with alarms and sirens.</p>
         </li>
         <li>
           <p id="_">Celery makes them sad.</p>
         </li>
       </ol></admonition>
       </sections>
       </ietf-standard>

    OUTPUT
  end

  it "processes term examples" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      == Terms and Definitions

      === Term1

      [example]
      This is an example
    INPUT
            #{BLANK_HDR}
            <sections>
        <terms id="_" obligation="normative">
        <title>Terms and definitions</title>
        <term id="term-Term1">
        <preferred><expression><name>Term1</name></expression></preferred>
      <termexample id="_">
        <p id="_">This is an example</p>
      </termexample></term>
      </terms>
      </sections>
      </ietf-standard>
    OUTPUT
  end

  it "processes term examples as plain examples in nonterm clauses" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      == Terms and Definitions

      [.nonterm]
      === Term1

      [example]
      This is an example
    INPUT
            #{BLANK_HDR}
      <sections>
        <terms id="_" obligation="normative">
        <title>Terms and definitions</title>
        <clause id="_" inline-header="false" obligation="normative">
        <title>Term1</title>
        <example id="_">
        <p id="_">This is an example</p>
      </example>
      </clause>
      </terms>
      </sections>
      </ietf-standard>
    OUTPUT
  end

  it "processes term examples as plain examples in definitions subclauses of terms & definitions" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      == Terms and Definitions

      === Term1

      === Symbols

      [example]
      This is an example
    INPUT
                    #{BLANK_HDR}
      <sections>
        <terms id="_" obligation="normative"><title>Terms, definitions and symbols</title>
      <term id="term-Term1">
        <preferred><expression><name>Term1</name></expression></preferred>
      </term>
      <definitions id="_" obligation="normative" type="symbols">
        <title>Symbols</title>
        <example id="_">
        <p id="_">This is an example</p>
      </example>
      </definitions></terms>
      </sections>
      </ietf-standard>
    OUTPUT
  end

  it "processes examples" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      [example,subsequence=A]
      .Title
      ====
      This is an example

      Amen
      ====

      [example%unnumbered]
      ====
      This is another example
      ====
    INPUT
      #{BLANK_HDR}
       <sections>
         <example id="_" subsequence="A">
         <name>Title</name>
        <p id="_">This is an example</p>
       <p id="_">Amen</p></example>
         <example id="_" unnumbered="true"><p id="_">This is another example</p></example>
       </sections>
       </ietf-standard>
    OUTPUT
  end

  it "processes preambles" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      This is a preamble

      == Section 1
    INPUT
      #{BLANK_HDR}
             <preface><foreword id="_" obligation="informative">
         <title>Foreword</title>
         <p id="_">This is a preamble</p>
       </foreword></preface><sections>
       <clause id="_" inline-header="false" obligation="normative">
         <title>Section 1</title>
       </clause></sections>
       </ietf-standard>
    OUTPUT
  end

  it "processes preambles with titles" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      .Preamble
      This is a preamble

      == Section 1
    INPUT
      #{BLANK_HDR}
             <preface><foreword id="_" obligation="informative">
         <title>Foreword</title>
         <p id="_">This is a preamble</p>
       </foreword></preface><sections>
       <clause id="_" inline-header="false" obligation="normative">
         <title>Section 1</title>
       </clause></sections>
       </ietf-standard>
    OUTPUT
  end

  it "accepts attributes on images" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      [height=4,width=3,alt="IMAGE",filename="riceimg1.png",titleattr="TITLE",align=left]
      .Caption
      image::spec/assets/rice_image1.png[]

    INPUT
      #{BLANK_HDR}
              <sections>
         <figure id="_"><name>Caption</name>
         <image src="spec/assets/rice_image1.png" id="_" mimetype="image/png" height="4" width="3" title="TITLE" alt="IMAGE" filename="riceimg1.png" align="left"/>
       </figure>
       </sections>
       </ietf-standard>
    OUTPUT
  end

  it "processes blockquotes" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      [quote, ISO, "ISO7301,section 1"]
      ____
      Block quotation
      ____
      [quote, ISO, http://www.example.com]
      ____
      Block quotation 2
      ____
    INPUT
            #{BLANK_HDR}
             <sections>
               <quote id="_">
               <source type="inline" bibitemid="ISO7301" citeas="">
               <localityStack>
              <locality type="section"><referenceFrom>1</referenceFrom></locality>
               </localityStack>
              </source>
               <author>ISO</author>
               <p id="_">Block quotation</p>
             </quote>
             <quote id='_'>
        <source type='inline' uri='http://www.example.com'/>
        <author>ISO</author>
        <p id='_'>Block quotation 2</p>
      </quote>
             </sections>
             </ietf-standard>
    OUTPUT
  end

  it "processes source code" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      .Caption
      [source,ruby,filename=sourcecode1.rb,markers=true]
      --
      puts "Hello, world."
      %w{a b c}.each do |x|
        puts x
      end
      --

      [source,ruby,src="http://www.example.com"]
      --
      --
    INPUT
      #{BLANK_HDR}
       <sections>
         <sourcecode id="_" lang="ruby" filename="sourcecode1.rb" markers="true"><name>Caption</name>puts "Hello, world."
       %w{a b c}.each do |x|
         puts x
       end</sourcecode>
       <sourcecode lang='ruby' id='_' src='http://www.example.com'/>
       </sections>
       </ietf-standard>
    OUTPUT
  end

  it "processes callouts" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      [source,ruby]
      --
      puts "Hello, world." <1>
      %w{a b c}.each do |x|
        puts x <2>
      end
      --
      <1> This is one callout
      <2> This is another callout
    INPUT
      #{BLANK_HDR}
              <sections><sourcecode id="_" lang="ruby">puts "Hello, world." <callout target="_">1</callout>
       %w{a b c}.each do |x|
         puts x <callout target="_">2</callout>
       end<annotation id="_">
         <p id="_">This is one callout</p>
       </annotation><annotation id="_">
         <p id="_">This is another callout</p>
       </annotation></sourcecode>
       </sections>
       </ietf-standard>
    OUTPUT
  end

  it "processes unmodified term sources" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      == Terms and Definitions

      === Term1

      Definition

      [.source]
      <<ISO2191,section=1>>
    INPUT
      #{BLANK_HDR}
       <sections>
         <terms id="_" obligation="normative">
         <title>Terms and definitions</title>
         <term id="term-Term1">
         <preferred><expression><name>Term1</name></expression></preferred>
                 <definition>
          <verbal-definition>
            <p id='_'>Definition</p>
          </verbal-definition>
        </definition>
        <termsource status='identical' type='authoritative'>
        <origin bibitemid="ISO2191" type="inline" citeas="">
         <localityStack>
        <locality type="section"><referenceFrom>1</referenceFrom></locality>
         </localityStack>
        </origin>
       </termsource>
       </term>
       </terms>
       </sections>
       </ietf-standard>
    OUTPUT
  end

  it "processes modified term sources" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      == Terms and Definitions

      === Term1

      Definition

      [.source]
      <<ISO2191,section=1>>, with adjustments
    INPUT
      #{BLANK_HDR}
            <sections>
         <terms id="_" obligation="normative">
         <title>Terms and definitions</title>
         <term id="term-Term1">
         <preferred><expression><name>Term1</name></expression></preferred>
                 <definition>
          <verbal-definition>
            <p id='_'>Definition</p>
          </verbal-definition>
        </definition>
        <termsource status='modified' type='authoritative'>
         <origin bibitemid="ISO2191" type="inline" citeas="">
         <localityStack>
        <locality type="section"><referenceFrom>1</referenceFrom></locality>
         </localityStack>
        </origin>
         <modification>
           <p id="_">with adjustments</p>
         </modification>
       </termsource>
       </term>
       </terms>
       </sections>
       </ietf-standard>
    OUTPUT
  end

  it "processes table attribute" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}

      [align=right]
      |===
      |A |B

      |C |D
      |===
    INPUT
      #{BLANK_HDR}
       <sections>
           <table id='_' align='right'>
             <thead>
               <tr>
                 <th valign="top" align='left'>A</th>
                 <th valign="top" align='left'>B</th>
               </tr>
             </thead>
             <tbody>
               <tr>
                 <td valign="top" align='left'>C</td>
                 <td valign="top" align='left'>D</td>
               </tr>
             </tbody>
           </table>
         </sections>
       </ietf-standard>
    OUTPUT
  end
end
