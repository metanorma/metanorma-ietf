require "spec_helper"
RSpec.describe Asciidoctor::Rfc::V3::Converter do
  it "renders areas" do
    expect(Asciidoctor.convert(<<~"INPUT", backend: :rfc3, header_footer: true)).to be_equivalent_to <<~"OUTPUT"
      = Document title
      :docName:
      Author
      :area: first_area, second_area

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
      <area>first_area</area>
      <area>second_area</area>
      </front><middle>
      <section anchor="_section_1" numbered="false">
      <name>Section 1</name>
      <t>Text</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end

  it "deals with entities in areas" do
    expect(Asciidoctor.convert(<<~"INPUT", backend: :rfc3, header_footer: true)).to be_equivalent_to <<~"OUTPUT"
      = Document title
      :docName:
      Author
      :area: first_area & second_area

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
      <area>first_area &amp; second_area</area>
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
