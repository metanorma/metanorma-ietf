require "spec_helper"
RSpec.describe Asciidoctor::Rfc::V3::Converter do
  it "renders keywords" do
    expect(Asciidoctor.convert(<<~"INPUT", backend: :rfc3, header_footer: true)).to be_equivalent_to <<~"OUTPUT"
      = Document title
      :docName:
      Author
      :keyword: first_keyword, second_keyword

      == Section 1
      Text
    INPUT
      #{XML_HDR}

      <rfc prepTime="2000-01-01T05:00:00Z" version="3" submissionType="IETF">
      <front>
      <title>Document title</title>
      <author fullname="Author">
      </author>
      <date day="1" month="January" year="2000"/>
      <keyword>first_keyword</keyword>
      <keyword>second_keyword</keyword>
      </front><middle>
      <section anchor="_section_1" numbered="false">
      <name>Section 1</name>
      <t>Text</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end
end
