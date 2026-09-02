# frozen_string_literal: true

require_relative "../../../../spec_helper"

RSpec.describe Metanorma::Ietf::Document::Metadata::IetfBibDataExtensionType do
  it "maps the camelCase rfc-attribute channel" do
    xml = <<~XML
      <ext>
        <doctype>internet-draft</doctype>
        <ipr>trust200902</ipr>
        <symRefs>false</symRefs>
        <tocInclude>false</tocInclude>
        <sortRefs>true</sortRefs>
        <pi><tocinclude>no</tocinclude><symrefs>false</symrefs></pi>
      </ext>
    XML

    ext = described_class.from_xml(xml)

    expect(ext.doctype).to eq("internet-draft")
    expect(ext.sym_refs).to eq("false")
    expect(ext.toc_include).to eq("false")
    expect(ext.sort_refs).to eq("true")
    expect(ext.pi.tocinclude).to eq("no")
    expect(ext.pi.symrefs).to eq("false")
  end

  it "maps the legacy pi toc channel under both spellings" do
    legacy = described_class.from_xml("<ext><pi><toc>no</toc></pi></ext>")
    emitted = described_class.from_xml("<ext><pi><tocinclude>no</tocinclude></pi></ext>")

    expect(legacy.pi.toc).to eq("no")
    expect(emitted.pi.tocinclude).to eq("no")
  end
end
