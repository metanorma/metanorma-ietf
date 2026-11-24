# frozen_string_literal: true

require "spec_helper"

# metanorma-ietf#365: the declared attribute table. The alias
# resolution replaces the raw pipe of hard-coded spellings, and the
# near-miss scan surfaces declared attributes that look like a
# misspelling of a flavor attribute instead of dropping them silently
# (the #348 failure mode).
RSpec.describe Metanorma::Ietf::AttributesTable do
  def node_with(attrs)
    doc = Asciidoctor::Document.new
    attrs.each { |k, v| doc.set_attr(k, v) }
    doc
  end

  describe ".resolve" do
    it "finds the canonical hyphenated spelling" do
      node = node_with("submission-type" => "independent")
      expect(described_class.resolve(node, "submission-type"))
        .to eq("independent")
    end

    it "finds the camelCase vocabulary spelling Asciidoctor downcased" do
      node = node_with("submissiontype" => "independent")
      expect(described_class.resolve(node, "submission-type"))
        .to eq("independent")
    end

    it "returns nil with no spelling declared" do
      expect(described_class.resolve(node_with({}), "submission-type"))
        .to be_nil
    end
  end

  describe ".scan" do
    it "flags a declared attribute within edit distance of a canonical" do
      findings = described_class.scan(node_with("submision-type" => "x"))
      expect(findings).to eq([["submision-type", "submission-type"]])
    end

    it "flags a downcased camelCase misspelling" do
      findings = described_class.scan(node_with("submissionTyp" => "x"))
      expect(findings).to eq([["submissionTyp", "submission-type"]])
    end

    it "accepts every guarded canonical spelling silently" do
      attrs = described_class::CANONICAL.to_h { |c| [c, "x"] }
      expect(described_class.scan(node_with(attrs))).to be_empty
    end

    it "accepts the author-line family and PI settings silently" do
      attrs = { "author" => "A", "firstname_2" => "B",
                "authorinitials" => "AB", "rfcedstyle" => "true",
                "tocindent" => "3", "my-custom-attr" => "x" }
      expect(described_class.scan(node_with(attrs))).to be_empty
    end
  end
end
