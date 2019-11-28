require "spec_helper"
RSpec.describe Asciidoctor::Rfc::V2::Converter do
  it "renders a quote as a paragraph" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
      [[verse-id]]
      [quote, attribution="quote attribution", citetitle="http://www.foo.bar"]
      Text
    INPUT
      <t anchor="verse-id">Text</t><t>-- quote attribution, http://www.foo.bar</t>
    OUTPUT
  end

  it "renders a verse" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
      [[verse-id]]
      [verse, Carl Sandburg, two lines from the poem Fog]
      The fog comes
      on little cat feet.
    INPUT
      <t anchor="verse-id">The fog comes<vspace/>
      on little cat feet.</t>
    OUTPUT
  end
end
