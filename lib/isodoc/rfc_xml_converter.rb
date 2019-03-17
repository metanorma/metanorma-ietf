require "nokogiri"

module IsoDoc
  class RfcXmlConverter
    attr_reader :document

    def initialize(document)
      @document = document
    end

    def convert
      build_rfc_document.to_xml
    end

    def self.convert(document)
      new(document).convert
    end

    private

    def nokogiri_document
      @nokogiri_document ||= Nokogiri.XML(document)
    end

    def find_element(xpath)
      nokogiri_document.search(xpath)
    end

    def find_text(xpath)
      find_element(xpath).text
    end

    def build_rfc_document
      Nokogiri::XML::Builder.new do |xml|
        xml.rfc(set_submission_type) {
          xml.front {
            xml.title find_text(elements[:title])
            xml.author(fullname: find_text(elements[:fullname]))
          }
        }
      end
    end

    def set_submission_type
      { submissionType: 'IETF' }
    end

    def elements
      {
        title: "bibdata/title",
        fullname: "contributor/person/name/completename",
      }
    end
  end
end
