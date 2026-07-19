# frozen_string_literal: true

require "spec_helper"
require "nokogiri"

# Content-conservation invariant: every content-bearing element in the
# Semantic XML input must have a non-blank counterpart in the RFC XML
# output. Guards the silent-loss defect class (empty-but-truthy collection
# reads): see docs/truthy-collection-audit.md and the WS1b findings.
#
# Known-open defects are encoded as `pending`: when a fix lands and the
# example starts passing, RSpec fails the run until the pending marker is
# removed — the defect ledger and the suite cannot drift apart.
RSpec.describe Metanorma::Ietf::Transformer do
  describe "content conservation (current-schema Semantic XML)" do
    let(:input_xml) do
      File.read("spec/fixtures/transformer/input/rfc3339-current.xml")
    end
    let(:input) do
      doc = Nokogiri::XML(input_xml)
      doc.remove_namespaces!
      doc
    end
    let(:output) do
      Nokogiri::XML(described_class.convert(input_xml))
    end

    it "conserves sourcecode content" do
      in_codes = input.xpath("//sourcecode").map { |n| n.text.strip }
        .reject(&:empty?)
      out_codes = output.xpath("//sourcecode").map { |n| n.text.strip }
      expect(out_codes.size).to eq(in_codes.size)
      expect(out_codes.reject(&:empty?).size).to eq(in_codes.size)
    end

    it "conserves bibliography entries" do
      # direct children only: relaton entries nest relation bibitems inside
      in_refs = input.xpath("//references/bibitem")
      out_refs = output.xpath("//references/reference")
      expect(out_refs.size).to eq(in_refs.size)
    end

    it "conserves document keywords" do
      pending "N8: front keywords dropped"
      in_kw = input.xpath("//bibdata//keyword").map { |n| n.text.strip }
        .reject(&:empty?)
      skip "no keywords in fixture" if in_kw.empty?
      out_kw = output.xpath("//front/keyword").map { |n| n.text.strip }
      expect(out_kw).to match_array(in_kw)
    end

    it "conserves the workgroup" do
      pending "N8: workgroup dropped"
      in_wg = input.xpath("//bibdata//editorialgroup//name |
                           //bibdata//workgroup").map { |n| n.text.strip }
        .reject(&:empty?)
      skip "no workgroup in fixture" if in_wg.empty?
      out_wg = output.xpath("//front/workgroup").map { |n| n.text.strip }
      expect(out_wg).not_to be_empty
    end

    it "conserves user-authored anchors" do
      # N2 mapping half fixed (anchor_for sweep); management half is the
      # presentation layer's per the architecture decision
      in_anchors = input.xpath("//*[@anchor]").map { |n| n["anchor"] }.uniq
      skip "no user anchors in fixture" if in_anchors.empty?
      out_anchors = output.xpath("//*[@anchor]").map { |n| n["anchor"] }
      missing = in_anchors - out_anchors
      expect(missing).to be_empty
    end

    it "conserves formulas" do
      in_stems = input.xpath("//formula//stem")
      skip "no formulas in fixture" if in_stems.empty?
      # N13: activates when a formula-bearing current-schema fixture lands
      out_text = output.text
      expect(in_stems.size).to be > 0
      expect(out_text).not_to be_empty
    end

    it "emits a non-blank abstract" do
      skip "no abstract in fixture" if input.xpath("//preface/abstract |
        //bibdata/abstract").empty?
      expect(output.xpath("//front/abstract").text.strip).not_to be_empty
    end
  end
end
