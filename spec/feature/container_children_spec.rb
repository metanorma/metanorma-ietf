require "spec_helper"

# Fix-wave specs for metanorma-ietf#297: quote/note/example lose
# non-paragraph children, and keepWithPrevious (WS5b A2.5, fixed under
# this ticket's umbrella). Admonition children beyond paragraphs, note
# sourcecode/figure/table, example note, and quote dl/sourcecode
# remain MODEL GAPS (metanorma-document 0.2.9 maps no accessors) —
# pendings below document them for the model upgrade.
RSpec.describe "IETF container children (#297)" do
  it "keeps a list inside a blockquote, in source order" do
    input = <<~INPUT
      #{BLANK_HDR}
      <sections><clause id="c1"><title>Body</title>
      <quote id="q1">
      <p id="p1">Lead.</p>
      <ul id="u1"><li><p id="p2">QUOTELISTITEM</p></li></ul>
      <p id="p3">Tail.</p>
      </quote>
      </clause></sections>
      </iso-standard>
    INPUT
    out = strip_guid(feature_convert(input))
    expect(out).to include("QUOTELISTITEM")
    expect(out).to match(%r{<blockquote[^>]*>.*Lead.*<ul.*QUOTELISTITEM.*</ul>.*Tail.*</blockquote>}m)
  end

  it "keeps formula and quote inside a note" do
    input = <<~INPUT
      #{BLANK_HDR}
      <sections><clause id="c1"><title>Body</title>
      <note id="n1"><p id="p1">Note lead.</p>
      <formula id="f1"><stem type="MathML" block="true"><math xmlns="http://www.w3.org/1998/Math/MathML"><mi>x</mi></math><asciimath>NOTEFORMULA</asciimath></stem></formula>
      <quote id="q1"><p id="p2">NOTEQUOTE</p></quote>
      </note>
      </clause></sections>
      </iso-standard>
    INPUT
    out = strip_guid(feature_convert(input))
    expect(out).to include("NOTEFORMULA")
    expect(out).to match(%r{<blockquote[^>]*>.*NOTEQUOTE.*</blockquote>}m)
  end

  it "keeps formula, quote and legacy list inside an example" do
    input = <<~INPUT
      #{BLANK_HDR}
      <sections><clause id="c1"><title>Body</title>
      <example id="e1"><p id="p1">Example lead.</p>
      <formula id="f1"><stem type="MathML" block="true"><math xmlns="http://www.w3.org/1998/Math/MathML"><mi>y</mi></math><asciimath>EXFORMULA</asciimath></stem></formula>
      <quote id="q1"><p id="p2">EXQUOTE</p></quote>
      </example>
      </clause></sections>
      </iso-standard>
    INPUT
    out = strip_guid(feature_convert(input))
    expect(out).to include("EXFORMULA")
    expect(out).to match(%r{<blockquote[^>]*>.*EXQUOTE.*</blockquote>}m)
  end

  it "carries keep-with-previous onto t" do
    input = <<~INPUT
      #{BLANK_HDR}
      <sections><clause id="c1"><title>Body</title>
      <p id="p1" keep-with-previous="true">KWP paragraph.</p>
      </clause></sections>
      </iso-standard>
    INPUT
    out = strip_guid(feature_convert(input))
    expect(out).to include('keepWithPrevious="true"')
  end

  it "renders admonition non-paragraph children" do
    pending "MODEL GAP (metanorma-document 0.2.9): AdmonitionBlock " \
            "maps only paragraphs — lists/sourcecode inside " \
            "admonitions cannot reach the transformer " \
            "(metanorma-ietf#297, metanorma-document#46). Re-test on " \
            "the model upgrade."
    input = <<~INPUT
      #{BLANK_HDR}
      <sections><clause id="c1"><title>Body</title>
      <admonition id="a1" type="caution"><p id="p1">Lead.</p>
      <ul id="u1"><li><p id="p2">ADMONLISTITEM</p></li></ul>
      </admonition>
      </clause></sections>
      </iso-standard>
    INPUT
    out = strip_guid(feature_convert(input))
    expect(out).to include("ADMONLISTITEM")
  end

  it "renders sourcecode inside a note" do
    pending "MODEL GAP (metanorma-document 0.2.9): NoteBlock maps no " \
            "sourcecode/figure/table (metanorma-ietf#297, " \
            "metanorma-document#46). Re-test on the model upgrade."
    input = <<~INPUT
      #{BLANK_HDR}
      <sections><clause id="c1"><title>Body</title>
      <note id="n1"><p id="p1">Lead.</p>
      <sourcecode id="s1"><body>NOTECODE()</body></sourcecode>
      </note>
      </clause></sections>
      </iso-standard>
    INPUT
    out = strip_guid(feature_convert(input))
    expect(out).to include("NOTECODE()")
  end
end
