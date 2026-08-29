require "spec_helper"

# Fix-wave specs for metanorma-ietf#296 (figure/image gaps) and #305
# (image sizing). 0.2.9 parse ghosts are documented as pending specs
# (metanorma-document#46 family).
RSpec.describe "IETF figure and image content (#296, #305)" do
  PNG = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==".freeze

  it "folds subfigure content into the parent figure" do
    input = <<~INPUT
      #{BLANK_HDR}
      <sections><clause id="c1"><title>Body</title>
      <figure id="f0"><name>Parent</name>
      <figure id="f1"><name>First sub</name><image id="i1" src="#{PNG}" mimetype="image/png"/></figure>
      <figure id="f2"><name>Second sub</name><image id="i2" src="#{PNG}" mimetype="image/png"/></figure>
      </figure>
      </clause></sections>
      </iso-standard>
    INPUT
    out = strip_guid(feature_convert(input))
    expect(out).to match(/<artwork[^>]* anchor="i1"[^>]* name="First sub"|<artwork[^>]* name="First sub"[^>]* anchor="i1"/)
    expect(out).to match(/name="Second sub"/)
    expect(out).to match(/<name>Parent<\/name>/)
  end

  it "carries the figure key definition list" do
    input = <<~INPUT
      #{BLANK_HDR}
      <sections><clause id="c1"><title>Body</title>
      <figure id="f1"><name>Keyed</name>
      <image id="i1" src="#{PNG}" mimetype="image/png"/>
      <dl id="k1" key="true"><dt>A</dt><dd><p id="kd1">alpha line</p></dd></dl>
      </figure>
      </clause></sections>
      </iso-standard>
    INPUT
    out = strip_guid(feature_convert(input))
    expect(out).to include("A: alpha line")
  end

  it "carries image sizing to artwork and leaves unsized images alone" do
    input = <<~INPUT
      #{BLANK_HDR}
      <sections><clause id="c1"><title>Body</title>
      <figure id="f1"><image id="i1" src="#{PNG}" mimetype="image/png" width="300" height="200"/></figure>
      <figure id="f2"><image id="i2" src="#{PNG}" mimetype="image/png"/></figure>
      </clause></sections>
      </iso-standard>
    INPUT
    out = strip_guid(feature_convert(input))
    expect(out).to match(/<artwork[^>]*anchor="i1"[^>]*width="300"[^>]*height="200"/)
    expect(out).not_to match(/<artwork[^>]*anchor="i2"[^>]*width=/)
  end

  it "recovers an inline image in a plain paragraph as an anchored figure" do
    input = <<~INPUT
      #{BLANK_HDR}
      <sections><clause id="c1"><title>Body</title>
      <p id="p1">Before <image id="i1" src="#{PNG}" mimetype="image/png"/> after.</p>
      </clause></sections>
      </iso-standard>
    INPUT
    out = strip_guid(feature_convert(input))
    expect(out).to match(%r{<figure>\s*<artwork anchor="i1"})
    expect(out).not_to include("[IMAGE")
  end

  it "recovers an inline image inside a list item" do
    input = <<~INPUT
      #{BLANK_HDR}
      <sections><clause id="c1"><title>Body</title>
      <ul id="u1"><li><p id="lp1">Item <image id="i2" src="#{PNG}" mimetype="image/png"/> tail.</p></li></ul>
      </clause></sections>
      </iso-standard>
    INPUT
    out = strip_guid(feature_convert(input))
    expect(out).to match(/<artwork anchor="i2"/)
    expect(out).not_to include("[IMAGE")
  end

  it "carries the figure [SOURCE:] attribution" do
    pending "MODEL GAP (metanorma-document 0.2.9): FigureBlock maps " \
            "the source ATTRIBUTE only — the <source> citation element " \
            "(and its fmt-source rendering) is parse-ghosted " \
            "(metanorma-ietf#296, metanorma-document#46 family)."
    input = <<~INPUT
      #{BLANK_HDR}
      <sections><clause id="c1"><title>Body</title>
      <figure id="f1"><image id="i1" src="#{PNG}" mimetype="image/png"/>
      <source status="generalisation"><origin bibitemid="ISO712" type="inline" citeas="ISO 712"/></source>
      </figure>
      </clause></sections>
      </iso-standard>
    INPUT
    out = strip_guid(feature_convert(input))
    expect(out).to match(/SOURCE.*ISO\s*712/m)
  end

  it "carries sourcecode src" do
    pending "MODEL GAP (metanorma-document 0.2.9): SourcecodeBlock " \
            "maps no src attribute — sourcecode src= is parse-ghosted " \
            "(metanorma-ietf#296, metanorma-document#46 family); " \
            "rfcxml's v3 Sourcecode maps src and is ready for it."
    input = <<~INPUT
      #{BLANK_HDR}
      <sections><clause id="c1"><title>Body</title>
      <sourcecode id="s1" src="https://example.com/code.rb"/>
      </clause></sections>
      </iso-standard>
    INPUT
    out = strip_guid(feature_convert(input))
    expect(out).to match(/<sourcecode[^>]* src="https:\/\/example\.com\/code\.rb"/)
  end

  it "carries intra-figure explanatory paragraphs" do
    pending "MODEL GAP (metanorma-document 0.2.9): FigureBlock maps " \
            "no p — intra-figure paragraphs are parse-ghosted " \
            "(metanorma-ietf#296/#303 ledger, metanorma-document#46 " \
            "family)."
    input = <<~INPUT
      #{BLANK_HDR}
      <sections><clause id="c1"><title>Body</title>
      <figure id="f1"><p id="fp1">PREAMBLETEXT</p>
      <image id="i1" src="#{PNG}" mimetype="image/png"/>
      <p id="fp2">POSTAMBLETEXT</p></figure>
      </clause></sections>
      </iso-standard>
    INPUT
    out = strip_guid(feature_convert(input))
    expect(out).to include("PREAMBLETEXT")
    expect(out).to include("POSTAMBLETEXT")
  end

  it "renders a clause-level pre as ascii-art artwork" do
    pending "MODEL GAP (metanorma-document 0.2.9): sections map no " \
            "pre — a clause-level literal block is parse-ghosted " \
            "(metanorma-ietf#296, metanorma-document#46 family)."
    input = <<~INPUT
      #{BLANK_HDR}
      <sections><clause id="c1"><title>Body</title>
      <pre id="pre1">ASCII ART HERE</pre>
      </clause></sections>
      </iso-standard>
    INPUT
    out = strip_guid(feature_convert(input))
    expect(out).to match(/<artwork[^>]*type="ascii-art"[^>]*>.*ASCII ART HERE/m)
  end
end
