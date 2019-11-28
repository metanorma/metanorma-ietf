require "spec_helper"
RSpec.describe Asciidoctor::Rfc::V2::Converter do
  it "treats bcp14 macro in v2 as <strong>" do
    expect(Asciidoctor.convert(<<~"INPUT", backend: :rfc2, header_footer: true)).to be_equivalent_to <<~"OUTPUT"
      = Document title
      :abbrev: abbrev_value
      :docName:
      Author

      == Section 1
      This [bcp14]#must not# stand
    INPUT
      #{XML_HDR}

      <rfc
               submissionType="IETF">
      <front>
      <title abbrev="abbrev_value">Document title</title>
      <author fullname="Author"/>
      <date day="1" month="January" year="2000"/>
      </front><middle>
      <section anchor="_section_1" title="Section 1">
      <t>This <spanx style="strong">MUST NOT</spanx> stand</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end

  it "respects Asciidoctor inline formatting" do
    expect(Asciidoctor.convert(<<~"INPUT", backend: :rfc2, header_footer: true)).to be_equivalent_to <<~"OUTPUT"
      = Document title
      :abbrev: abbrev_value
      :docName:
      Author

      == Section 1
      _Text_ *Text* `Text` "`Text`" '`Text`' ^Superscript^ ~Subscript~
    INPUT
      #{XML_HDR}

      <rfc
               submissionType="IETF">
      <front>
      <title abbrev="abbrev_value">Document title</title>
      <author fullname="Author"/>
      <date day="1" month="January" year="2000"/>
      </front><middle>
      <section anchor="_section_1" title="Section 1">
      <t><spanx style="emph">Text</spanx> <spanx style="strong">Text</spanx> <spanx style="verb">Text</spanx> &#8220;Text&#8221; &#8216;Text&#8217; ^Superscript^ _Subscript_</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end

  it "allows suppression of smart quotes" do
    expect(Asciidoctor.convert(<<~"INPUT", backend: :rfc2, header_footer: true)).to be_equivalent_to <<~"OUTPUT"
      = Document title
      :abbrev: abbrev_value
      :docName:
      :smart-quotes: false
      Author

      == Section 1
      "`Text`" '`Text`'
    INPUT
      #{XML_HDR}

      <rfc
               submissionType="IETF">
      <front>
      <title abbrev="abbrev_value">Document title</title>
      <author fullname="Author"/>
      <date day="1" month="January" year="2000"/>
      </front><middle>
      <section anchor="_section_1" title="Section 1">
      <t>"Text" 'Text'</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end

  it "renders stem as literal" do
    expect(Asciidoctor.convert(<<~"INPUT", backend: :rfc2, header_footer: true)).to be_equivalent_to <<~"OUTPUT"
      = Document title
      :abbrev: abbrev_value
      :docName:
      Author
      :stem:

      == Section 1
      stem:[sqrt(4) = 2]
    INPUT
      #{XML_HDR}

      <rfc
               submissionType="IETF">
      <front>
      <title abbrev="abbrev_value">Document title</title>
      <author fullname="Author"/>
      <date day="1" month="January" year="2000"/>
      </front><middle>
      <section anchor="_section_1" title="Section 1">
      <t>sqrt(4) = 2</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end
  it "deals with non-Ascii characters" do
    expect(Asciidoctor.convert(<<~"INPUT", backend: :rfc2, header_footer: true)).to be_equivalent_to <<~"OUTPUT"
      = Document title
      :abbrev: abbrev_value
      :docName:
      Author

      == Section 1
      Hello René! Hello Владимир!

    INPUT
      #{XML_HDR}

      <rfc
               submissionType="IETF">
      <front>
         <title abbrev="abbrev_value">Document title</title>
         <author fullname="Author"/>
      <date day="1" month="January" year="2000"/>
      </front><middle>
      <section anchor="_section_1" title="Section 1">
         <t>Hello Ren&#233;! Hello &#1042;&#1083;&#1072;&#1076;&#1080;&#1084;&#1080;&#1088;!</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end
  it "deals with HTML entities" do
    expect(Asciidoctor.convert(<<~"INPUT", backend: :rfc2, header_footer: true)).to be_equivalent_to <<~"OUTPUT"
      = Document title
      :abbrev: abbrev_value
      :docName:
      Author

      == Section 1
      Hello &lt;&nbsp;(&amp;lt;)

      == Section 2
      Hello &lt;&nbsp;(&amp;lt;)
    INPUT
      #{XML_HDR}

      <rfc
               submissionType="IETF">
      <front>
         <title abbrev="abbrev_value">Document title</title>
         <author fullname="Author"/>
      <date day="1" month="January" year="2000"/>
      </front><middle>
      <section anchor="_section_1" title="Section 1">
         <t>Hello &lt;&#160;(&amp;lt;)</t>
      </section>
      <section anchor="_section_2" title="Section 2">
         <t>Hello &lt;&#160;(&amp;lt;)</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end
  it "renders line break" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
      == Section 1
      Hello +
      This is a line break
    INPUT
      <section anchor="_section_1" title="Section 1">
         <t>Hello<vspace/>
       This is a line break</t>
      </section>
    OUTPUT
  end
  it "removes markup within spanx" do
    expect(Asciidoctor.convert(<<~"INPUT", backend: :rfc2, header_footer: true)).to be_equivalent_to <<~"OUTPUT"
      = Document title
      :abbrev: abbrev_value
      :docName:
      Author

      == Section 1
      `This is http://www.example.com _a_ *citation*`
    INPUT
      #{XML_HDR}

      <rfc
               submissionType="IETF">
      <front>
         <title abbrev="abbrev_value">Document title</title>
         <author fullname="Author"/>
      <date day="1" month="January" year="2000"/>
      </front><middle>

      <section anchor="_section_1" title="Section 1">
       <t><spanx style="verb">This is  a citation</spanx></t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end
end
