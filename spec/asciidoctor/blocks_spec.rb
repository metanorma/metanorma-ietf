require "spec_helper"
require "open3"

RSpec.describe Asciidoctor::Ietf do
      it "processes paragraphs" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :ietf, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}

      [keepWithNext=true,keepWithPrevious=true]
      Hello
    INPUT
        #{BLANK_HDR}
       <sections>
       <p keepWithNext='true' keepWithPrevious='true' id='_'>Hello</p>
       </sections>
       </ietf-standard>
    OUTPUT
  end

    it "processes pass blocks" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :ietf, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      
      ++++
      <abc>X &gt; Y</abc>
      ++++
    INPUT
        #{BLANK_HDR}
       <sections>
       <abc>X &gt; Y</abc>
       </sections>
       </ietf-standard>
    OUTPUT
  end

  it "processes open blocks" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :ietf, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :ietf, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :ietf, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :draft: 1.2

      [[foreword]]
      .Foreword
      Foreword

      [reviewer=ISO,date=20170101,from=foreword,to=foreword]
      ****
      A Foreword shall appear in each document. The generic text is shown here. It does not contain requirements, recommendations or permissions.

      For further information on the Foreword, see *ISO/IEC Directives, Part 2, 2016, Clause 12.*
      ****
      INPUT
      <ietf-standard xmlns="https://open.ribose.com/standards/ietf">
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
  <doctype>Internet-Draft</doctype>
</ext>
       </bibdata>
       <sections><p id="foreword">Foreword</p>
       <review reviewer="ISO" id="_" date="20170101T00:00:00Z" from="foreword" to="foreword"><p id="_">A Foreword shall appear in each document. The generic text is shown here. It does not contain requirements, recommendations or permissions.</p>
       <p id="_">For further information on the Foreword, see <strong>ISO/IEC Directives, Part 2, 2016, Clause 12.</strong></p></review></sections>
       </ietf-standard>

      OUTPUT
  end

  it "processes term notes" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :ietf, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      == Terms and Definitions

      === Term1

      NOTE: This is a note
      INPUT
              #{BLANK_HDR}
       <sections>
         <terms id="_" obligation="normative">
         <title>Terms and definitions</title>
         <p>For the purposes of this document, the following terms and definitions apply.</p>
         <term id="_">
         <preferred>Term1</preferred>
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
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :ietf, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
         <p>No terms and definitions are listed in this document.</p>
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
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :ietf, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      == Terms and Definitions

      === Term1

      === Symbols

      NOTE: This is a note
      INPUT
              #{BLANK_HDR}
              <sections>
  <terms id="_" obligation="normative"><title>Terms, definitions, symbols and abbreviated terms</title>
<p>For the purposes of this document, the following terms and definitions apply.</p>
<term id="_">
  <preferred>Term1</preferred>
</term>
<definitions id="_">
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
      expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :ietf, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      NOTE: This is a note

      == Clause 1


      NOTE: This is a note
      INPUT
              #{BLANK_HDR}
              <preface><foreword obligation="informative">
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
      expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :ietf, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      ....
      <LITERAL>
      ....
      INPUT
      #{BLANK_HDR}
       <sections>
           <figure id="_">
        <pre id="_">&lt;LITERAL&gt;</pre>
        </figure>
       </sections>
       </ietf-standard>

      OUTPUT
    end

    it "processes simple admonitions with Asciidoc names" do
      expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :ietf, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
      expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :ietf, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
      expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :ietf, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
<p>For the purposes of this document, the following terms and definitions apply.</p>
  <term id="_">
  <preferred>Term1</preferred>

<termexample id="_">
  <p id="_">This is an example</p>
</termexample></term>
</terms>
</sections>
</ietf-standard>
      OUTPUT
    end

    it "processes term examples as plain examples in nonterm clauses" do
      expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :ietf, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
<p>No terms and definitions are listed in this document.</p>
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
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :ietf, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      == Terms and Definitions

      === Term1

      === Symbols

      [example]
      This is an example
      INPUT
              #{BLANK_HDR}
<sections> 
  <terms id="_" obligation="normative"><title>Terms, definitions, symbols and abbreviated terms</title>
<p>For the purposes of this document, the following terms and definitions apply.</p><term id="_">   
  <preferred>Term1</preferred>   
</term>  
<definitions id="_">   
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
      expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :ietf, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
      expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :ietf, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      This is a preamble

      == Section 1
      INPUT
      #{BLANK_HDR}
             <preface><foreword obligation="informative">
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
      expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :ietf, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      .Preamble
      This is a preamble

      == Section 1
      INPUT
      #{BLANK_HDR}
             <preface><foreword obligation="informative">
         <title>Preamble</title>
         <p id="_">This is a preamble</p>
       </foreword></preface><sections>
       <clause id="_" inline-header="false" obligation="normative">
         <title>Section 1</title>
       </clause></sections>
       </ietf-standard>
      OUTPUT
    end

  it "processes subfigures" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :ietf, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      [[figureC-2]]
      .Stages of gelatinization
      ====
      .Initial stages: No grains are fully gelatinized (ungelatinized starch granules are visible inside the kernels)
      image::spec/examples/rice_images/rice_image3_1.png[]

      .Intermediate stages: Some fully gelatinized kernels are visible
      image::spec/examples/rice_images/rice_image3_2.png[]

      .Final stages: All kernels are fully gelatinized
      image::spec/examples/rice_images/rice_image3_3.png[]
      ====
    INPUT
       #{BLANK_HDR}
              <sections>
         <figure id="figureC-2"><name>Stages of gelatinization</name><figure id="_">
         <name>Initial stages: No grains are fully gelatinized (ungelatinized starch granules are visible inside the kernels)</name>
         <image src="spec/examples/rice_images/rice_image3_1.png" id="_" mimetype="image/png" height="auto" width="auto"/>
       </figure>
       <figure id="_">
         <name>Intermediate stages: Some fully gelatinized kernels are visible</name>
         <image src="spec/examples/rice_images/rice_image3_2.png" id="_" mimetype="image/png" height="auto" width="auto"/>
       </figure>
       <figure id="_">
         <name>Final stages: All kernels are fully gelatinized</name>
         <image src="spec/examples/rice_images/rice_image3_3.png" id="_" mimetype="image/png" height="auto" width="auto"/>
       </figure></figure>
       </sections>
       </ietf-standard>
    OUTPUT
  end

    it "processes figures within examples" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :ietf, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      [[figureC-2]]
      .Stages of gelatinization
      ====
      .Initial stages: No grains are fully gelatinized (ungelatinized starch granules are visible inside the kernels)
      image::spec/examples/rice_images/rice_image3_1.png[]

      Text

      .Intermediate stages: Some fully gelatinized kernels are visible
      image::spec/examples/rice_images/rice_image3_2.png[]

      .Final stages: All kernels are fully gelatinized
      image::spec/examples/rice_images/rice_image3_3.png[]
      ====
    INPUT
       #{BLANK_HDR}
              <sections>
         <example id="figureC-2"><name>Stages of gelatinization</name><figure id="_">
         <name>Initial stages: No grains are fully gelatinized (ungelatinized starch granules are visible inside the kernels)</name>
         <image src="spec/examples/rice_images/rice_image3_1.png" id="_" mimetype="image/png" height="auto" width="auto"/>
       </figure>
       <p id="_">Text</p>
       <figure id="_">
         <name>Intermediate stages: Some fully gelatinized kernels are visible</name>
         <image src="spec/examples/rice_images/rice_image3_2.png" id="_" mimetype="image/png" height="auto" width="auto"/>
       </figure>
       <figure id="_">
         <name>Final stages: All kernels are fully gelatinized</name>
         <image src="spec/examples/rice_images/rice_image3_3.png" id="_" mimetype="image/png" height="auto" width="auto"/>
       </figure></example>
       </sections>
       </ietf-standard>
    OUTPUT
  end


    it "processes images" do
      expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :ietf, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      [%unnumbered]
      .Split-it-right sample divider
      image::spec/examples/rice_images/rice_image1.png[alttext]

      INPUT
      #{BLANK_HDR}
              <sections>
         <figure id="_" unnumbered="true">
         <name>Split-it-right sample divider</name>
                  <image src="spec/examples/rice_images/rice_image1.png" id="_" mimetype="image/png" height="auto" width="auto" alt="alttext"/>
       </figure>
       </sections>
       </ietf-standard>
      OUTPUT
    end

    it "accepts attributes on images" do
      expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :ietf, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      [height=4,width=3,alt="IMAGE",filename="riceimg1.png",titleattr="TITLE"]
      .Caption
      image::spec/examples/rice_images/rice_image1.png[]

      INPUT
      #{BLANK_HDR}
              <sections>
         <figure id="_"><name>Caption</name>
         <image src="spec/examples/rice_images/rice_image1.png" id="_" mimetype="image/png" height="4" width="3" title="TITLE" alt="IMAGE" filename="riceimg1.png"/>
       </figure>
       </sections>
       </ietf-standard>
      OUTPUT
    end

        it "processes inline images with width and height attributes on images" do
      expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :ietf, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      Hello image:spec/examples/rice_images/rice_image1.png[alt, 4, 3], how are you?

      INPUT
      #{BLANK_HDR}
              <sections>
          <p id="_">Hello <image src="spec/examples/rice_images/rice_image1.png" id="_" mimetype="image/png" height="3" width="4" alt="alt"/>, how are you?</p>
       </sections>
       </ietf-standard>
      OUTPUT
    end

    it "processes blockquotes" do
      expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :ietf, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      [quote, ISO, "ISO7301,section 1"]
      ____
      Block quotation
      ____
      INPUT
      #{BLANK_HDR}
       <sections>
         <quote id="_">
         <source type="inline" bibitemid="ISO7301" citeas=""><locality type="section"><referenceFrom>1</referenceFrom></locality></source>
         <author>ISO</author>
         <p id="_">Block quotation</p>
       </quote>
       </sections>
       </ietf-standard>
      OUTPUT
    end

    it "processes source code" do
      expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :ietf, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      .Caption
      [source,ruby,filename=sourcecode1.rb]
      --
      puts "Hello, world."
      %w{a b c}.each do |x|
        puts x
      end
      --
      INPUT
      #{BLANK_HDR}
       <sections>
         <sourcecode id="_" lang="ruby" filename="sourcecode1.rb"><name>Caption</name>puts "Hello, world."
       %w{a b c}.each do |x|
         puts x
       end</sourcecode>
       </sections>
       </ietf-standard>
      OUTPUT
    end

    it "processes callouts" do
      expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :ietf, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
      expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :ietf, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      == Terms and Definitions

      === Term1

      [.source]
      <<ISO2191,section=1>>
      INPUT
      #{BLANK_HDR}
       <sections>
         <terms id="_" obligation="normative">
         <title>Terms and definitions</title><p>For the purposes of this document,
       the following terms and definitions apply.</p>
         <term id="_">
         <preferred>Term1</preferred>
         <termsource status="identical">
         <origin bibitemid="ISO2191" type="inline" citeas=""><locality type="section"><referenceFrom>1</referenceFrom></locality></origin>
       </termsource>
       </term>
       </terms>
       </sections>
       </ietf-standard>
      OUTPUT
    end

    it "processes modified term sources" do
      expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :ietf, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      == Terms and Definitions

      === Term1

      [.source]
      <<ISO2191,section=1>>, with adjustments
      INPUT
      #{BLANK_HDR}
            <sections>
         <terms id="_" obligation="normative">
         <title>Terms and definitions</title>
         <p>For the purposes of this document,
       the following terms and definitions apply.</p>
         <term id="_">
         <preferred>Term1</preferred>
         <termsource status="modified">
         <origin bibitemid="ISO2191" type="inline" citeas=""><locality type="section"><referenceFrom>1</referenceFrom></locality></origin>
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

        it "processes recommendation" do
    input = <<~"INPUT"
      #{ASCIIDOC_BLANK_HDR}
      [.recommendation,label="/ogc/recommendation/wfs/2",subject="user",inherit="/ss/584/2015/level/1",options="unnumbered"]
      ====
      I recommend this
      ====
    INPUT
             output = <<~"OUTPUT"
            #{BLANK_HDR}
       <sections>
  <recommendation id="_" unnumbered="true">
  <label>/ogc/recommendation/wfs/2</label>
<subject>user</subject>
<inherit>/ss/584/2015/level/1</inherit>
  <description><p id="_">I recommend this</p></description>
</recommendation>
       </sections>
       </ietf-standard>
    OUTPUT

    expect(xmlpp(strip_guid(Asciidoctor.convert(input, backend: :ietf, header_footer: true)))).to be_equivalent_to xmlpp(output)
  end

    it "processes requirement" do
    input = <<~"INPUT"
      #{ASCIIDOC_BLANK_HDR}
      [.requirement,subsequence="A"]
      .Title
      ====
      I recommend this
      ====
    INPUT
             output = <<~"OUTPUT"
            #{BLANK_HDR}
       <sections>
  <requirement id="_" subsequence="A"><title>Title</title>
  <description><p id="_">I recommend this</p></description>
</requirement>
       </sections>
       </ietf-standard>
    OUTPUT

    expect(xmlpp(strip_guid(Asciidoctor.convert(input, backend: :ietf, header_footer: true)))).to be_equivalent_to xmlpp(output)
  end

        it "processes permission" do
    input = <<~"INPUT"
      #{ASCIIDOC_BLANK_HDR}
      [.permission]
      ====
      I recommend this
      ====
    INPUT
             output = <<~"OUTPUT"
            #{BLANK_HDR}
       <sections>
  <permission id="_">
  <description><p id="_">I recommend this</p></description>
</permission>
       </sections>
       </ietf-standard>
    OUTPUT

    expect(xmlpp(strip_guid(Asciidoctor.convert(input, backend: :ietf, header_footer: true)))).to be_equivalent_to xmlpp(output)
  end


       it "processes nested permissions" do
    input = <<~"INPUT"
      #{ASCIIDOC_BLANK_HDR}
      [.permission]
      ====
      I permit this

      =====
      Example 2
      =====

      [.permission]
      =====
      I also permit this
      =====
      ====
    INPUT
             output = <<~"OUTPUT"
            #{BLANK_HDR}
       <sections>
         <permission id="_"><description><p id="_">I permit this</p>
<example id="_">
  <p id="_">Example 2</p>
</example></description>
<permission id="_">
  <description><p id="_">I also permit this</p></description>
</permission></permission>
</sections>
</ietf-standard>
    OUTPUT

    expect(xmlpp(strip_guid(Asciidoctor.convert(input, backend: :ietf, header_footer: true)))).to be_equivalent_to xmlpp(output)
  end

        it "processes recommendation with internal markup of structure" do
    input = <<~"INPUT"
      #{ASCIIDOC_BLANK_HDR}
      [.recommendation,label="/ogc/recommendation/wfs/2",subject="user",classification="control-class:Technical;priority:P0;family:System and Communications Protection,System and Communications Protocols",obligation="permission,recommendation",filename="reqt1.rq"]
      ====
      I recommend _this_.

      [.specification,type="tabular"]
      --
      This is the object of the recommendation:
      |===
      |Object |Value
      |Mission | Accomplished
      |===
      -- 

      As for the measurement targets,

      [.measurement-target]
      --
      The measurement target shall be measured as:
      [stem]
      ++++
      r/1 = 0
      ++++
      --

      [.verification]
      --
      The following code will be run for verification:

      [source,CoreRoot]
      ----
      CoreRoot(success): HttpResponse
      if (success)
        recommendation(label: success-response)
      end
      ----
      --
      
      [.import%exclude]
      --
      [source,CoreRoot]
      ----
      success-response()
      ----
      --
      ====
    INPUT
             output = <<~"OUTPUT"
            #{BLANK_HDR}
       <sections>
       <recommendation id="_"  obligation="permission,recommendation" filename="reqt1.rq"><label>/ogc/recommendation/wfs/2</label><subject>user</subject>
<classification><tag>control-class</tag><value>Technical</value></classification><classification><tag>priority</tag><value>P0</value></classification><classification><tag>family</tag><value>System and Communications Protection</value></classification><classification><tag>family</tag><value>System and Communications Protocols</value></classification>
        <description><p id="_">I recommend <em>this</em>.</p>
       </description><specification exclude="false" type="tabular"><p id="_">This is the object of the recommendation:</p><table id="_">  <tbody>    <tr>      <td align="left">Object</td>      <td align="left">Value</td>    </tr>    <tr>      <td align="left">Mission</td>      <td align="left">Accomplished</td>    </tr>  </tbody></table></specification><description>
       <p id="_">As for the measurement targets,</p>
       </description><measurement-target exclude="false"><p id="_">The measurement target shall be measured as:</p><formula id="_">  <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mfrac><mi>r</mi><mn>1</mn></mfrac><mo>=</mo><mn>0</mn></math></stem></formula></measurement-target>
       <verification exclude="false"><p id="_">The following code will be run for verification:</p><sourcecode  lang="CoreRoot" id="_">CoreRoot(success): HttpResponse
if (success)
  recommendation(label: success-response)
end</sourcecode></verification>
       <import exclude="true">  <sourcecode  lang="CoreRoot" id="_">success-response()</sourcecode></import></recommendation>
       </sections>
       </ietf-standard>
    OUTPUT

    expect(xmlpp(strip_guid(Asciidoctor.convert(input, backend: :ietf, header_footer: true)))).to be_equivalent_to xmlpp(output)
  end

end
