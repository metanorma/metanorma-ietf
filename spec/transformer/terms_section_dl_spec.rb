# frozen_string_literal: true

require "spec_helper"
require "metanorma/ietf/transformer"

# metanorma-ietf#376: a bare <dl> directly inside a "Terms and
# Definitions" section was silently dropped from the RFC XML - the
# transformer walked paragraphs, terms and nested sections but never
# definition lists
RSpec.describe Metanorma::Ietf::Transformer do
  let(:terms_xml) do
    <<~XML
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
      <p>The key words MUST are to be interpreted as described in RFC 2119.</p>
      <dl id="d1">
      <dt>Time-Stamping Unit</dt>
      <dd><p>As defined in RFC 3628.</p></dd>
      <dt>Merkle Tree</dt>
      <dd><p>As defined in RFC 6962, section 2.1.</p></dd>
      </dl>
      </terms>
      </sections>
      </ietf-standard>
    XML
  end

  it "renders the terms-section definition list" do
    # was pending: TermsSection mapped no dl (metanorma-ietf#376);
    # the mapping ships in metanorma-standoc 3.5.28
    result = described_class.convert(terms_xml)

    expect(result).to include("<dl")
    expect(result).to include("<dt>Time-Stamping Unit</dt>")
    expect(result).to include("As defined in RFC 3628.")
    expect(result).to include("As defined in RFC 6962, section 2.1.")
    expect(result).to include("The key words MUST")
  end
end
