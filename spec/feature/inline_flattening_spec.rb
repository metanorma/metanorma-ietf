require "spec_helper"

# Fix-wave specs for metanorma-ietf#292: inline markup content used to
# be LOST (not merely flattened) wherever ls_text fed titles, captions,
# names and mixed inline content. Structure is asserted where v3 makes
# it legal (name admits the full inline set) AND the 0.2.9 model maps
# the child; parse-ghosted children are documented as pending specs
# (metanorma-document#46 family — re-test on the model upgrade).
RSpec.describe "IETF inline content preservation (#292)" do
  it "carries emphasis inside a section title" do
    input = <<~INPUT
      #{BLANK_HDR}
      <sections><clause id="c1"><title>Plain <em>emphasized</em> tail</title><p id="p1">T.</p></clause></sections>
      </iso-standard>
    INPUT
    out = strip_guid(feature_convert(input))
    expect(out).to match(%r{<name>Plain <em>emphasized</em> tail</name>})
  end

  it "keeps descendant text of an inline nested in a dropped inline" do
    input = <<~INPUT
      #{BLANK_HDR}
      <sections><clause id="c1"><title>Body</title>
      <p id="p1"><strike>cut <em>gone</em> here</strike></p>
      </clause></sections>
      </iso-standard>
    INPUT
    out = strip_guid(feature_convert(input))
    expect(out).to include("cut gone here")
  end

  it "keeps link content inside a definition term" do
    input = <<~INPUT
      #{BLANK_HDR}
      <sections><clause id="c1"><title>Body</title>
      <dl id="d1"><dt>Term <link target="http://example.com">site</link></dt>
      <dd><p id="dd1">Def.</p></dd></dl>
      </clause></sections>
      </iso-standard>
    INPUT
    out = strip_guid(feature_convert(input))
    expect(out).to match(%r{<dt[^>]*>Term site</dt>})
  end

  it "carries an xref inside a figure caption" do
    pending "MODEL GAP (metanorma-document 0.2.9): NameWithIdElement " \
            "maps no inline children — an xref inside a figure/table " \
            "caption is parse-ghosted, content included " \
            "(metanorma-ietf#292, metanorma-document#46 family). The " \
            "name builder carries mapped inlines — re-test on upgrade."
    input = <<~INPUT
      #{BLANK_HDR}
      <sections><clause id="c1"><title>Body</title>
      <figure id="f1"><name>As <xref target="c1">Clause 1</xref> shows</name>
      <p id="fp1">FIGBODY</p></figure>
      </clause></sections>
      </iso-standard>
    INPUT
    out = strip_guid(feature_convert(input))
    expect(out).to match(%r{<name>As <xref target="c1">Clause 1</xref> shows</name>})
  end

  it "interleaves mixed simple-inline content in source order" do
    pending "MODEL GAP (metanorma-document 0.2.9): EmRawElement maps " \
            "no nested simple inlines — <strong> inside <em> is " \
            "parse-ghosted, content included (metanorma-ietf#292, " \
            "metanorma-document#46 family). The mixed-content builder " \
            "interleaves mapped children — re-test on upgrade."
    input = <<~INPUT
      #{BLANK_HDR}
      <sections><clause id="c1"><title>Body</title>
      <p id="p1">Lead <em>alpha <strong>beta</strong> gamma</em> tail.</p>
      </clause></sections>
      </iso-standard>
    INPUT
    out = strip_guid(feature_convert(input))
    expect(out).to match(%r{<em>alpha <strong>beta</strong> gamma</em>})
  end

  it "keeps the text of an xref nested in a dropped inline (strike)" do
    pending "MODEL GAP (metanorma-document 0.2.9): StrikeElement maps " \
            "em/strong/eref/link but NOT xref — a nested xref is " \
            "parse-ghosted, content included (metanorma-ietf#292, " \
            "metanorma-document#46 family). Re-test on upgrade."
    input = <<~INPUT
      #{BLANK_HDR}
      <sections><clause id="c1"><title>Body</title>
      <p id="p1"><strike>cut <xref target="c2">Clause 2</xref> here</strike></p>
      <clause id="c2"><title>Target</title><p id="p2">T.</p></clause>
      </clause></sections>
      </iso-standard>
    INPUT
    out = strip_guid(feature_convert(input))
    expect(out).to include("cut Clause 2 here")
  end
end
