# frozen_string_literal: true

require "spec_helper"
require "metanorma/ietf/transformer"

# WS5b #296: figure content conservation. Each case was dropped or
# lossy before the fix; specs use raw-semantic parses (no presentation
# stage) through the transformer's fallback path.
RSpec.describe Metanorma::Ietf::Transformer do
  def convert_fragment(body)
    xml = <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc">
        <sections><clause id="c"><title>F</title>
        #{body}
        </clause></sections>
      </metanorma>
    XML
    described_class.convert(xml, presentation: false)
  end

  it "renders subfigures into the parent figure" do
    result = convert_fragment(<<~BODY)
      <figure id="parent"><name>Parent</name>
        <figure id="sub1"><name>Sub One</name><image src="a.png" alt="a"/></figure>
        <figure id="sub2"><name>Sub Two</name><image src="b.png" alt="b"/></figure>
      </figure>
    BODY

    expect(result).to include("Sub One")
    expect(result).to include("Sub Two")
    expect(result).to include("b.png")
    # subfigures fold into the parent: captions ride the artworks,
    # one <figure> carries them all
    expect(result.scan(/<figure[ >]/).size).to eq(1)
    expect(result.scan("<artwork").size).to eq(2)
  end

  it "carries figure key and surrounding paragraphs" do
    result = convert_fragment(<<~BODY)
      <figure id="f2"><name>Fig</name>
        <p>before the art</p>
        <image src="m.png"/>
        <dl><dt>k</dt><dd>v</dd></dl>
        <p>after the art</p>
      </figure>
    BODY

    expect(result).to include("<preamble>")
    expect(result).to include("before the art")
    expect(result).to include("<postamble>")
    expect(result).to include("after the art")
    expect(result).to include("k: v")
  end

  it "renders <source> citations through the shared bracket" do
    result = convert_fragment(<<~BODY)
      <figure id="f3"><name>Fig</name><image src="m.png"/>
      <source type="bibliographic">
      <origin bibitemid="rfc1234" type="inline"/>
      </source></figure>
    BODY

    expect(result).to include("[SOURCE: ")
    expect(result).to include(%q(target="rfc1234"))
    expect(result).to include("]")
  end

  it "carries the legacy @source attribute as a SOURCE bracket" do
    result = convert_fragment(
      '<figure id="f3" source="RFC 4321"><image src="m.png"/></figure>',
    )

    expect(result).to include("[SOURCE: RFC 4321]")
  end

  it "recovers inline images queued in list items" do
    result = convert_fragment(<<~BODY)
      <ul><li><p>item one<image src="b.png" mimetype="image/png"/></p></li></ul>
    BODY

    expect(result).to include("<figure>")
    expect(result).to include("b.png")
    expect(result).not_to include("[IMAGE")
  end

  it "recovers inline images queued in paragraphs" do
    result = convert_fragment(<<~BODY)
      <p>lead<image src="a.png" mimetype="image/png"/></p>
    BODY

    expect(result).to include("<figure>")
    expect(result).to include("a.png")
    expect(result).not_to include("[IMAGE")
  end

  it "keeps anchor, align and sizing on inline-image artwork" do
    result = convert_fragment(<<~BODY)
      <figure id="f5"><image src="m.png" id="img1" align="left"
        width="40%" height="20%"/></figure>
    BODY

    expect(result).to include('anchor="img1"')
    expect(result).to include('align="left"')
    expect(result).to include('width="40%"')
    expect(result).to include('height="20%"')
  end
end
