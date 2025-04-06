require "spec_helper"
require "fileutils"

RSpec.describe Metanorma::Ietf do
  it "warns that image is not SVG" do
    FileUtils.rm_f "test.err.html"
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      image::spec/assets/rice_image1.png[]
    INPUT
    expect(File.read("test.err.html"))
      .to include("image spec/​assets/rice_​image1.png is not SVG")
  end

  it "does not warn that image is SVG" do
    FileUtils.rm_f "test.err.html"
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      image::spec/assets/Example.svg[]
    INPUT
    if File.exist?("test.err.html")
      expect(File.read("test.err.html"))
        .not_to include("is not SVG")
    end
  end

  it "warns of status in editorial stream" do
    FileUtils.rm_f "test.err.html"
    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :status: standard
      :submission-type: editorial

    INPUT
    expect(File.read("test.err.html"))
      .to include("Editorial stream must have Informational status")

    FileUtils.rm_f "test.err.html"
    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :status: informational
      :submission-type: editorial

    INPUT
    expect(File.read("test.err.html"))
      .not_to include("Editorial stream must have Informational status")
  end

  it "warns of invalid workgroup" do
    VCR.use_cassette "workgroup_fetch" do
      FileUtils.rm_f "test.err.html"
      Asciidoctor.convert(<<~INPUT, *OPTIONS)
        = Document title
        Author
        :docfile: test.adoc
        :nodoc:
        :workgroup: Group
        :flush-caches: true

      INPUT
      expect(File.read("test.err.html"))
        .to include("unrecognised working group")
    end
  end

  it "does not warn of valid workgroup suffixed with Working Group" do
    VCR.use_cassette "workgroup_fetch" do
      FileUtils.rm_f "test.err.html"
      Asciidoctor.convert(<<~INPUT, *OPTIONS)
        = Document title
        Author
        :docfile: test.adoc
        :nodoc:
        :workgroup: Global Access to the Internet for All Research Group
        :flush-caches: true

      INPUT
      if File.exist?("test.err.html")
        expect(File.read("test.err.html"))
          .not_to include("unrecognised working group")
      end
    end
  end

  it "warns of cref macro not pointing to valid element" do
    FileUtils.rm_f "test.err.html"
    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :draft:

      == Clause 1

      cref:[xyz]

      cref:[abc]

      cref:[def]

      [[def]]
      ****
      What?
      ****

      [[abc]]
      == Clause 2

    INPUT
    if File.exist?("test.err.html")
      expect(File.read("test.err.html"))
        .to include("No matching review for cref:​[xyz]")
      expect(File.read("test.err.html"))
        .to include("No matching review for cref:​[abc]")
      expect(File.read("test.err.html"))
        .not_to include("No matching review for cref:​[def]")
    end
  end

  it "validates document against Metanorma XML schema" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      = A
      X
      :docfile: test.adoc
      :docnumber: 21
      :no-pdf:

      == Clause

      [keep-with-next=mid-air]
      Para
    INPUT
    expect(File.read("test.err.html"))
      .to include('value of attribute "keep-with-next" is invalid; must be a boolean')
  end

  context "when xref_error.adoc compilation" do
    around do |example|
      FileUtils.rm_f "spec/assets/xref_error.err.html"
      example.run
      Dir["spec/assets/xref_error*"].each do |file|
        next if file.match?(/adoc$/)

        FileUtils.rm_f(file)
      end
    end

    it "generates error file" do
      expect do
        Metanorma::Compile.new
          .compile("spec/assets/xref_error.adoc",
                   type: "ietf", "agree-to-terms": true)
      end.to(change { File.exist?("spec/assets/xref_error.err.html") }
              .from(false).to(true))
    end
  end
end
