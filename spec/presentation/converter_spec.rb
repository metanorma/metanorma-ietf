# frozen_string_literal: true

require "spec_helper"
require "metanorma/ietf/presentation"

RSpec.describe Metanorma::Ietf::Presentation::Converter do
  let(:input_xml) do
    File.read("spec/fixtures/transformer/input/rfc3339-current.xml")
  end
  let(:converter) { described_class.new }

  describe "#populate_id (xref integrity, layer-side half of N2)" do
    let(:enriched) { Nokogiri::XML(converter.enrich(input_xml)) }

    it "promotes every user-authored anchor to the effective id" do
      anchored = enriched.xpath("//*[@anchor]")
      expect(anchored).not_to be_empty
      anchored.each do |elem|
        expect(elem["id"]).to eq elem["anchor"]
      end
    end

    it "preserves the original GUID id in semx-id" do
      elem = enriched.at(%{//*[@anchor="restrictions"]})
      expect(elem["semx-id"]).to match(/\A_[0-9a-f-]+\z/)
    end
  end

  describe "#render_orphan_references (81f7bc1/#272 parity)" do
    let(:orphaned_input) do
      doc = Nokogiri::XML(input_xml)
      ns = { "m" => doc.root.namespace.href }
      bib = doc.at(%{//m:bibitem[@anchor="ZELLER"]}, ns)
      bib.xpath("./m:title | ./m:formattedref", ns).each(&:remove)
      doc.to_xml
    end

    it "synthesises a formattedref from the docidentifier" do
      enriched = Nokogiri::XML(converter.enrich(orphaned_input))
      fr = enriched.at(%{//*[@anchor="ZELLER"]/*[local-name()="formattedref"]})
      expect(fr).not_to be_nil
      expect(fr.text).to eq "ZELLER"
    end

    it "inherits the document namespace on the synthesised element" do
      enriched = Nokogiri::XML(converter.enrich(orphaned_input))
      fr = enriched.at(%{//*[@anchor="ZELLER"]/*[local-name()="formattedref"]})
      expect(fr.namespace&.href).to eq enriched.root.namespace&.href
    end

    it "leaves bibitems that still carry a formattedref alone" do
      enriched = Nokogiri::XML(converter.enrich(input_xml))
      frs = enriched.xpath(%{//*[@anchor="ZELLER"]/*[local-name()="formattedref"]})
      expect(frs.size).to be <= 1
    end
  end

  describe "#stamp_autonums (note/formula numbering via the shared Xref)" do
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
      out = Nokogiri::XML(converter.enrich(synthetic))
      expect(out.at(%{//m:note[@id="n1"]}, ns)["autonum"]).to be_nil
      expect(out.at(%{//m:note[@id="n2"]}, ns)["autonum"]).to eq "1"
      expect(out.at(%{//m:note[@id="n3"]}, ns)["autonum"]).to eq "2"
    end

    # Maintainer concession (#233, 2026-07-23): notes render UNNUMBERED
    # in RFC output; the shared-layer autonum stamping stays (all
    # flavours), the IETF flavour just does not render it for notes
    it "renders notes unnumbered through the transformer" do
      require "metanorma/ietf/transformer"
      rfc = Metanorma::Ietf::Transformer.convert(converter.enrich(synthetic))
      expect(rfc).to include "NOTE: solo"
      expect(rfc).to include "NOTE: first"
      expect(rfc).to include "NOTE: second"
      expect(rfc).not_to include "NOTE 1"
    end
  end

  describe "round-trip into the transformer" do
    it "produces enriched XML the transformer still consumes" do
      require "metanorma/ietf/transformer"
      enriched = converter.enrich(input_xml)
      rfc = Metanorma::Ietf::Transformer.convert(enriched)
      expect(rfc.scan(/<sourcecode/).size).to eq 12
      expect(rfc).to include('anchor="restrictions"')
    end
  end
end
