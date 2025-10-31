require "spec_helper"
require "open3"

RSpec.describe Metanorma::Ietf do
  it "processes paragraphs" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}

      [keepWithNext=true,keepWithPrevious=true,indent=5]
      Hello
    INPUT
    output = <<~OUTPUT
       #{BLANK_HDR}
      <sections>
      <p keep-with-next='true' keep-with-previous='true' indent='5' id='_'>Hello</p>
      </sections>
      </metanorma>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes open blocks" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      --
      x

      y

      z
      --
    INPUT
    output = <<~OUTPUT
       #{BLANK_HDR}
      <sections><p id="_">x</p>
      <p id="_">y</p>
      <p id="_">z</p></sections>
      </metanorma>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes annotation blocks" do
    input = <<~INPUT
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:

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
    output = <<~OUTPUT
            <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" version="#{Metanorma::Ietf::VERSION}" flavor="ietf">
             <bibdata type="standard">
               <title language="en" type="main">Document title</title>
      <contributor>
                   <role type='publisher'/>
                   <organization>
                     <name>Internet Engineering Task Force</name>
                     <abbreviation>IETF</abbreviation>
                   </organization>
                 </contributor>
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
                 <flavor>ietf</flavor>
        <ipr>trust200902</ipr>
        <pi>
        <tocinclude>yes</tocinclude>
      </pi>
      </ext>
             </bibdata>
                       <sections>
             <p id="_" anchor="foreword">Foreword</p>
          </sections>
          <annotation-container>
             <annotation id="_" reviewer="ISO" date="20170101T00:00:00Z" type="review" display="false" from="foreword" to="foreword">
                <name id="_">Title</name>
                <p id="_">A Foreword shall appear in each document. The generic text is shown here. It does not contain requirements, recommendations or permissions.</p>
                <p id="_">
                   For further information on the Foreword, see
                   <strong>ISO/IEC Directives, Part 2, 2016, Clause 12.</strong>
                </p>
             </annotation>
          </annotation-container>
       </metanorma>
    OUTPUT
    xml = Nokogiri::XML(Asciidoctor.convert(input, *OPTIONS))
    xml.at("//xmlns:metanorma-extension").remove
    expect(Canon.format_xml(strip_guid(xml.to_xml)))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes term notes" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      == Terms and Definitions

      === Term1

      NOTE: This is a note
    INPUT
    output = <<~OUTPUT
             #{BLANK_HDR}
      <sections>
        <terms id="_" obligation="normative">
        <title id="_">Terms and definitions</title>
        <term id="_" anchor="term-Term1">
        <preferred><expression><name>Term1</name></expression></preferred>
        <termnote id="_">
        <p id="_">This is a note</p>
      </termnote>
      </term>
      </terms>
      </sections>
      </metanorma>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes term notes as plain notes in nonterm clauses" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      == Terms and Definitions

      [.nonterm]
      === Term1

      NOTE: This is a note
    INPUT
    output = <<~OUTPUT
                    #{BLANK_HDR}
                    <sections>
        <terms id="_" obligation="normative">
        <title id="_">Terms and Definitions</title>
        <clause id="_" inline-header="false" obligation="normative">
        <title id="_">Term1</title>
        <note id="_">
        <p id="_">This is a note</p>
      </note>
      </clause>
      </terms>
      </sections>
      </metanorma>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes term notes as plain notes in definitions subclauses of terms & definitions" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      == Terms and Definitions

      === Term1

      === Symbols

      NOTE: This is a note
    INPUT
    output = <<~OUTPUT
                    #{BLANK_HDR}
                    <sections>
        <terms id="_" obligation="normative">
        <title id="_">Terms, definitions and symbols</title>
      <term id="_" anchor="term-Term1">
        <preferred><expression><name>Term1</name></expression></preferred>
      </term>
      <definitions id="_" obligation="normative" type="symbols">
        <title id="_">Symbols</title>
        <note id="_">
        <p id="_">This is a note</p>
      </note>
      </definitions></terms>
      </sections>
      </metanorma>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes notes" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      NOTE: This is a note

      == Clause 1


      NOTE: This is a note
    INPUT
    output = <<~OUTPUT
             #{BLANK_HDR}
             <preface><foreword id="_" obligation="informative">
        <title id="_">Foreword</title>
        <note id="_">
        <p id="_">This is a note</p>
      </note>
      </foreword></preface><sections>
      <clause id="_" inline-header="false" obligation="normative">
        <title id="_">Clause 1</title>
        <note id="_">
        <p id="_">This is a note</p>
      </note>
      </clause></sections>

      </metanorma>

    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes literals" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      [[lit]]
      [align=left,alt=hello]
      ....
      <LITERAL>
      ....
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
       <sections>
           <figure id="_" anchor="lit">
        <pre align='left' alt='hello'>&lt;LITERAL&gt;</pre>
        </figure>
       </sections>
       </metanorma>

    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes simple admonitions with Asciidoc names" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      CAUTION: Only use paddy or parboiled rice for the determination of husked rice yield.
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
       <sections>
         <admonition id="_" type="caution">
         <p id="_">Only use paddy or parboiled rice for the determination of husked rice yield.</p>
       </admonition>
       </sections>
       </metanorma>

    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes complex admonitions with non-Asciidoc names" do
    input = <<~INPUT
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
    output = <<~OUTPUT
      #{BLANK_HDR}
      <sections>
         <admonition id="_" type="safety precautions"><name id="_">Precautions</name><p id="_">While werewolves are hardy community members, keep in mind the following dietary concerns:</p>
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
       </metanorma>

    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes term examples" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      == Terms and Definitions

      === Term1

      [example]
      This is an example
    INPUT
    output = <<~OUTPUT
            #{BLANK_HDR}
            <sections>
        <terms id="_" obligation="normative">
        <title id="_">Terms and definitions</title>
        <term id="_" anchor="term-Term1">
        <preferred><expression><name>Term1</name></expression></preferred>
      <termexample id="_">
        <p id="_">This is an example</p>
      </termexample></term>
      </terms>
      </sections>
      </metanorma>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes term examples as plain examples in nonterm clauses" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      == Terms and Definitions

      [.nonterm]
      === Term1

      [example]
      This is an example
    INPUT
    output = <<~OUTPUT
            #{BLANK_HDR}
      <sections>
        <terms id="_" obligation="normative">
        <title id="_">Terms and Definitions</title>
        <clause id="_" inline-header="false" obligation="normative">
        <title id="_">Term1</title>
        <example id="_">
        <p id="_">This is an example</p>
      </example>
      </clause>
      </terms>
      </sections>
      </metanorma>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes term examples as plain examples in definitions subclauses of terms & definitions" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      == Terms and Definitions

      === Term1

      === Symbols

      [example]
      This is an example
    INPUT
    output = <<~OUTPUT
                    #{BLANK_HDR}
      <sections>
        <terms id="_" obligation="normative">
        <title id="_">Terms, definitions and symbols</title>
      <term id="_" anchor="term-Term1">
        <preferred><expression><name>Term1</name></expression></preferred>
      </term>
      <definitions id="_" obligation="normative" type="symbols">
        <title id="_">Symbols</title>
        <example id="_">
        <p id="_">This is an example</p>
      </example>
      </definitions></terms>
      </sections>
      </metanorma>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes examples" do
    input = <<~INPUT
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
    output = <<~OUTPUT
      #{BLANK_HDR}
       <sections>
         <example id="_" subsequence="A">
         <name id="_">Title</name>
        <p id="_">This is an example</p>
       <p id="_">Amen</p></example>
         <example id="_" unnumbered="true"><p id="_">This is another example</p></example>
       </sections>
       </metanorma>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes preambles" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      This is a preamble

      == Section 1
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
             <preface><foreword id="_" obligation="informative">
         <title id="_">Foreword</title>
         <p id="_">This is a preamble</p>
       </foreword></preface><sections>
       <clause id="_" inline-header="false" obligation="normative">
         <title id="_">Section 1</title>
       </clause></sections>
       </metanorma>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes preambles with titles" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      .Preamble
      This is a preamble

      == Section 1
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
             <preface><foreword id="_" obligation="informative">
         <title id="_">Foreword</title>
         <p id="_">This is a preamble</p>
       </foreword></preface><sections>
       <clause id="_" inline-header="false" obligation="normative">
         <title id="_">Section 1</title>
       </clause></sections>
       </metanorma>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "accepts attributes on images" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      [height=4,width=3,alt="IMAGE",filename="riceimg1.png",titleattr="TITLE",align=left]
      .Caption
      image::spec/assets/rice_image1.png[]

    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
              <sections>
         <figure id="_" width="3"><name id="_">Caption</name>
         <image src="spec/assets/rice_image1.png" id="_" mimetype="image/png" height="4" width="3" title="TITLE" alt="IMAGE" filename="riceimg1.png" align="left"/>
       </figure>
       </sections>
       </metanorma>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes blockquotes" do
    input = <<~INPUT
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
    output = <<~OUTPUT
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
             </metanorma>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes source code" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      .Caption
      [source,ruby,filename=sourcecode1.rb,markers=true]
      --
      puts "Hello, world."
      %w{a b c}.each do |x|
        puts x
      end
      {{{<<RFC4918,section=14.24>>}}}
      {{{<<RFC4918,section=14.24,Hello>>}}}
      {{{http://www.example.com[]}}}
      {{{http://www.example.com[example]}}}
      {{{<<A,Goodbye>>}}}
      {{{<<A,Goodbye>>}}}
      --

      [source,ruby,src="http://www.example.com"]
      --
      --

      [[A]]
      [bibliography]
      == Bibliography

      * [[[RFC4918,RFC 4918]]]
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
        <preface>
             <foreword id="_" obligation="informative">
                <title id="_">Foreword</title>
                <sourcecode id="_" lang="ruby" filename="sourcecode1.rb" markers="true">
                   <name id="_">Caption</name>
                   <body>
                      puts "Hello, world." %w{a b c}.each do |x| puts x end
                      <eref type="inline" bibitemid="RFC4918" citeas="RFC 4918">
                         <localityStack>
                            <locality type="section">
                               <referenceFrom>14.24</referenceFrom>
                            </locality>
                         </localityStack>
                      </eref>
                      <eref type="inline" bibitemid="RFC4918" citeas="RFC 4918">
                         <localityStack>
                            <locality type="section">
                               <referenceFrom>14.24</referenceFrom>
                            </locality>
                         </localityStack>
                         <display-text>Hello</display-text>
                      </eref>
                      <link target="http://www.example.com"/>
                      <link target="http://www.example.com">example</link>
                      <xref target="A">
                         <display-text>Goodbye</display-text>
                      </xref>
                      <xref target="A">
                         <display-text>Goodbye</display-text>
                      </xref>
                   </body>
                </sourcecode>
                <sourcecode id="_" lang="ruby" src="http://www.example.com">
                   <body/>
                </sourcecode>
             </foreword>
          </preface>
          <sections>

       </sections>
          <bibliography>
             <references id="_" anchor="A" normative="false" obligation="informative">
                <title id="_">Bibliography</title>
                <bibitem id="_" anchor="RFC4918">
                   <formattedref format="application/x-isodoc+xml">[NO INFORMATION AVAILABLE]</formattedref>
                   <docidentifier>RFC 4918</docidentifier>
                   <docnumber>4918</docnumber>
                   <language>en</language>
                   <script>Latn</script>
                </bibitem>
             </references>
          </bibliography>
       </metanorma>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes callouts" do
    input = <<~INPUT
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
    output = <<~OUTPUT
      #{BLANK_HDR}
              <sections><sourcecode id="_" lang="ruby"><body>puts "Hello, world." <callout target="_">1</callout>

       %w{a b c}.each do |x|
         puts x <callout target="_">2</callout>
       end</body><callout-annotation id="_" anchor="_">
         <p id="_">This is one callout</p>
       </callout-annotation><callout-annotation id="_" anchor="_">
         <p id="_">This is another callout</p>
       </callout-annotation></sourcecode>
       </sections>
       </metanorma>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes unmodified term sources" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      == Terms and Definitions

      === Term1

      Definition

      [.source]
      <<ISO2191,section=1>>
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
       <sections>
         <terms id="_" obligation="normative">
         <title id="_">Terms and definitions</title>
         <term id="_" anchor="term-Term1">
         <preferred><expression><name>Term1</name></expression></preferred>
                 <definition id="_">
          <verbal-definition id="_">
            <p id='_'>Definition</p>
          </verbal-definition>
        </definition>
        <source status='identical' type='authoritative'>
        <origin bibitemid="ISO2191" type="inline" citeas="">
         <localityStack>
        <locality type="section"><referenceFrom>1</referenceFrom></locality>
         </localityStack>
        </origin>
       </source>
       </term>
       </terms>
       </sections>
       </metanorma>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes modified term sources" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      == Terms and Definitions

      === Term1

      Definition

      [.source]
      <<ISO2191,section=1>>, with adjustments
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
            <sections>
         <terms id="_" obligation="normative">
         <title id="_">Terms and definitions</title>
         <term id="_" anchor="term-Term1">
         <preferred><expression><name>Term1</name></expression></preferred>
                 <definition id="_">
          <verbal-definition id="_">
            <p id='_'>Definition</p>
          </verbal-definition>
        </definition>
        <source status='modified' type='authoritative'>
         <origin bibitemid="ISO2191" type="inline" citeas="">
         <localityStack>
        <locality type="section"><referenceFrom>1</referenceFrom></locality>
         </localityStack>
        </origin>
         <modification>
           <p id="_">with adjustments</p>
         </modification>
       </source>
       </term>
       </terms>
       </sections>
       </metanorma>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "processes table attribute" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}

      [align=right]
      |===
      |A |B

      |C |D
      |===
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
       <sections>
           <table id='_' align='right'>
             <thead>
               <tr id="_">
                 <th id="_" valign="top" align='left'>A</th>
                 <th id="_" valign="top" align='left'>B</th>
               </tr>
             </thead>
             <tbody>
               <tr id="_">
                 <td id="_" valign="top" align='left'>C</td>
                 <td id="_" valign="top" align='left'>D</td>
               </tr>
             </tbody>
           </table>
         </sections>
       </metanorma>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end
end
