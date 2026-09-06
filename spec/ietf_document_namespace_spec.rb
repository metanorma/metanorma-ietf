# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Metanorma::Ietf::Document namespace" do
  describe "canonical namespace" do
    it "exposes Metanorma::Ietf::Document as a Module" do
      expect(Metanorma::Ietf::Document).to be_a(Module)
    end

    it "exposes Root with the canonical name" do
      expect(Metanorma::Ietf::Document::Root.name)
        .to eq("Metanorma::Ietf::Document::Root")
    end

    it "Root is a lutaml Serializable" do
      expect(Metanorma::Ietf::Document::Root < Lutaml::Model::Serializable).to be(true)
    end
  end

  describe "backwards-compat alias" do
    it "Metanorma::IetfDocument aliases to the new namespace" do
      expect(Metanorma::IetfDocument).to eq(Metanorma::Ietf::Document)
    end

    it "the alias preserves class identity" do
      expect(Metanorma::IetfDocument::Root.equal?(
               Metanorma::Ietf::Document::Root)).to be(true)
    end
  end

  describe "parent namespace" do
    it "Metanorma::Standoc::Document is available" do
      expect(Metanorma::Standoc::Document).to be_a(Module)
    end

    it "Metanorma::StandardDocument alias is available" do
      expect(Metanorma::StandardDocument).to eq(Metanorma::Standoc::Document)
    end
  end
end
