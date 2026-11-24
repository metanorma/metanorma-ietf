# frozen_string_literal: true

require "spec_helper"
require "metanorma/ietf/transformer"

# WS5b #297: container children. Each container dropped its
# non-paragraph children before the fix.
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

  it "renders a ul inside a blockquote" do
    result = convert_fragment(<<~BODY)
      <quote id="q"><p>lead</p><ul><li>bq li</li></ul></quote>
    BODY

    expect(result).to include("<blockquote")
    expect(result).to include("bq li")
  end

  it "renders a ul inside an admonition" do
    # was pending: AdmonitionBlock mapped no ul/ol/dl (#297); the
    # mappings ship in metanorma-document 0.5.13
    result = convert_fragment(<<~BODY)
      <admonition type="caution"><p>careful</p><ul><li>ad li</li></ul></admonition>
    BODY

    expect(result).to include("<aside")
    expect(result).to include("CAUTION")
    expect(result).to include("ad li")
  end

  it "renders sourcecode inside a note" do
    # was pending: NoteBlock mapped no sourcecode (#297); the mapping
    # ships in metanorma-document 0.5.13
    result = convert_fragment(<<~BODY)
      <note id="note1"><p>note lead</p><sourcecode>note_code</sourcecode></note>
    BODY

    expect(result).to include("<aside")
    expect(result).to include("note lead")
    # the v3 aside admits no sourcecode element: text-at-minimum
    expect(result).to include("note_code")
  end

  it "renders a note inside an example" do
    # was pending: ExampleBlock mapped no note (#297); the mapping
    # ships in metanorma-document 0.5.13
    result = convert_fragment(<<~BODY)
      <example id="ex1"><p>example body</p>
      <note id="inner"><p>example note text</p></note></example>
    BODY

    expect(result).to include("EXAMPLE")
    expect(result).to include("example note text")
  end
end
