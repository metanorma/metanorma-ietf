require "spec_helper"
RSpec.describe Asciidoctor::Rfc::V3::Converter do
  it "renders a listing" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      [[literal-id]]
      .filename
      [align=left,alt=alt_text]
      ....
        Literal contents.
      ....
    INPUT
      <figure>
      <artwork anchor="literal-id" align="left" name="filename" type="ascii-art" alt="alt_text"><![CDATA[
        Literal contents.
      ]]></artwork>
      </figure>
    OUTPUT
  end
  it "ignores callouts" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      [[literal-id]]
      .filename
      [align=left,alt=alt_text]
      ....
        Literal contents.
      ....
      <1> This is a callout
    INPUT
      <figure>
      <artwork anchor="literal-id" align="left" name="filename" type="ascii-art" alt="alt_text"><![CDATA[
        Literal contents.
      ]]></artwork>
      </figure>
    OUTPUT
  end
  it "renders stem as a literal" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      :stem:
      [stem]
      ++++
      sqrt(4) = 2
      ++++
    INPUT
      <figure>
      <artwork type="ascii-art" align="center"><![CDATA[
      sqrt(4) = 2
      ]]></artwork>
      </figure>
    OUTPUT
  end
  it "renders stem as a literal within an example" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      :stem:

      [#id]
      ====
      [stem]
      ++++
      sqrt(4) = 2
      ++++
      ====
    INPUT
      <figure anchor="id">
      <artwork type="ascii-art" align="center"><![CDATA[
      sqrt(4) = 2
      ]]></artwork>
      </figure>
    OUTPUT
  end
end
