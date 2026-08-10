require "spec_helper"

# Fix-wave specs for metanorma-ietf#294: li anchors, the dead
# :definition_lists guard, block children of li, and source-order
# serialisation of li children.
RSpec.describe "IETF list-item children (#294)" do
  it "carries the li anchor so xrefs to list items resolve" do
    input = <<~INPUT
      #{BLANK_HDR}
      <sections><clause id="c1"><title>Body</title>
      <ul id="u1">
      <li id="itemid"><p id="p1">first</p></li>
      <li id="i2"><p id="p2">second, see <xref target="itemid"/></p></li>
      </ul>
      </clause></sections>
      </iso-standard>
    INPUT
    out = strip_guid(feature_convert(input))
    expect(out).to include('<li anchor="itemid">')
    expect(out).to include('<xref target="itemid"/>')
  end

  it "renders a definition list nested in a list item" do
    input = <<~INPUT
      #{BLANK_HDR}
      <sections><clause id="c1"><title>Body</title>
      <ul id="u1"><li id="l1"><p id="p1">item one</p>
      <dl id="d1"><dt>term</dt><dd id="dd1"><p id="p2">NESTEDDLDEF</p></dd></dl>
      </li></ul>
      </clause></sections>
      </iso-standard>
    INPUT
    out = strip_guid(feature_convert(input))
    expect(out).to include("NESTEDDLDEF")
    expect(out).to match(%r{<li[^>]*>.*<dl.*NESTEDDLDEF.*</dl>.*</li>}m)
  end

  it "renders quote and table attached to a list item" do
    input = <<~INPUT
      #{BLANK_HDR}
      <sections><clause id="c1"><title>Body</title>
      <ul id="u1"><li id="l1"><p id="p1">item</p>
      <quote id="q1"><p id="p2">LIQUOTE</p></quote>
      <table id="t1"><tbody><tr><td>LITABLECELL</td></tr></tbody></table>
      </li></ul>
      </clause></sections>
      </iso-standard>
    INPUT
    out = strip_guid(feature_convert(input))
    expect(out).to match(%r{<li[^>]*>.*<blockquote[^>]*>.*LIQUOTE.*</blockquote>.*</li>}m)
    expect(out).to match(%r{<li[^>]*>.*LITABLECELL.*</li>}m)
  end

  it "serialises li children in source order" do
    input = <<~INPUT
      #{BLANK_HDR}
      <sections><clause id="c1"><title>Body</title>
      <ul id="u1"><li id="l1">
      <p id="pa">leading paragraph</p>
      <ul id="u2"><li id="l2"><p id="pb">nested item</p></li></ul>
      <p id="pc">trailing paragraph after sublist</p>
      </li></ul>
      </clause></sections>
      </iso-standard>
    INPUT
    out = strip_guid(feature_convert(input))
    expect(out).to match(%r{leading paragraph.*<ul.*nested item.*</ul>.*trailing paragraph after sublist}m)
  end
end
