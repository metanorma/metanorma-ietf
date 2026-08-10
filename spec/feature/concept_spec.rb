require "spec_helper"

# Fix-wave specs for metanorma-ietf#306: a concept in body text
# crashed the whole conversion (safe_append on the unmapped :concept
# collection); concepts now render as em + a live xref, and
# safe_append skips unmapped collections instead of raising.
RSpec.describe "IETF body-text concepts (#306)" do
  it "renders a body concept with renderterm and xref, without crashing" do
    input = <<~INPUT
      #{BLANK_HDR}
      <sections><clause id="c1"><title>Body</title>
      <p>We rely on <concept><refterm>encapsulation</refterm><renderterm>encapsulation</renderterm><xref target="c2"/></concept> here.</p>
      </clause>
      <clause id="c2"><title>Target</title><p>T.</p></clause>
      </sections>
      </iso-standard>
    INPUT
    out = nil
    expect { out = strip_guid(feature_convert(input)) }.not_to raise_error
    expect(out).to include("<em>encapsulation</em>")
    expect(out).to include('<xref target="c2"/>')
    expect(out).to include("[term defined in ")
    expect(out).not_to include("&lt;xref")
  end

  it "renders a body concept with only an xref as a live reference" do
    input = <<~INPUT
      #{BLANK_HDR}
      <sections><clause id="c1"><title>Body</title>
      <p>Before <concept><xref target="c2"/></concept> after.</p>
      </clause>
      <clause id="c2"><title>Target</title><p>T.</p></clause>
      </sections>
      </iso-standard>
    INPUT
    out = nil
    expect { out = strip_guid(feature_convert(input)) }.not_to raise_error
    expect(out).to include('[term defined in <xref target="c2"/>]')
  end

  it "safe_append skips unmapped collections instead of raising" do
    conv = Metanorma::Ietf::Transformer::IetfToRfcV3.allocate
    text = Rfcxml::V3::Text.new
    expect do
      expect do
        conv.send(:safe_append, text, :concept, Object.new)
      end.to output(/no concept collection/).to_stderr
    end.not_to raise_error
  end
end
