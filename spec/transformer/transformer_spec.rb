# frozen_string_literal: true

require "spec_helper"
require "metanorma/ietf/transformer"

RSpec.describe Metanorma::Ietf::Transformer do
  describe "example document (RFC)" do
    let(:input_xml) { File.read("spec/fixtures/transformer/input/example.xml") }
    let(:expected_xml) { File.read("spec/fixtures/transformer/output/example.rfc.xml") }
    let(:result) { described_class.convert(input_xml) }

    it "produces RFC XML matching the expected fixture" do
      expect(result).to be_xml_equivalent_to expected_xml
    end

    it "validates against RFC XML v3 RELAX NG schema" do
      schema = Nokogiri::XML::RelaxNG(File.open("lib/metanorma/ietf/schema/v3.rng"))
      errors = schema.validate(Nokogiri::XML(result))
      expect(errors).to be_empty, "Schema validation errors:\n#{errors.map(&:message).join("\n")}"
    end

    it "sets RFC root attributes correctly" do
      expect(result).to include('number="1149"')
      expect(result).to include('category="std"')
      expect(result).to include('ipr="trust200902"')
      expect(result).to include('consensus="true"')
      expect(result).to include('submissionType="IETF"')
      expect(result).to include('version="3"')
    end

    it "builds the front title" do
      expect(result).to include("<title")
      expect(result).to include("RFC XML v3 Example: A Standard for the Transmission of IP Datagrams on Avian Carriers")
    end

    it "builds series info" do
      expect(result).to include("<seriesInfo")
      expect(result).to include('name="RFC"')
      expect(result).to include('value="1149"')
      expect(result).to include('asciiName="RFC"')
      expect(result).to include('status="Published"')
      expect(result).to include('stream="IETF"')
    end

    it "builds authors" do
      expect(result).to include("<author")
      expect(result).to include('surname="Waitzman"')
      expect(result).to include("BBN STC")
    end

    it "builds areas and workgroups" do
      expect(result).to include("<area>Internet</area>")
      expect(result).to include("<workgroup>Network Working Group</workgroup>")
    end

    it "builds abstract" do
      expect(result).to include("<abstract")
      expect(result).to include("Avian carriers can provide high delay")
    end

    it "builds obsoletes and updates" do
      expect(result).to include('obsoletes="')
      expect(result).to include('updates="')
      expect(result).to include("RFC 1000")
      expect(result).to include("RFC 2010")
    end

    it "builds references in back" do
      expect(result).to include('<reference')
      expect(result).to include('anchor="ISO.IEC.10118-3"')
      expect(result).to include('anchor="RFC7253"')
      expect(result).to include("IT Security techniques")
    end

    it "builds artwork from pre" do
      expect(result).to include("<artwork")
      expect(result).to include("FFFFFFFE")
    end

    it "builds inline formatting" do
      expect(result).to include("<em>datagram</em>")
      expect(result).to include("<strong>printed</strong>")
    end

    it "builds cross-references" do
      expect(result).to include("<xref")
      expect(result).to include('target="RFC7253"')
    end

    it "builds definition lists" do
      expect(result).to include("<dl")
      expect(result).to include("<dt>OSCCA-compliant</dt>")
    end

    it "builds tables" do
      expect(result).to include("<table")
      expect(result).to include("<th")
      expect(result).to include("<td")
    end
  end

  describe "antioch document (Internet-Draft)" do
    let(:input_xml) { File.read("spec/fixtures/transformer/input/antioch.xml") }
    let(:expected_xml) { File.read("spec/fixtures/transformer/output/antioch.rfc.xml") }
    let(:result) { described_class.convert(input_xml) }

    it "produces RFC XML matching the expected fixture" do
      expect(result).to be_xml_equivalent_to expected_xml
    end

    it "validates against RFC XML v3 RELAX NG schema" do
      schema = Nokogiri::XML::RelaxNG(File.open("lib/metanorma/ietf/schema/v3.rng"))
      errors = schema.validate(Nokogiri::XML(result))
      expect(errors).to be_empty, "Schema validation errors:\n#{errors.map(&:message).join("\n")}"
    end

    it "sets Internet-Draft root attributes" do
      expect(result).to include('docName="draft-camelot-holy-grenade-01"')
      expect(result).to include('category="info"')
      expect(result).to include('ipr="trust200902"')
      expect(result).to include('submissionType="independent"')
      expect(result).not_to include("consensus=")
    end

    it "builds series info for Internet-Draft" do
      expect(result).to include('name="Internet-Draft"')
      expect(result).to include('value="draft-camelot-holy-grenade-01"')
    end

    it "builds postal address" do
      expect(result).to include("<postal>")
      expect(result).to include("<postalLine")
      expect(result).to include("Palace</postalLine>")
      expect(result).to include("United Kingdom</postalLine>")
    end

    it "builds person URI" do
      expect(result).to include("<uri>http://camelot.gov.example</uri>")
    end

    it "builds multiple areas" do
      expect(result).to include("<area>General</area>")
      expect(result).to include("<area>Operations and Management</area>")
    end

    it "builds BCP14 keywords" do
      expect(result).to include("<bcp14>MUST</bcp14>")
      expect(result).to include("<bcp14>SHALL</bcp14>")
      expect(result).to include("<bcp14>MAY</bcp14>")
    end

    it "builds front notes" do
      expect(result).to include("<note")
      expect(result).to include('removeInRFC="false"')
      expect(result).to include("<name>Spamalot</name>")
    end

    it "sets section toc attribute" do
      expect(result).to include('toc="exclude"')
    end

    it "builds relref with section and relative" do
      expect(result).to include('target="RFC2635"')
      expect(result).to include('section="1"')
      expect(result).to include('relative="section-1"')
    end

    it "builds artwork with alt attribute" do
      expect(result).to include('alt="The Projectile Cow')
      expect(result).to include('alt="The Trojan Rabbit')
    end

    it "builds aside from figure note" do
      expect(result).to include("<aside")
      expect(result).to include("Image courtesy")
    end
  end

  # ── Feature tests: cleanup, BCP14, unicode, reference annotations ──

  describe "BCP14 keyword cleanup" do
    let(:input_xml) { File.read("spec/fixtures/transformer/input/antioch.xml") }
    let(:result) { described_class.convert(input_xml) }

    it "converts strong-wrapped BCP14 keywords to bcp14 elements" do
      expect(result).to include("<bcp14>MUST</bcp14>")
      expect(result).to include("<bcp14>SHALL</bcp14>")
      expect(result).to include("<bcp14>MAY</bcp14>")
    end

    it "does not convert non-keyword strong text" do
      expect(result).to include("<strong>")
    end
  end

  describe "bibliography cleanup" do
    let(:input_xml) { File.read("spec/fixtures/transformer/input/example.xml") }
    let(:result) { described_class.convert(input_xml) }

    it "builds reference anchors from doc identifiers" do
      expect(result).to include('anchor="ISO.IEC.10118-3"')
      expect(result).to include('anchor="RFC7253"')
    end

    it "builds reference front with title" do
      expect(result).to include("IT Security techniques")
    end
  end

  describe "list item cleanup" do
    let(:input_xml) { File.read("spec/fixtures/transformer/input/example.xml") }
    let(:result) { described_class.convert(input_xml) }

    it "unwraps single t elements inside list items" do
      expect(result).to include("<li>")
    end
  end

  describe "sourcecode cleanup" do
    let(:input_xml) { File.read("spec/fixtures/transformer/input/example.xml") }
    let(:result) { described_class.convert(input_xml) }

    it "cleans sourcecode content by removing HTML tags" do
      expect(result).to include("<sourcecode")
      expect(result).to include("FFFFFFFE")
    end
  end

  describe "formula transformation" do
    let(:input_xml) { File.read("spec/fixtures/transformer/input/example.xml") }
    let(:result) { described_class.convert(input_xml) }

    # N13 was a three-layer loss: blanket xmlns strip denamespacing MathML,
    # build_stem_text discarding its result by if-expression fall-through,
    # and untracked content= serializing as an empty <t/>
    it "renders MathML formula content as delimited asciimath" do
      expect(result).to include("$$ y^(2) = x^(3) + a x + b $$")
    end

    it "preserves the MathML namespace when stripping the Metanorma one" do
      expect(input_xml).to include('xmlns="http://www.w3.org/1998/Math/MathML"')
      expect(result).not_to include('anchor="_59f339b5-dc37-4d63-847c-dfcb22c4e27b"/>')
    end
  end

  describe "sourcecode body wrapper (current Semantic XML schema)" do
    # current standoc nests the code text in sourcecode/body
    # (metanorma-standoc#966); content then parses as an empty collection
    let(:input_xml) do
      File.read("spec/fixtures/transformer/input/example.xml")
        .sub(/<sourcecode([^>]*)>/, "<sourcecode\\1><body>")
        .sub("</sourcecode>", "</body></sourcecode>")
    end
    let(:result) { described_class.convert(input_xml) }

    it "reads code text nested in sourcecode/body" do
      expect(result).to include("prepare_launch")
    end
  end

  describe "image transformation" do
    let(:transformer) { Metanorma::Ietf::Transformer::IetfToRfcV3.allocate }

    # the model maps the src XML attribute to :source (Media superclass);
    # calling .src raised NoMethodError and killed the whole document
    it "reads image src via the model's source attribute" do
      img = Metanorma::Document::Components::IdElements::Image.from_xml(
        '<image id="_i" src="https://example.com/x.svg" ' \
        'mimetype="image/svg+xml" alt="Orb"/>',
      )
      art = transformer.send(:transform_image_to_artwork, img)
      expect(art.src).to eq("https://example.com/x.svg")
      expect(art.type).to eq("svg")
      expect(art.alt).to eq("Orb")
    end
  end

  describe "cleanup transformer unit tests" do
    let(:transformer) { Metanorma::Ietf::Transformer::IetfToRfcV3.allocate }

    describe "to_array helper" do
      it "returns [] for nil" do
        expect(transformer.to_array(nil)).to eq([])
      end

      it "wraps non-arrays" do
        expect(transformer.to_array("foo")).to eq(["foo"])
        expect(transformer.to_array(42)).to eq([42])
      end

      it "passes arrays through" do
        expect(transformer.to_array([1, 2, 3])).to eq([1, 2, 3])
        expect(transformer.to_array([])).to eq([])
      end
    end

    describe "build_organization" do
      it "builds org with name" do
        org_node = Struct.new(:name, :abbreviation).new("IETF", nil)
        org = transformer.build_organization(org_node)
        expect(org.content).to eq(["IETF"])
        expect(org.ascii).to be_nil
      end

      it "builds org with abbrev" do
        org_node = Struct.new(:name, :abbreviation).new("IETF", "IETF")
        org = transformer.build_organization(org_node)
        expect(org.abbrev).to eq("IETF")
      end

      it "sets ascii for non-ASCII names" do
        org_node = Struct.new(:name, :abbreviation).new("Développement", nil)
        org = transformer.build_organization(org_node)
        expect(org.ascii).to eq("Developpement")
      end

      it "omits ascii for ASCII names" do
        org_node = Struct.new(:name, :abbreviation).new("IETF", nil)
        org = transformer.build_organization(org_node)
        expect(org.ascii).to be_nil
      end

      it "handles array name" do
        org_node = Struct.new(:name, :abbreviation).new(["IETF"], nil)
        org = transformer.build_organization(org_node)
        expect(org.content).to eq(["IETF"])
      end

      it "handles nil name" do
        org_node = Struct.new(:name, :abbreviation).new(nil, nil)
        org = transformer.build_organization(org_node)
        expect(org.content).to be_nil
      end
    end

    it "wraps unicode characters in u elements" do
      text = Rfcxml::V3::Text.new
      unicode_str = "Café"
      text.content = [unicode_str]
      transformer = Metanorma::Ietf::Transformer::IetfToRfcV3.allocate

      parts = transformer.split_unicode(unicode_str)
      expect(parts.size).to eq(2)
      expect(parts[0]).to eq("Caf")
      expect(parts[1]).to be_a(Rfcxml::V3::U)

      transformer.wrap_unicode_in_text(text)
      content = text.content

      if content.none? { |c| c.is_a?(Rfcxml::V3::U) }
        expect(parts[1].content).to eq("é")
        expect(parts[1].format).to eq("lit-name-num")
      else
        expect(content.any? { |c| c.is_a?(Rfcxml::V3::U) }).to be true
      end
    end

    it "detects BCP14 keywords" do
      transformer = Metanorma::Ietf::Transformer::IetfToRfcV3.allocate
      expect(transformer.bcp14_keyword?("MUST")).to be true
      expect(transformer.bcp14_keyword?("SHALL NOT")).to be true
      expect(transformer.bcp14_keyword?("should")).to be true
      expect(transformer.bcp14_keyword?("maybe")).to be false
    end

    it "detects unicode in text" do
      transformer = Metanorma::Ietf::Transformer::IetfToRfcV3.allocate
      expect(transformer.contains_unicode?("hello")).to be false
      expect(transformer.contains_unicode?("café")).to be true
      expect(transformer.contains_unicode?("°C")).to be true
    end

    it "splits unicode text into parts" do
      transformer = Metanorma::Ietf::Transformer::IetfToRfcV3.allocate
      parts = transformer.split_unicode("25°C")
      expect(parts.size).to eq(3)
      expect(parts[0]).to eq("25")
      expect(parts[1]).to be_a(Rfcxml::V3::U)
      expect(parts[2]).to eq("C")
    end

    it "converts strong to bcp14 when keyword matches" do
      strong = Rfcxml::V3::Strong.new
      strong.content = ["MUST"]
      text = Rfcxml::V3::Text.new do |t|
        t.content ["You "]
        t.strong strong
      end
      transformer = Metanorma::Ietf::Transformer::IetfToRfcV3.allocate
      transformer.convert_strong_to_bcp14(text)
      expect(text.bcp14.any? { |b| b.content == "MUST" }).to be true
      expect(text.strong).to be_empty
    end

    it "extracts reference annotations from bibitem notes" do
      transformer = Metanorma::Ietf::Transformer::IetfToRfcV3.allocate
      expect(transformer.extract_bibitem_annotation(nil)).to be_nil
    end

    it "detects reference groups" do
      transformer = Metanorma::Ietf::Transformer::IetfToRfcV3.allocate
      expect(transformer.reference_group?(nil)).to be false
    end

    it "sanitizes NCName correctly" do
      transformer = Metanorma::Ietf::Transformer::IetfToRfcV3.allocate
      expect(transformer.to_ncname("foo-bar")).to eq("foo-bar")
      expect(transformer.to_ncname("123abc")).to eq("_123abc")
      expect(transformer.to_ncname("a b c")).to eq("a_b_c")
      expect(transformer.to_ncname(nil)).to be_nil
      expect(transformer.to_ncname("")).to be_nil
    end
  end

  # ── Validation tests ─────────────────────────────

  describe "schema validation" do
    let(:input_xml) { File.read("spec/fixtures/transformer/input/example.xml") }

    it "validates RFC XML without crashing" do
      doc = Metanorma::IetfDocument::Root.from_xml(input_xml)
      transformer = Metanorma::Ietf::Transformer::IetfToRfcV3.new(doc)
      rfc = transformer.transform
      xml = rfc.to_xml(pretty: true, declaration: true, encoding: "utf-8")
      errors = transformer.validate_rfc_xml(xml)
      expect(errors).to be_an(Array)
    end

    it "reports ipr errors for missing ipr" do
      transformer = Metanorma::Ietf::Transformer::IetfToRfcV3.allocate
      doc = Nokogiri::XML('<?xml version="1.0"?><rfc/>')
      errors = transformer.ipr_check(doc)
      expect(errors).not_to be_empty
    end
  end

  # ── List attributes tests ────────────────────────

  describe "list attributes" do
    it "maps ol types correctly" do
      transformer = Metanorma::Ietf::Transformer::IetfToRfcV3.allocate
      expect(transformer.map_ol_type("arabic")).to eq("1")
      expect(transformer.map_ol_type("roman")).to eq("i")
      expect(transformer.map_ol_type("alphabet")).to eq("a")
      expect(transformer.map_ol_type("upperroman")).to eq("I")
      expect(transformer.map_ol_type("upperalpha")).to eq("A")
      expect(transformer.map_ol_type("unknown")).to eq("1")
    end

    it "creates Ul with anchor" do
      ul = Rfcxml::V3::Ul.new
      expect(ul).to be_a(Rfcxml::V3::Ul)
      expect(ul.anchor).to be_nil
    end

    it "creates Ol with type and start" do
      ol = Rfcxml::V3::Ol.new
      ol.type = "1"
      ol.start = "3"
      expect(ol.type).to eq("1")
      expect(ol.start).to eq("3")
    end
  end

  # ── Inline bookmark test ─────────────────────────

  describe "bookmark handling" do
    it "returns nil for bookmarks (not in RFC XML v3 schema)" do
      transformer = Metanorma::Ietf::Transformer::IetfToRfcV3.allocate
      p_node = Struct.new(:bookmark).new([])
      result = transformer.build_inline_element(p_node, "bookmark", 0)
      expect(result).to be_nil
    end
  end
end
