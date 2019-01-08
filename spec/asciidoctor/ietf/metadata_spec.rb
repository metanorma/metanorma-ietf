require "spec_helper"
require "metanorma-ietf"

RSpec.describe Asciidoctor::Ietf do
  describe "basic conversion" do
    it "converts the basic document structure" do
      iso_xml = Asciidoctor.convert(
        asciidoc_metadata, backend: :ietf, header_footer: true
      )

      doc = Nokogiri::XML(iso_xml)
      contributor = doc.at("contributor")

      expect(strip(contributor)).to eq(strip(contributor_xml))
    end
  end

  def strip(document)
    document.to_s.gsub("\n", "").gsub(" ", "")
  end

  def contributor_xml
    '<contributor>
      <roletype="author"/>
      <person>
        <name>
          <completename>SimonPerreault</completename>
          <surname>Perreault</surname>
          <initial>S.</initial>
        </name>
        <contact>
          <address>
            <street>2875Laurier,suiteD2-630</street>
            <country>Canada</country>
            <postcode>G1V2M2</postcode>
            <region>Quebec,QC</region>
          </address>
        </contact>
      </person>
    </contributor>'
  end

  def asciidoc_metadata
    <<~METADATA
    = vCard Format Specification
    Simon Perreault <simon.perreault@viagenie.ca>
    :bibliography-database: rfc6350_refs.xml
    :bibliography-passthrough: true
    :bibliography-prepend-empty: false
    :bibliography-hyperlinks: false
    :bibliography-style: rfc-v2
    :doctype: rfc
    :abbrev: vCard
    :obsoletes: 2425, 2426, 4770
    :updates: 2739
    :name: 6350
    :revdate: 2011-08
    :submission-type: IETF
    :status: standard
    :intended-series: full-standard 6350
    :fullname: Simon Perreault
    :lastname: Perreault
    :forename_initials: S.
    :organization: Viagenie
    :email: simon.perreault@viagenie.ca
    :street: 2875 Laurier, suite D2-630
    :region: Quebec, QC
    :code: G1V 2M2
    :country: Canada
    :phone: +1 418 656 9254
    :uri: http://www.viagenie.ca
    :link: urn:issn:2070-1721 item
    :rfcedstyle: yes
    :ipr: pre5378Trust200902
    :inline-definition-lists: true
    :comments: yes
    :workgroup: first_workgroup, second_workgroup & third_workgroup
    METADATA
  end
end
