require "spec_helper"

# Fix-wave specs for metanorma-ietf#293: footnote bodies lost inline
# content, non-paragraph bodies vanished, table-footnote dedup was
# keyed globally, and markers abutted the running text.
RSpec.describe "IETF footnote content (#293)" do
  it "preserves a footnote body's inline content and its anchor" do
    input = <<~INPUT
      #{BLANK_HDR}
      <sections><clause id="c1"><title>Body</title>
      <p id="p1">Claim.<fn reference="1"><p id="fnp1">See <em>emphatic</em> and <link target="http://example.com">site</link> tail</p></fn></p>
      </clause></sections>
      </iso-standard>
    INPUT
    out = strip_guid(feature_convert(input))
    expect(out).to include("[1] See emphatic and site tail")
    expect(out).to match(/<t anchor="[^"]*">\[1\] See emphatic/)
  end

  it "sets footnote markers off from the running text" do
    input = <<~INPUT
      #{BLANK_HDR}
      <sections><clause id="c1"><title>Body</title>
      <p id="p1">text<fn reference="1"><p id="fnp1">Note body</p></fn></p>
      </clause></sections>
      </iso-standard>
    INPUT
    out = strip_guid(feature_convert(input))
    expect(out).to include("text [1]")
  end

  it "keeps same-labelled footnotes of different tables distinct" do
    input = <<~INPUT
      #{BLANK_HDR}
      <sections><clause id="c1"><title>Body</title>
      <table id="t1"><tbody><tr><td>A<fn reference="a"><p id="f1">FIRSTNOTE</p></fn></td></tr></tbody></table>
      <table id="t2"><tbody><tr><td>B<fn reference="a"><p id="f2">SECONDNOTE</p></fn></td></tr></tbody></table>
      </clause></sections>
      </iso-standard>
    INPUT
    out = strip_guid(feature_convert(input))
    expect(out).to include("[1] FIRSTNOTE")
    expect(out).to include("[2] SECONDNOTE")
  end

  it "carries a non-paragraph footnote body" do
    pending "MODEL GAP (metanorma-document 0.2.9): FnElement maps " \
            "only p — a list-bodied footnote is parse-ghosted, content " \
            "included (metanorma-ietf#293, metanorma-document#46 " \
            "family). Re-test on the model upgrade."
    input = <<~INPUT
      #{BLANK_HDR}
      <sections><clause id="c1"><title>Body</title>
      <p id="p1">Claim.<fn reference="1"><ul id="u1"><li><p id="lp1">LISTNOTE</p></li></ul></fn></p>
      </clause></sections>
      </iso-standard>
    INPUT
    out = strip_guid(feature_convert(input))
    expect(out).to include("LISTNOTE")
  end
end
