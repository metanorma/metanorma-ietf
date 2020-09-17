require "spec_helper"
require "fileutils"

RSpec.describe Asciidoctor::Ietf do
  it "warns that image is not SVG" do
      FileUtils.rm_f "test.err"
     Asciidoctor.convert(<<~"INPUT", backend: :ietf, header_footer: true) 
  #{VALIDATING_BLANK_HDR}

  image::spec/assets/rice_image1.png[]
  INPUT
    expect(File.read("test.err")).to include "image spec/assets/rice_image1.png is not SVG"
  end

  it "does not warn that image is SVG" do
      FileUtils.rm_f "test.err"
     Asciidoctor.convert(<<~"INPUT", backend: :ietf, header_footer: true) 
  #{VALIDATING_BLANK_HDR}

  image::spec/assets/Example.svg[]
  INPUT
     if(File.exist?("test.err"))
    expect(File.read("test.err")).not_to include "is not SVG"
     end
  end

  it "warns of invalid workgroup" do
        VCR.use_cassette "workgroup_fetch", :re_record_interval => 25200 do
      FileUtils.rm_f "test.err"
     Asciidoctor.convert(<<~"INPUT", backend: :ietf, header_footer: true)
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :workgroup: Group
  :flush-caches: true

  INPUT
    expect(File.read("test.err")).to include "unrecognised working group"
  end
  end

  it "does not warn of valid workgroup suffixed with Working Group" do
        VCR.use_cassette "workgroup_fetch", :re_record_interval => 25200 do
      FileUtils.rm_f "test.err"
     Asciidoctor.convert(<<~"INPUT", backend: :ietf, header_footer: true)
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :workgroup: Global Access to the Internet for All Research Group
  :flush-caches: true

  INPUT
     if(File.exist?("test.err"))
    expect(File.read("test.err")).not_to include "unrecognised working group"
     end
  end
  end

end
