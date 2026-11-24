# frozen_string_literal: true

require "spec_helper"
require "metanorma/ietf/transformer"

# WS5b #292: inline content conservation. Where structure is
# unrepresentable in v3, the text content must at minimum survive.
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

  it "carries emphasis inside a section title" do
    result = convert_fragment(
      '<clause id="sub"><title>Plain <em>emphasized</em> tail</title>'\
      '<p>x</p></clause>',
    )

    expect(result).to include("emphasized")
    expect(result).to include("<em>")
  end

  it "carries mixed nested inline content" do
    result = convert_fragment(
      '<p>lead <em>text <strong>nested</strong> tail</em> end</p>',
    )

    # strong inside em has no v3 home; its text must survive
    expect(result).to include("text")
    expect(result).to include("nested")
    expect(result).to include("tail")
  end

  it "carries a cross-reference inside a figure caption" do
    result = convert_fragment(<<~BODY)
      <figure id="f2"><name>see <xref target="other"/></name>
      <image src="m.png"/></figure>
    BODY

    # v3 <name> legally carries inline elements; the structure survives
    expect(result).to include(%q(<name>see <xref target="other"/></name>))
  end

  it "keeps the text of a cross-reference inside strike" do
    result = convert_fragment(
      '<p>keep <strike>cut <xref target="other">Section 2</xref> ' \
      'here</strike> end</p>',
    )

    # strike has no v3 home: text-at-minimum, descendant text included
    expect(result).to include("cut Section 2 here")
  end

  it "carries link content inside a dt" do
    result = convert_fragment(
      '<dl><dt><link target="https://example.com">site</link> name</dt>'\
      '<dd>def</dd></dl>',
    )

    expect(result).to include("site")
    expect(result).to include("name")
  end
end
