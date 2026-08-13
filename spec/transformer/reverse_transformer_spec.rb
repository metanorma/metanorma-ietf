# frozen_string_literal: true

require "spec_helper"
require "metanorma/ietf/transformer"

RSpec.describe Metanorma::Ietf::Transformer, "reverse direction" do
  let(:minimal_rfc_xml) do
    <<~XML
      <?xml version="1.0" encoding="utf-8"?>
      <rfc docName="draft-example-00" category="info" ipr="trust200902"
           submissionType="IETF" consensus="true" version="3">
        <front>
          <title>Example Document</title>
          <author fullname="John Doe" surname="Doe" initials="J.">
            <organization>Example Org</organization>
            <address>
              <email>john@example.com</email>
              <uri>http://example.com</uri>
            </address>
          </author>
          <date month="January" year="2024"/>
          <area>General</area>
          <workgroup>Example WG</workgroup>
          <abstract>
            <t>This is an abstract.</t>
          </abstract>
        </front>
        <middle>
          <section anchor="s1">
          <name>Introduction</name>
            <t>Hello world.</t>
            <ul>
              <li>Item one</li>
              <li>Item two</li>
            </ul>
          </section>
          <section anchor="s2">
          <name>Details</name>
            <t>More text with <strong>bold</strong> and <em>italic</em>.</t>
            <ol type="1">
              <li>First</li>
              <li>Second</li>
            </ol>
            <dl>
              <dt>Term1</dt>
              <dd>Definition of term 1.</dd>
              <dt>Term2</dt>
              <dd>Definition of term 2.</dd>
            </dl>
          </section>
        </middle>
        <back>
          <references anchor="normative">
            <name>Normative References</name>
            <reference anchor="RFC2119" target="https://www.rfc-editor.org/info/rfc2119">
              <front>
                <title>Key Words</title>
                <author fullname="S. Bradner"/>
                <date month="March" year="1997"/>
              </front>
              <refcontent>RFC 2119</refcontent>
              <seriesInfo name="IETF" value="RFC 2119"/>
            </reference>
          </references>
        </back>
      </rfc>
    XML
  end

  let(:result) { described_class.convert(minimal_rfc_xml, direction: :reverse) }

  describe "basic round-trip" do
    it "produces non-empty Metanorma XML" do
      expect(result).not_to be_empty
      expect(result).to include("<metanorma")
    end

    it "preserves the document title" do
      expect(result).to include("Example Document")
    end

    it "preserves the author name" do
      expect(result).to include("John Doe")
      expect(result).to include("Doe")
    end

    it "preserves the organization" do
      expect(result).to include("Example Org")
    end
  end

  describe "bibdata" do
    it "sets docnumber" do
      expect(result).to include("draft-example-00")
    end

    it "sets doctype" do
      expect(result).to include("internet-draft")
    end

    it "sets ipr" do
      expect(result).to include("trust200902")
    end

    it "sets date" do
      expect(result).to include("2024")
    end

    it "sets area" do
      expect(result).to include("General")
    end

    it "sets workgroup" do
      expect(result).to include("Example WG")
    end
  end

  describe "sections" do
    it "builds clause sections" do
      expect(result).to include("<clause")
    end

    it "preserves section titles" do
      expect(result).to include("Introduction")
      expect(result).to include("Details")
    end

    it "preserves paragraph text" do
      expect(result).to include("Hello world.")
      expect(result).to include("More text")
    end

    it "builds unordered lists" do
      expect(result).to include("<ul")
      expect(result).to include("Item one")
      expect(result).to include("Item two")
    end

    it "builds ordered lists" do
      expect(result).to include("<ol")
      expect(result).to include("First")
      expect(result).to include("Second")
    end

    it "builds definition lists" do
      expect(result).to include("<dl")
      expect(result).to include("Term1")
      expect(result).to include("Term2")
    end
  end

  describe "inline elements" do
    it "preserves strong text" do
      expect(result).to include("bold")
    end

    it "preserves em text" do
      expect(result).to include("italic")
    end
  end

  describe "bibliography" do
    it "builds bibliography section" do
      expect(result).to include("<bibliography")
    end

    it "preserves reference title" do
      expect(result).to include("Key Words")
    end

    it "preserves reference anchor" do
      expect(result).to include("RFC2119")
    end
  end

  describe "abstract" do
    it "builds abstract section in preface" do
      expect(result).to include("This is an abstract.")
    end
  end

  describe "contributors" do
    it "wires author to bibdata contributors" do
      expect(result).to include("<contributor")
    end

    it "preserves email" do
      expect(result).to include("john@example.com")
    end
  end

  describe "round-trip fixture test" do
    let(:forward_input) { File.read("spec/fixtures/transformer/input/example.xml") }

    it "reverse-transforms RFC XML without crashing" do
      # First do a forward transform to get RFC XML
      rfc_xml = described_class.convert(forward_input, direction: :forward)
      expect(rfc_xml).not_to be_empty

      # Then reverse it back to Metanorma XML
      mn_xml = described_class.convert(rfc_xml, direction: :reverse)
      expect(mn_xml).not_to be_empty
      expect(mn_xml).to include("<metanorma")
    end
  end

  # ── Unit tests for reverse transformer internals ──

  describe "RfcV3ToIetf unit tests" do
    let(:transformer) do
      rfc = Rfcxml::V3::Rfc.from_xml(minimal_rfc_xml)
      Metanorma::Ietf::Transformer::RfcV3ToIetf::Transformer.new(rfc)
    end

    it "determines doctype as internet-draft for draft- prefix" do
      expect(transformer.determine_doctype).to eq("internet-draft")
    end

    it "resolves IDs correctly" do
      node = Struct.new(:anchor).new("section-1")
      expect(transformer.resolve_id(node)).to eq("section-1")
    end

    it "returns nil when no anchor" do
      node = Struct.new(:anchor).new(nil)
      expect(transformer.resolve_id(node)).to be_nil
    end

    it "maps ol type to canonical MN values" do
      expect(transformer.ol_type_to_mn("1")).to eq("arabic")
      expect(transformer.ol_type_to_mn("a")).to eq("alphabet")
      expect(transformer.ol_type_to_mn("A")).to eq("alphabet_upper")
      expect(transformer.ol_type_to_mn("i")).to eq("roman")
      expect(transformer.ol_type_to_mn("I")).to eq("roman_upper")
    end

    it "maps artwork type to MIME" do
      expect(transformer.art_type_to_mime("svg")).to eq("image/svg+xml")
      expect(transformer.art_type_to_mime("png")).to eq("image/png")
      expect(transformer.art_type_to_mime("jpg")).to eq("image/jpeg")
    end

    it "converts month name to number" do
      expect(transformer.date_month_to_num("January")).to eq("01")
      expect(transformer.date_month_to_num("December")).to eq("12")
      expect(transformer.date_month_to_num(nil)).to eq("01")
    end

    it "builds localized string" do
      ls = transformer.build_localized_string("test")
      expect(ls.value).to eq(["test"])
    end

    it "builds title element" do
      title = transformer.build_title_element("My Title")
      expect(title.text).to eq(["My Title"])
    end

    it "returns nil for empty title" do
      expect(transformer.build_title_element("")).to be_nil
      expect(transformer.build_title_element(nil)).to be_nil
    end
  end
end
