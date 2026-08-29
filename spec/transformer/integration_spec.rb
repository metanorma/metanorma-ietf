# frozen_string_literal: true

require "spec_helper"
require "metanorma-ietf"
require "metanorma/ietf/transformer"
require "tempfile"

RSpec.describe "Full pipeline integration", type: :integration do
  let(:adoc_input) do
    <<~ADOC
      = A Standard for IP Datagrams on Avian Carriers
      David Waitzman
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib:
      :flush-caches: true
      :fullname: David Waitzman
      :surname: Waitzman
      :initials: D.
      :affiliation: BBN STC
      :email: dwaitzman@BBN.COM
      :ipr: trust200902
      :submission-type: IETF
      :area: Internet
      :workgroup: Network Working Group
      :category: info
      :consensus: true
      :abbrev: IP on Avian Carriers
      :keywords: avian, ip, datagram

      == Abstract

      Avian carriers can provide high delay, low throughput, and low
      altitude service.

      == Status of This Memo

      This document is not an Internet Standards Track specification.

      == Introduction

      This document describes a method for encapsulating IP datagrams
      in avian carriers.

      The IP datagram is printed, on a small scroll of paper, in hexadecimal,
      with each octet separated by whitestuff and blackstuff.

      NOTE: This is an April 1 RFC.

      == Frame Format

      Upon receipt, the duct tape is removed and the paper copy of the
      datagram is optically scanned into an electronically transmittable form.

      === Sub-frame

      More details about the frame format.

      * Item one with details
      * Item two with details
      * Item three

      . First step
      . Second step
      . Third step

      Term1:: Definition of term 1.
      Term2:: Definition of term 2.

      [[table1]]
      [cols="2",options="header"]
      |===
      | ID | Description

      | TBD
      | SM2
      |===

      == Mailing Lists

      Avian carriers can be used without significant interference.

      The implementor MUST provide food and water.

      == Security Considerations

      Security is not generally a problem in normal operation, but special
      measures MUST be taken when avian carriers are used in a tactical
      environment.

      [bibliography]
      == References

      * [[[RFC2119,Key Words]]] S. Bradner, _Key Words for Use in RFCs to Indicate Requirement Levels_, BCP 14, RFC 2119, March 1997.
    ADOC
  end

  let(:options) { [{ backend: :ietf, header_footer: true }].freeze }

  def convert_adoc_to_semantic_xml(adoc)
    Asciidoctor.convert(adoc, *options)
  end

  def convert_semantic_xml_to_rfc_xml(semantic_xml)
    Metanorma::Ietf::Transformer.convert(semantic_xml, direction: :forward)
  end

  def run_xml2rfc(rfc_xml, format: "--text")
    input = Tempfile.new(["integration_test", ".xml"])
    output = Tempfile.new(["integration_test", ".txt"])
    begin
      input.write(rfc_xml)
      input.flush

      stdout, stderr, status = Open3.capture3(
        "xml2rfc", format, input.path, "-o", output.path
      )
      [stdout + stderr, status]
    ensure
      input.close
      output.close
    end
  end

  # ── Step 1: ADOC → Semantic XML ──

  describe "ADOC → Semantic XML" do
    let(:semantic_xml) { convert_adoc_to_semantic_xml(adoc_input) }

    it "produces valid semantic XML" do
      expect(semantic_xml).to include("<metanorma")
      expect(semantic_xml).to include("<bibdata")
      expect(semantic_xml).to include("<sections")
    end

    it "preserves document title" do
      expect(semantic_xml).to include("A Standard for IP Datagrams on Avian Carriers")
    end

    it "preserves author metadata" do
      expect(semantic_xml).to include("Waitzman")
    end

    it "preserves section content" do
      expect(semantic_xml).to include("Introduction")
      expect(semantic_xml).to include("Frame Format")
      expect(semantic_xml).to include("Security Considerations")
    end
  end

  # ── Step 2: Semantic XML → metanorma-document model ──

  describe "Semantic XML → metanorma-document model parsing" do
    let(:semantic_xml) { convert_adoc_to_semantic_xml(adoc_input) }

    it "parses into a Root model without errors" do
      stripped = semantic_xml.gsub(/\sxmlns="[^"]*"/, "")
      root = Metanorma::IetfDocument::Root.from_xml(stripped)
      expect(root).to be_a(Metanorma::IetfDocument::Root)
      expect(root.bibdata).not_to be_nil
      expect(root.sections).not_to be_nil
    end
  end

  # ── Step 3: Model → RFC XML v3 via Transformer ──

  describe "Semantic XML → RFC XML v3 via Transformer" do
    let(:semantic_xml) { convert_adoc_to_semantic_xml(adoc_input) }
    let(:rfc_xml) { convert_semantic_xml_to_rfc_xml(semantic_xml) }

    it "produces valid RFC XML v3 structure" do
      expect(rfc_xml).to include('<?xml version="1.0"')
      expect(rfc_xml).to include("<rfc")
      expect(rfc_xml).to include("<front>")
      expect(rfc_xml).to include("<middle>")
      expect(rfc_xml).to include("<back>")
    end

    it "includes PI settings" do
      expect(rfc_xml).to include('<?rfc sortrefs="yes"?>')
      expect(rfc_xml).to include('<?rfc symrefs="yes"?>')
    end

    it "preserves front matter" do
      expect(rfc_xml).to include("<title")
      expect(rfc_xml).to include("A Standard for IP Datagrams on Avian Carriers")
      expect(rfc_xml).to include("David Waitzman")
      expect(rfc_xml).to include("BBN STC")
      expect(rfc_xml).to include("dwaitzman@BBN.COM")
    end

    it "preserves IETF metadata" do
      expect(rfc_xml).to include('ipr="trust200902"')
      expect(rfc_xml).to include('submissionType="IETF"')
      expect(rfc_xml).to include('consensus="true"')
      expect(rfc_xml).to include("<area>Internet</area>")
    end

    it "preserves sections with names" do
      expect(rfc_xml).to include("<name>Introduction</name>")
      expect(rfc_xml).to include("<name>Frame Format</name>")
      expect(rfc_xml).to include("<name>Security Considerations</name>")
    end

    it "preserves paragraph text" do
      expect(rfc_xml).to include("encapsulating IP datagrams")
      expect(rfc_xml).to include("duct tape is removed")
    end

    it "preserves lists" do
      expect(rfc_xml).to include("<ul")
      expect(rfc_xml).to include("<ol")
      expect(rfc_xml).to include("Item one with details")
    end

    it "preserves tables" do
      expect(rfc_xml).to include("<table")
      expect(rfc_xml).to include("<thead>")
      expect(rfc_xml).to include("SM2")
    end

    it "preserves BCP14 keywords in text" do
      expect(rfc_xml).to include("MUST")
    end

    it "preserves notes" do
      expect(rfc_xml).to include("<aside")
      expect(rfc_xml).to include("April 1 RFC")
    end

    it "preserves bibliography" do
      expect(rfc_xml).to include("<references")
      expect(rfc_xml).to include("Key Words")
    end
  end

  # ── Step 4: xml2rfc validation ──

  describe "RFC XML v3 → xml2rfc", if: ENV["CI"] || `which xml2rfc 2>/dev/null`.strip != "" do
    let(:semantic_xml) { convert_adoc_to_semantic_xml(adoc_input) }
    let(:rfc_xml) { convert_semantic_xml_to_rfc_xml(semantic_xml) }

    around(:example) do |example|
      Timecop.return
      example.run
      Timecop.freeze Time.at(946702800).utc
    end

    it "produces RFC XML accepted by xml2rfc" do
      output, status = run_xml2rfc(rfc_xml)
      expect(status.exitstatus).to eq(0),
        "xml2rfc failed:\n#{output}\n\nRFC XML:\n#{rfc_xml[0..2000]}"
    end

    it "produces text output" do
      output, status = run_xml2rfc(rfc_xml)
      expect(status.exitstatus).to eq(0),
        "xml2rfc failed:\n#{output}\n\nRFC XML:\n#{rfc_xml[0..2000]}"

      text_output, text_status = run_xml2rfc(rfc_xml, format: "--text")
      expect(text_status.exitstatus).to eq(0),
        "xml2rfc text failed:\n#{text_output}"
    end
  end

  # ── Fixture-based pipeline tests ──

  describe "fixture semantic XML → RFC XML v3 → xml2rfc" do
    shared_examples "produces xml2rfc-accepted output" do |fixture_path|
      let(:semantic_xml) { File.read(fixture_path) }
      let(:rfc_xml) { convert_semantic_xml_to_rfc_xml(semantic_xml) }

      it "produces RFC XML with correct structure" do
        expect(rfc_xml).to include("<rfc")
        expect(rfc_xml).to include("<front>")
        expect(rfc_xml).to include("<middle>")
      end

      it "is accepted by xml2rfc", if: ENV["CI"] || `which xml2rfc 2>/dev/null`.strip != "" do
        Timecop.return
        output, status = run_xml2rfc(rfc_xml)
        Timecop.freeze Time.at(946702800).utc
        expect(status.exitstatus).to eq(0),
          "xml2rfc failed for #{fixture_path}:\n#{output}\n\nRFC XML:\n#{rfc_xml[0..2000]}"
      end
    end

    it_behaves_like "produces xml2rfc-accepted output",
      "spec/fixtures/transformer/input/example.xml"

    it_behaves_like "produces xml2rfc-accepted output",
      "spec/fixtures/transformer/input/antioch.xml"
  end

  # ── Pipeline 2: RFC XML → reverse → forward → xml2rfc ──

  describe "round-trip: RFC XML v3 → reverse (MN XML) → forward (RFC XML v3)" do
    shared_examples "round-trips cleanly through xml2rfc" do |fixture_path|
      let(:semantic_xml) { File.read(fixture_path) }
      let(:forward_rfc_xml) { convert_semantic_xml_to_rfc_xml(semantic_xml) }
      let(:reverse_mn_xml) do
        Metanorma::Ietf::Transformer.convert(forward_rfc_xml, direction: :reverse)
      end
      let(:roundtrip_rfc_xml) { convert_semantic_xml_to_rfc_xml(reverse_mn_xml) }

      it "reverse transform produces valid metanorma XML" do
        expect(reverse_mn_xml).to include("<metanorma")
        expect(reverse_mn_xml).to include("<bibdata")
        expect(reverse_mn_xml).to include("<sections")
      end

      it "round-trip RFC XML has correct structure" do
        expect(roundtrip_rfc_xml).to include('<?xml version="1.0"')
        expect(roundtrip_rfc_xml).to include("<rfc")
        expect(roundtrip_rfc_xml).to include("<front>")
        expect(roundtrip_rfc_xml).to include("<middle>")
        expect(roundtrip_rfc_xml).to include("<back>")
      end

      it "preserves title across round-trip" do
        title_match = forward_rfc_xml.match(/<title[^>]*>(.*?)<\/title>/m)
        skip "No title found in forward RFC XML" unless title_match
        title_text = title_match[1].gsub(/<[^>]+>/, "").strip
        expect(roundtrip_rfc_xml).to include(title_text),
          "Title '#{title_text}' lost in round-trip"
      end

      it "preserves section structure across round-trip" do
        section_count = forward_rfc_xml.scan(/<section\b/).size
        roundtrip_section_count = roundtrip_rfc_xml.scan(/<section\b/).size
        expect(roundtrip_section_count).to be >= section_count - 1,
          "Lost sections in round-trip: had #{section_count}, got #{roundtrip_section_count}"
      end

      it "round-tripped RFC XML is accepted by xml2rfc",
         if: ENV["CI"] || `which xml2rfc 2>/dev/null`.strip != "" do
        Timecop.return
        output, status = run_xml2rfc(roundtrip_rfc_xml)
        Timecop.freeze Time.at(946702800).utc

        errors = output.scan(/Error:/)
        expect(errors).to be_empty,
          "xml2rfc errors after round-trip for #{fixture_path}:\n#{output}\n\nRFC XML:\n#{roundtrip_rfc_xml[0..3000]}"

        expect(status.exitstatus).to eq(0),
          "xml2rfc failed for round-tripped #{fixture_path}:\n#{output}\n\nRFC XML:\n#{roundtrip_rfc_xml[0..3000]}"
      end
    end

    it_behaves_like "round-trips cleanly through xml2rfc",
      "spec/fixtures/transformer/input/example.xml"

    it_behaves_like "round-trips cleanly through xml2rfc",
      "spec/fixtures/transformer/input/antioch.xml"
  end

  # ── Round-trip with inline ADOC document ──

  describe "round-trip: ADOC → RFC XML → reverse → forward → xml2rfc" do
    let(:semantic_xml) { convert_adoc_to_semantic_xml(adoc_input) }
    let(:forward_rfc_xml) { convert_semantic_xml_to_rfc_xml(semantic_xml) }
    let(:reverse_mn_xml) do
      Metanorma::Ietf::Transformer.convert(forward_rfc_xml, direction: :reverse)
    end
    let(:roundtrip_rfc_xml) { convert_semantic_xml_to_rfc_xml(reverse_mn_xml) }

    it "preserves document title across full round-trip" do
      expect(roundtrip_rfc_xml).to include("A Standard for IP Datagrams on Avian Carriers")
    end

    it "preserves author across full round-trip" do
      expect(roundtrip_rfc_xml).to include("Waitzman")
    end

    it "preserves section names across full round-trip" do
      expect(roundtrip_rfc_xml).to include("Introduction")
      expect(roundtrip_rfc_xml).to include("Frame Format")
      expect(roundtrip_rfc_xml).to include("Security Considerations")
    end

    it "preserves paragraph content across full round-trip" do
      expect(roundtrip_rfc_xml).to include("encapsulating IP datagrams")
      expect(roundtrip_rfc_xml).to include("duct tape is removed")
    end

    it "preserves list elements across full round-trip" do
      expect(roundtrip_rfc_xml).to include("<ul")
      expect(roundtrip_rfc_xml).to include("<ol")
      expect(roundtrip_rfc_xml).to include("Item three")
    end

    it "round-tripped RFC XML is accepted by xml2rfc",
       if: ENV["CI"] || `which xml2rfc 2>/dev/null`.strip != "" do
      Timecop.return
      output, status = run_xml2rfc(roundtrip_rfc_xml)
      Timecop.freeze Time.at(946702800).utc

      errors = output.scan(/Error:/)
      expect(errors).to be_empty,
        "xml2rfc errors after ADOC round-trip:\n#{output}\n\nRFC XML:\n#{roundtrip_rfc_xml[0..3000]}"

      expect(status.exitstatus).to eq(0),
        "xml2rfc failed after ADOC round-trip:\n#{output}\n\nRFC XML:\n#{roundtrip_rfc_xml[0..3000]}"
    end
  end
end
