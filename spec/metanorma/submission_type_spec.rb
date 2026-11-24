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
      :fullname: Author Name
      :surname: Name
      :email: author@example.com
      :docfile: test.adoc
      :nodoc:
      :docnumber: 1
      :doctype: internet-draft
      :ipr: trust200902
      :intended-series: informational
      #{attr_line}

      [abstract]
      --
      Probe abstract.
      --

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

  # The emitted Rfcxml model, exactly as the processor leg builds it:
  # presentation stage, model parse, IetfToRfcV3 transform
  let(:rfc_model) do
    presented = Metanorma::Ietf::Transformer.presentation(semantic_xml)
    doc = Metanorma::Ietf::Transformer.parse_semantic(presented)
    Metanorma::Ietf::Transformer::IetfToRfcV3.new(doc).transform
  end

  # The RFC 7841 stream vocabulary: Datatracker's "Individual
  # Submissions" stream is spelled `independent` in RFC XML (RFC 7991
  # s2.45.11). A value outside the enum must not reach the output —
  # the model validation halts it (stream validation specs in
  # spec/feature/validate_spec.rb).
  context "with the declaration" do
    let(:attr_line) { ":submissionType: independent" }

    it "carries the stream into the bibdata series" do
      expect(semantic_xml).to include("<title>independent</title>")
    end

    it "emits the declared submissionType on the rfc tag" do
      expect(rfc_xml).to include('submissionType="independent"')
    end

    it "validates clean on the model" do
      v = Metanorma::Ietf::RfcValidate.new
      v.content_validate(rfc_model)
      v.content_warnings(rfc_model)
      expect(v).not_to be_fatal
      expect(v).not_to be_entries
    end
  end

  context "with the kebab-case spelling" do
    let(:attr_line) { ":submission-type: independent" }

    it "emits the declared submissionType on the rfc tag" do
      expect(rfc_xml).to include('submissionType="independent"')
    end
  end

  context "with no declaration" do
    let(:attr_line) { "" }

    it "defaults the rfc tag to IETF" do
      expect(rfc_xml).to include('submissionType="IETF"')
    end
  end

  context "with a value outside the RFC 7841 stream enum" do
    let(:attr_line) { ":submission-type: individual" }

    it "emits the declared value verbatim" do
      expect(rfc_xml).to include('submissionType="individual"')
    end

    it "is halted by the model validation with the legal values" do
      v = Metanorma::Ietf::RfcValidate.new
      fatal = v.content_validate(rfc_model)
      expect(fatal.join("\n"))
        .to match(/Unknown submissionType \(stream\) on <rfc> element/)
      expect(fatal.join("\n"))
        .to include("IAB, IETF, IRTF, editorial, independent")
    end
  end
end
