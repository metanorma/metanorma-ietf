require "spec_helper"
require "fileutils"

RSpec.describe Asciidoctor::Ietf do
  it "warns that image is not SVG" do
     expect { Asciidoctor.convert(<<~"INPUT", backend: :ietf, header_footer: true) }.to output(%r{image spec/assets/rice_image1.png is not SVG\!}).to_stderr
  #{VALIDATING_BLANK_HDR}

  image::spec/assets/rice_image1.png[]
  INPUT
  end

  it "does not warn that image is SVG" do
     expect { Asciidoctor.convert(<<~"INPUT", backend: :ietf, header_footer: true) }.not_to output(%r{is not SVG\!}).to_stderr
  #{VALIDATING_BLANK_HDR}

  image::spec/assets/Example.svg[]
  INPUT
  end
end
