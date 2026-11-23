# frozen_string_literal: true

require "spec_helper"

# metanorma-ietf#348: the RFC-XML world spells the attribute
# `submissionType`; Asciidoctor downcases attribute names, so a document
# declaring `:submissionType: individual` stored it under
# "submissiontype" while the gem only read "submission-type" — the
# declaration was silently dropped and the emitted rfc tag defaulted to
# submissionType="IETF", which the IETF's Idnits3 submission check flags
# as SUBMISSION_TYPE_UNEXPECTED against a Datatracker record without a
# stream.
RSpec.describe "submission type attribute spellings" do
  let(:adoc_input) do
    <<~INPUT
      = Probe
      Author
      :docfile: test.adoc
      :nodoc:
      :docnumber: 1
      :doctype: internet-draft
      :ipr: trust200902
      #{attr_line}

      == Probe

      Text.
    INPUT
  end

  let(:semantic_xml) do
    Asciidoctor.convert(adoc_input, backend: :ietf, header_footer: true)
  end

  let(:rfc_xml) do
    Metanorma::Ietf::Transformer.convert(semantic_xml, direction: :forward)
  end

  context "with the declaration" do
    let(:attr_line) { ":submissionType: individual" }

    it "carries the stream into the bibdata series" do
      expect(semantic_xml).to include("<title>individual</title>")
    end

    it "emits the declared submissionType on the rfc tag" do
      expect(rfc_xml).to include('submissionType="individual"')
    end
  end

  context "with the kebab-case spelling" do
    let(:attr_line) { ":submission-type: individual" }

    it "emits the declared submissionType on the rfc tag" do
      expect(rfc_xml).to include('submissionType="individual"')
    end
  end

  context "with no declaration" do
    let(:attr_line) { "" }

    it "defaults the rfc tag to IETF" do
      expect(rfc_xml).to include('submissionType="IETF"')
    end
  end
end
