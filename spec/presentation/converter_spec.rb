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
