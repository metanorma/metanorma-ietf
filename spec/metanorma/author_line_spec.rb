# frozen_string_literal: true

require "spec_helper"

# metanorma-ietf#360: the flavor read author declarations only through
# :fullname:/:surname: (Standoc#personal_author), so documents using
# the common AsciiDoc author line — the names on the line after the
# title — produced author-less front matter, which RFC 7991 forbids
# (author+ in <front>) and which idnits3's submission mode never flags.
RSpec.describe "AsciiDoc author line" do
  let(:adoc_input) do
    <<~INPUT
      = Probe
      #{author_line}
      :docfile: test.adoc
      :nodoc:
      :docnumber: 1
      :doctype: internet-draft
      :ipr: trust200902
      :submission-type: independent
      :intended-series: informational
      #{extra_attrs}

      [abstract]
      --
      Probe abstract.
      --

      == Probe

      Text.
    INPUT
  end

  let(:extra_attrs) { "" }

  let(:semantic_xml) do
    Asciidoctor.convert(adoc_input, backend: :ietf, header_footer: true)
  end

  let(:rfc_xml) do
    Metanorma::Ietf::Transformer.convert(semantic_xml, direction: :forward)
  end

  let(:rfc_model) do
    presented = Metanorma::Ietf::Transformer.presentation(semantic_xml)
    doc = Metanorma::Ietf::Transformer.parse_semantic(presented)
    Metanorma::Ietf::Transformer::IetfToRfcV3.new(doc).transform
  end

  context "with a single author on the title line" do
    let(:author_line) { "Jane Roe <jane@roe.example>" }

    it "emits the author into the front matter" do
      expect(rfc_xml).to include('<author initials="J." surname="Roe"')
      expect(rfc_xml).to include("jane@roe.example")
    end

    it "validates clean on the model" do
      v = Metanorma::Ietf::RfcValidate.new
      v.content_validate(rfc_model)
      v.content_warnings(rfc_model)
      expect(v).not_to be_fatal
    end
  end

  context "with several authors on the title line" do
    let(:author_line) { "Jane Roe <jane@roe.example>; John Q. Public" }

    it "emits every author in order" do
      expect(rfc_xml.scan("<author ").size).to eq(2)
      expect(rfc_xml).to include('surname="Roe"')
      expect(rfc_xml).to include('surname="Public"')
      expect(rfc_xml.index("Roe")).to be < rfc_xml.index("Public")
    end
  end

  context "with :fullname: declared alongside the author line" do
    let(:author_line) { "Jane Roe <jane@roe.example>" }
    let(:extra_attrs) do
      ":fullname: Arthur Pendragon\n:surname: Pendragon"
    end

    it "emits only the declared author, not both" do
      expect(rfc_xml.scan("<author ").size).to eq(1)
      expect(rfc_xml).to include('fullname="Arthur Pendragon"')
      expect(rfc_xml).not_to include("Roe")
    end
  end
end
