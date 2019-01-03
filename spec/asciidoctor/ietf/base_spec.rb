require "spec_helper"
require "metanorma-ietf"

RSpec.describe Asciidoctor::Ietf do
  describe "basic conversion" do
    it "converts the basic document structure" do
      expect(
        Asciidoctor.convert("", backend: :ietf, header_footer: true),
      ).to be_equivalent_to("Sample Document here")
    end
  end
end
