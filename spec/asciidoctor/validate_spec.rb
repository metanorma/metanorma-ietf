require "spec_helper"
require "fileutils"

RSpec.describe Asciidoctor::Ietf do
  it "warns that image is not SVG" do
    FileUtils.rm_f "test.err"
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      image::spec/assets/rice_image1.png[]
    INPUT
    expect(File.read("test.err")).to include "image spec/assets/rice_image1.png is not SVG"
  end

  it "does not warn that image is SVG" do
    FileUtils.rm_f "test.err"
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      image::spec/assets/Example.svg[]
    INPUT
    if File.exist?("test.err")
      expect(File.read("test.err")).not_to include "is not SVG"
    end
  end

  it "warns of invalid workgroup" do
    VCR.use_cassette "workgroup_fetch" do
      FileUtils.rm_f "test.err"
      Asciidoctor.convert(<<~"INPUT", *OPTIONS)
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
    VCR.use_cassette "workgroup_fetch" do
      FileUtils.rm_f "test.err"
      Asciidoctor.convert(<<~"INPUT", *OPTIONS)
        = Document title
        Author
        :docfile: test.adoc
        :nodoc:
        :workgroup: Global Access to the Internet for All Research Group
        :flush-caches: true

      INPUT
      if File.exist?("test.err")
        expect(File.read("test.err")).not_to include "unrecognised working group"
      end
    end
  end

  context "when xref_error.adoc compilation" do
    around do |example|
      FileUtils.rm_f "spec/assets/xref_error.err"
      example.run
      Dir["spec/assets/xref_error*"].each do |file|
        next if file.match?(/adoc$/)

        FileUtils.rm_f(file)
      end
    end

    it "generates error file" do
      expect do
        Metanorma::Compile
          .new
          .compile("spec/assets/xref_error.adoc", type: "ietf", "agree-to-terms": true)
      end.to(change { File.exist?("spec/assets/xref_error.err") }
              .from(false).to(true))
    end
  end
end
