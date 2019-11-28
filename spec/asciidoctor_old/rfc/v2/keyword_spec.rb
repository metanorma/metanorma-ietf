require "spec_helper"
RSpec.describe Asciidoctor::Rfc::V2::Converter do
  it "renders keywords" do
    expect(Asciidoctor.convert(<<~"INPUT", backend: :rfc2, header_footer: true)).to be_equivalent_to <<~"OUTPUT"
      = Document title
      :docName:
      Author
      :keyword: first_keyword, second_keyword

      == Section 1
      text
    INPUT
      #{XML_HDR}

      <rfc
               submissionType="IETF">
      <front>
      <title>Document title</title>
      <author fullname="Author"/>
      <date day="1" month="January" year="2000"/>
      <keyword>first_keyword</keyword><keyword>second_keyword</keyword>
      </front><middle>
      <section anchor="_section_1" title="Section 1">

         <t>text</t>

      </section>
      </middle>
      </rfc>
     OUTPUT
  end
  it "deals with entities in keywords" do
    expect(Asciidoctor.convert(<<~"INPUT", backend: :rfc2, header_footer: true)).to be_equivalent_to <<~"OUTPUT"
      = Document title
      :docName:
      Author
      :keyword: first_keyword & second_keyword

      == Section 1
      text
    INPUT
      #{XML_HDR}

      <rfc
               submissionType="IETF">
      <front>
      <title>Document title</title>
      <author fullname="Author"/>
      <date day="1" month="January" year="2000"/>
      <keyword>first_keyword &amp; second_keyword</keyword>
      </front><middle>
      <section anchor="_section_1" title="Section 1">

         <t>text</t>

      </section>
      </middle>
      </rfc>
     OUTPUT
  end
end
