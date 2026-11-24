# frozen_string_literal: true

require "spec_helper"
require "metanorma/ietf/transformer"

# WS5b #294: list item content conservation. Each case was dropped or
# lossy before the fix.
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

  it "emits the li anchor so xrefs to it resolve" do
    result = convert_fragment(<<~BODY)
      <ul>
        <li id="itemid"><p>anchored item</p></li>
        <li><p>xref target check <xref target="itemid"/></p></li>
      </ul>
    BODY

    expect(result).to include('anchor="itemid"')
    expect(result).to include('target="itemid"')
  end

  it "renders a nested dl under the li" do
    result = convert_fragment(<<~BODY)
      <ul><li><p>item</p>
      <dl><dt>term</dt><dd>definition</dd></dl></li></ul>
    BODY

    expect(result).to include("<dt>term</dt>")
    expect(result).to include("<dd>definition</dd>")
  end

  it "carries quote, note and figure blocks under the li" do
    result = convert_fragment(<<~BODY)
      <ul><li><p>item</p>
      <quote id="q1"><p>quoted text</p></quote>
      <note id="note1"><p>a note body</p></note>
      <figure id="fig1"><image src="m.png"/></figure>
      </li></ul>
    BODY

    expect(result).to include("quoted text")
    expect(result).to include("a note body")
    expect(result).to include("m.png")
  end

  it "keeps children in source order around a sublist" do
    result = convert_fragment(<<~BODY)
      <ul><li><p>before list</p><ul><li>inner</li></ul>
      <p>after list</p></li></ul>
    BODY

    expect(result.index("before list")).to be < result.index("inner")
    expect(result.index("inner")).to be < result.index("after list")
  end
end
