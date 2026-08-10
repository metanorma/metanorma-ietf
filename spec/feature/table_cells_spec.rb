require "spec_helper"

# Fix-wave specs for metanorma-ietf#295: block content inside table
# cells (probe showed an ENTIRELY EMPTY cell), table-level @align, and
# mixed th/td header rows dropping their td cells.
RSpec.describe "IETF table cells (#295)" do
  it "renders block content inside a table cell" do
    input = <<~INPUT
      #{BLANK_HDR}
      <sections><clause id="c1"><title>Body</title>
      <table id="t1"><tbody><tr>
      <td>plain cell</td>
      <td><p id="p1">CELLLEAD</p><ul id="u1"><li><p id="p2">CELLLISTITEM</p></li></ul></td>
      </tr></tbody></table>
      </clause></sections>
      </iso-standard>
    INPUT
    out = strip_guid(feature_convert(input))
    expect(out).to include("CELLLEAD")
    expect(out).to match(%r{<td[^>]*>.*CELLLEAD.*<ul.*CELLLISTITEM.*</ul>.*</td>}m)
  end

  it "carries table-level align" do
    input = <<~INPUT
      #{BLANK_HDR}
      <sections><clause id="c1"><title>Body</title>
      <table id="t1" align="left"><tbody><tr><td>x</td></tr></tbody></table>
      </clause></sections>
      </iso-standard>
    INPUT
    out = strip_guid(feature_convert(input))
    expect(out).to match(/<table[^>]* align="left"/)
  end

  it "keeps td cells in a header row that mixes th and td" do
    input = <<~INPUT
      #{BLANK_HDR}
      <sections><clause id="c1"><title>Body</title>
      <table id="t1"><thead><tr><th>HEADA</th><td>HEADB</td></tr></thead>
      <tbody><tr><td>x</td><td>y</td></tr></tbody></table>
      </clause></sections>
      </iso-standard>
    INPUT
    out = strip_guid(feature_convert(input))
    expect(out).to include("HEADB")
    expect(out).to match(%r{<th[^>]*>HEADA</th>\s*<td[^>]*>HEADB</td>}m)
  end
end
