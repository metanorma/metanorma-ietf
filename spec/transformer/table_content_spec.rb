# frozen_string_literal: true

require "spec_helper"
require "metanorma/ietf/transformer"

# WS5b #295: table cell block content, table alignment, mixed header
# rows. Each case was dropped or lossy before the fix.
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

  it "renders block content inside cells" do
    result = convert_fragment(<<~BODY)
      <table id="t1"><thead><tr><th>H</th></tr></thead><tbody>
      <tr><td id="c1"><p>cell para</p><ul><li>cell li</li></ul></td></tr>
      </tbody></table>
    BODY

    expect(result).to include("cell para")
    expect(result).to include("cell li")
  end

  it "carries table alignment" do
    result = convert_fragment(<<~BODY)
      <table id="t2" align="left"><thead><tr><th>H</th></tr></thead>
      <tbody><tr><td>x</td></tr></tbody></table>
    BODY

    expect(result).to include('<table align="left"')
  end

  it "keeps td cells in mixed th/td header rows" do
    result = convert_fragment(<<~BODY)
      <table id="t3"><thead><tr><th>H1</th><td>H2</td></tr></thead>
      <tbody><tr><td>a</td><td>b</td></tr></tbody></table>
    BODY

    expect(result).to include("H1")
    expect(result).to include("H2")
    expect(result.scan("<td>").size).to eq(3)
  end
end
