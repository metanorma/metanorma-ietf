# frozen_string_literal: true

require "spec_helper"
require "metanorma/ietf/transformer"

# The B presentation stage (architecture B, #233): the genuine shared
# converter subclass, exercised through Transformer.presentation and
# the default forward pipeline. Supersedes the A-harness spec
# (Metanorma::Ietf::Presentation::Converter, retired) — same
# behavioural contract, now against the shared layer itself.
RSpec.describe "IETF presentation stage" do
  let(:input_xml) do
    File.read("spec/fixtures/transformer/input/rfc3339-current.xml")
  end

  describe "anchor -> id promotion (xref integrity, N2)" do
    let(:presented) do
      Nokogiri::XML(Metanorma::Ietf::Transformer.presentation(input_xml))
    end

    it "promotes every user-authored anchor to the effective id" do
      anchored = presented.xpath("//*[@anchor]")
      expect(anchored).not_to be_empty
      anchored.each do |elem|
        expect(elem["id"]).to eq elem["anchor"]
      end
    end

    it "preserves the original GUID id in semx-id" do
      elem = presented.at(%{//*[@anchor="restrictions"]})
      expect(elem["semx-id"]).to match(/\A_[0-9a-f-]+\z/)
    end
  end

  describe "references lacking title & formattedref (81f7bc1/#272 parity)" do
    let(:orphaned_input) do
      doc = Nokogiri::XML(input_xml)
      ns = { "m" => doc.root.namespace.href }
      bib = doc.at(%{//m:bibitem[@anchor="ZELLER"]}, ns)
      bib.xpath("./m:title | ./m:formattedref", ns).each(&:remove)
      doc.to_xml
    end

    it "still renders the reference, identifier visible" do
      rfc = Nokogiri::XML(Metanorma::Ietf::Transformer.convert(orphaned_input))
      ref = rfc.at(%{//reference[@anchor="ZELLER"]})
      expect(ref).not_to be_nil
      # F9: the identifier surfaces as the (schema-required) title —
      # the released leg renders it as the quoted title too; the
      # refcontent echo of the same identifier is suppressed
      expect(ref.at("./front/title")&.text).to eq "ZELLER"
      expect(ref.at("./refcontent")).to be_nil
    end
  end

  describe "unresolved references as concept/errormsg (model-iso#144)" do
    let(:errormsg_input) do
      <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc">
          <sections>
            <clause id="c1"><title>One</title>
              <p id="p1">Before <concept><errormsg>term <tt>X</tt> not resolved via ID <tt>Y</tt></errormsg></concept> after.</p>
            </clause>
          </sections>
        </metanorma>
      XML
    end

    it "resolves errormsg to a bold message at the presentation stage" do
      pres = Nokogiri::XML(Metanorma::Ietf::Transformer.presentation(errormsg_input))
      expect(pres.at("//*[local-name()='concept']")).to be_nil
      strong = pres.at("//*[local-name()='p']/*[local-name()='strong']")
      expect(strong).not_to be_nil
      expect(strong.text).to eq "term X not resolved via ID Y"
    end

    it "carries the message bold into RFC XML end to end" do
      rfc = Nokogiri::XML(Metanorma::Ietf::Transformer.convert(errormsg_input))
      strong = rfc.at("//t//strong")
      expect(strong).not_to be_nil
      expect(strong.text).to include "not resolved via ID"
    end
  end

  describe "note/formula autonumbering via the shared Xref" do
    let(:synthetic) do
      <<~XML
        <metanorma xmlns="https://www.metanorma.org/ns/standoc">
          <sections>
            <clause id="c1"><title>One</title>
              <note id="n1"><p id="p1">solo</p></note>
            </clause>
            <clause id="c2"><title>Two</title>
              <note id="n2"><p id="p2">first</p></note>
              <note id="n3"><p id="p3">second</p></note>
            </clause>
          </sections>
        </metanorma>
      XML
    end
    let(:ns) { { "m" => "https://www.metanorma.org/ns/standoc" } }

    it "numbers sibling notes and leaves a solo note unnumbered" do
      out = Nokogiri::XML(Metanorma::Ietf::Transformer.presentation(synthetic))
      expect(out.at(%{//m:note[@id="n1"]}, ns)["autonum"].to_s).to eq ""
      expect(out.at(%{//m:note[@id="n2"]}, ns)["autonum"]).to eq "1"
      expect(out.at(%{//m:note[@id="n3"]}, ns)["autonum"]).to eq "2"
    end

    # Maintainer concession (#233, 2026-07-23): notes render UNNUMBERED
    # in RFC output; the shared-layer autonum stamping stays (all
    # flavours), the IETF flavour just does not render it for notes
    it "renders notes unnumbered through the transformer" do
      rfc = Metanorma::Ietf::Transformer.convert(synthetic)
      expect(rfc).to include "NOTE: solo"
      expect(rfc).to include "NOTE: first"
      expect(rfc).to include "NOTE: second"
      expect(rfc).not_to include "NOTE 1"
    end
  end

  describe "default forward pipeline consumption" do
    it "produces presented XML the transformer consumes intact" do
      rfc = Metanorma::Ietf::Transformer.convert(input_xml)
      expect(rfc.scan(/<sourcecode/).size).to eq 12
      expect(rfc).to include('anchor="restrictions"')
    end
  end
end
