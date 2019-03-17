require "spec_helper"
require "metanorma-ietf"

RSpec.describe IsoDoc::RfcXmlConverter do
  describe "appendix converter" do
    it "converts the metanorma xml to rfc xml" do
      metanorma_xml = convert_asciidoc(appendix_in_asciidoc)
      document = IsoDoc::RfcXmlConverter.convert(metanorma_xml)

      puts document.inspect
    end
  end

  def appendix_in_asciidoc
    <<~XML
      = Document title
      :fullname: Simon Perreault
      :lastname: Perreault

      == Section 1
      text

      [appendix]
      == Appendix
      text
    XML
  end

  def convert_asciidoc(document)
    Asciidoctor.convert(document, backend: :ietf, header_footer: true)
  end
end
