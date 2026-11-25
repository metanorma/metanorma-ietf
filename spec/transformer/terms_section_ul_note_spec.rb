# frozen_string_literal: true

require "spec_helper"
require "metanorma/ietf/transformer"

# metanorma-ietf#380: a terms section's lists and notes were silently
# dropped from the RFC XML — the walk carried only paragraphs, the
# dl (as of #376) and term entries
RSpec.describe Metanorma::Ietf::Transformer do
  def convert_terms(body)
    xml = <<~XML
      <ietf-standard xmlns="https://www.metanorma.org/ns/ietf" type="semantic" version="2.3.0">
      <bibdata type="standard">
      <title language="en" format="text/plain" type="main">Repro Doc</title>
      <docidentifier>1</docidentifier>
      <docnumber>1</docnumber>
      <language>en</language>
      <script>Latn</script>
      <status><stage>published</stage></status>
      <copyright><from>2026</from><owner><organization><name>IETF</name></organization></owner></copyright>
      </bibdata>
      <sections>
      <terms id="terms1" obligation="normative">
      <title>Terms and Definitions</title>
      #{body}
      </terms>
      </sections>
      </ietf-standard>
    XML
    described_class.convert(xml)
  end

  it "renders a ul inside the terms section" do
    result = convert_terms("<ul><li>terms li</li></ul>")

    expect(result).to include("terms li")
  end

  it "renders a note inside the terms section" do
    # was pending: TermsSection mapped no note (metanorma-ietf#380);
    # the mapping ships in metanorma-standoc 3.5.30
    result = convert_terms('<note id="n1"><p>terms note</p></note>')

    expect(result).to include("<aside")
    expect(result).to include("terms note")
  end
end
