# frozen_string_literal: true

require "spec_helper"
require "metanorma/ietf/transformer"

# WS5b #293: footnote content conservation and dedup. Each case was
# dropped or lossy before the fix.
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

  it "keeps inline markup text in footnote bodies" do
    result = convert_fragment(<<~BODY)
      <p>body<fn><p>See <em>emphatic</em> and tail</p></fn> done.</p>
    BODY

    expect(result).to include("emphatic")
    expect(result).to include("tail")
  end

  it "renders list-bodied footnotes in the endnotes" do
    result = convert_fragment(<<~BODY)
      <p>body<fn><p>first para</p><ul><li>fn li one</li></ul></fn> done.</p>
    BODY

    expect(result).to include("[1]")
    expect(result).to include("fn li one")
  end

  it "keeps same-labelled distinct table footnotes distinct" do
    result = convert_fragment(<<~BODY)
      <table id="t1"><thead><tr><th>A<fn reference="a"><p>table one note</p></fn></th></tr></thead>
      <tbody><tr><td>x</td></tr></tbody></table>
      <table id="t2"><thead><tr><th>B<fn reference="a"><p>table two note</p></fn></th></tr></thead>
      <tbody><tr><td>y</td></tr></tbody></table>
    BODY

    expect(result).to include("table one note")
    expect(result).to include("table two note")
  end

  it "sets the marker off from running text" do
    result = convert_fragment(<<~BODY)
      <p>word<fn><p>note text</p></fn>.</p>
    BODY

    expect(result).to include("word [1]")
  end

  it "carries the footnote paragraph id onto the endnote" do
    result = convert_fragment(<<~BODY)
      <p>see the note <xref target="fnp1"/> and the
      note itself<fn><p id="fnp1">note body here</p></fn>.</p>
    BODY

    expect(result).to include('target="fnp1"')
    expect(result).to include('anchor="fnp1"')
    expect(result).to include("note body here")
  end
end
