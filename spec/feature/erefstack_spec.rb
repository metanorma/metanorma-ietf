# frozen_string_literal: true

require "spec_helper"

# metanorma-ietf#304: erefstack (stacked external references). On the
# default pipeline the shared presentation stage renders the stack,
# joining the citations with their connectives — named connectives
# work today (the connective-less and custom-connective cases are
# fixed in the shared stage by metanorma/isodoc#911). The
# presentation:false path exercises this flavor's own fallback
# renderer. Stack-in-concept stays pending on the ledgered
# concept-in-paragraph gap (#292).
RSpec.describe "erefstack rendering" do
  def stack_input(second_attrs)
    <<~INPUT
      <metanorma xmlns="https://www.metanorma.org/ns/standoc">
      <sections><clause id="stackclause"><title>Stack</title>
      <p>
      <erefstack>
      <eref type="inline" bibitemid="ISO712" citeas="ISO 712"><display-text>ISO 712</display-text></eref>
      <eref type="inline" bibitemid="ISO8000" citeas="ISO 8000" #{second_attrs}><display-text>ISO 8000</display-text></eref>
      </erefstack>
      </p>
      </clause></sections>
      </metanorma>
    INPUT
  end

  it "renders both references of a named-connective stack end to end" do
    out = strip_guid(feature_convert(stack_input('connective="and"')))
    expect(out).to include('<xref target="ISO712">ISO 712</xref>')
    expect(out).to include('<xref target="ISO8000">ISO 8000</xref>')
    expect(out).to match(%r{ISO 712</xref> and <xref target="ISO8000">})
  end

  it "comma-joins a connective-less stack in the fallback renderer" do
    out = strip_guid(Metanorma::Ietf::Transformer
      .convert(stack_input(""), presentation: false))
    expect(out).to include('<xref target="ISO712"/>')
    expect(out).to include('<xref target="ISO8000"/>')
    expect(out).to match(%r{ISO712"/>, <xref target="ISO8000"/>})
  end

  it "joins with the authored custom connective in the fallback renderer" do
    out = strip_guid(Metanorma::Ietf::Transformer.convert(
      stack_input('custom-connective="together with"'), presentation: false,
    ))
    expect(out).to match(%r{ISO712"/> together with <xref target="ISO8000"/>})
  end

  # pending: stacks inside <concept> need the concept-in-paragraph
  # rendering (model-gap ledger, metanorma-ietf#292) before the stack
  # child is reached; the presentation path additionally needs
  # metanorma/isodoc#911 for the connective-less stack
  it "renders a stack inside a concept" do
    pending "concept-in-paragraph rendering (#292) and isodoc#911"
    input = stack_input("").sub(
      "<p>", "<concept term=\"time-stamp\"><renderterm>time-stamp</renderterm>",
    ).sub("</p>", "</concept>")
    out = strip_guid(Metanorma::Ietf::Transformer.convert(
      input, presentation: false,
    ))
    expect(out).to include('<xref target="ISO712"/>')
  end
end
