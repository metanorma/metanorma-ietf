# frozen_string_literal: true

# Self-contained: avoids the gem spec_helper's heavier requires.
require "bundler/setup"
require "metanorma/ietf/document"
require "metanorma/ietf/html"
require "metanorma/html/generator"

# The renderer registration contract: the IETF root and its section
# classes must dispatch — an unregistered root renders reader chrome
# with no document body. (Semantic parse verified against
# mn-samples-ietf example; the corpus carries no compiled
# presentation XML.)
RSpec.describe "Metanorma::Ietf::Html::Renderer" do
  let(:xml) do
    <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" \
type="presentation" flavor="ietf">
        <bibdata type="standard"><title>IETF Test</title></bibdata>
        <sections><clause id="_c1" obligation="normative">
          <title>Scope</title><p id="_p1">The scope.</p>
        </clause></sections>
      </metanorma>
    XML
  end

  it "renders the IETF root to a document body, not an empty shell" do
    model = Metanorma::Ietf::Document::Root.from_xml(xml)
    html = Metanorma::Html::Generator.generate(model)
    page = Nokogiri::HTML(html)
    page.css("header, nav, .header-actions, button, kbd").remove

    expect(page.css("p").size).to be >= 1,
                                  "document body rendered no content (root dispatch missing)"
    expect(page.at("body").text).to include("The scope.")
  end

  it "is the renderer the flavor registry resolves" do
    entry = Metanorma::Core::Flavors.find(:ietf)
    expect(entry.renderers[:html].call(nil)).to eq(Metanorma::Ietf::Html::Renderer)
  end
end
