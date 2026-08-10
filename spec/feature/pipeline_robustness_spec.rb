require "spec_helper"

# Fix-wave specs for metanorma-ietf#302 (pipeline robustness): anchor
# vs xref-target NCName consistency, and the refcontent
# delete-inside-each iteration bug. The quarantine and processor-leg
# ampersand-escape halves of #302 are specced in
# spec/metanorma/processor_spec.rb.
RSpec.describe "IETF pipeline robustness (#302)" do
  it "sanitises '#'-carrying anchors and their xref targets consistently" do
    input = <<~INPUT
      #{BLANK_HDR}
      <sections><clause id="RFC5234#section-2"><title>Target</title>
      <p id="p1">T.</p></clause>
      <clause id="c1"><title>Body</title>
      <p id="p2">See <xref target="RFC5234#section-2"/>.</p>
      </clause></sections>
      </iso-standard>
    INPUT
    out = strip_guid(feature_convert(input))
    expect(out).to include('anchor="RFC5234_section-2"')
    expect(out).to include('<xref target="RFC5234_section-2"/>')
    expect(out).not_to include("RFC5234#section-2")
  end

  it "removes consecutive empty refcontents" do
    conv = Metanorma::Ietf::Transformer::IetfToRfcV3.allocate
    ref = Rfcxml::V3::Reference.new
    empty1 = Rfcxml::V3::Refcontent.new
    empty1.content = [" "]
    empty2 = Rfcxml::V3::Refcontent.new
    empty2.content = [""]
    full = Rfcxml::V3::Refcontent.new
    full.content = [" ISO 2002 "]
    ref.refcontent = [empty1, empty2, full]
    conv.send(:biblio_refcontent_cleanup, ref)
    expect(ref.refcontent.length).to eq 1
    expect(ref.refcontent.first.content).to eq ["ISO 2002"]
  end
end
