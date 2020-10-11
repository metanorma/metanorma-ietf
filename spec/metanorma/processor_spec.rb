require "spec_helper"
require "metanorma"

RSpec.describe Metanorma::Ietf::Processor do

  registry = Metanorma::Registry.instance
  registry.register(Metanorma::Ietf::Processor)
  processor = registry.find_processor(:ietf)

  it "registers against metanorma" do
    expect(processor).not_to be nil
  end

  it "registers output formats against metanorma" do
    expect(processor.output_formats.sort.to_s).to be_equivalent_to <<~"OUTPUT"
    [[:html, "html"], [:pdf, "pdf"], [:rfc, "rfc.xml"], [:rxl, "rxl"], [:txt, "txt"], [:xml, "xml"]]
    OUTPUT
  end

  it "registers version against metanorma" do
    expect(processor.version.to_s).to match(%r{^Metanorma::Ietf })
  end

  it "generates IsoDoc XML from a blank document" do
    expect(processor.input_to_isodoc(<<~"INPUT", nil)).to be_equivalent_to <<~"OUTPUT"
    #{ASCIIDOC_BLANK_HDR}
    INPUT
    #{BLANK_HDR}
<sections/>
</csd-standard>
    OUTPUT
  end

  it "generates HTML from IsoDoc XML" do
    FileUtils.rm_f "test.xml"
    FileUtils.rm_f "test.html"
    FileUtils.rm_f "test.rfc.xml"
    processor.output(<<~"INPUT", "test.xml", "test.html", :html)
           <ietf-standard xmlns="https://open.ribose.com/standards/ietf">
       <bibdata type="standard">
        <title language="en" type="main" format="text/plain">Document title</title>
        <docidentifier>1149</docidentifier>
<docnumber>1149</docnumber>
         <contributor>
           <role type="publisher"/>
           <organization>
           <name>Internet Engineering Task Force</name>
       <abbreviation>IETF</abbreviation>
           </organization>
         </contributor>
<contributor>
<role type="author"/>
<person>
<name>
<forename>David</forename>
  
<surname>Waitzman</surname>
</name>
<phone>(617) 873-4323</phone>
<email>dwaitzman@BBN.COM</email>
</person>
</contributor>
         <language>en</language>
         <script>Latn</script>
<status>
  <stage>published</stage>
</status>

         <copyright>
           <from>2000</from>
           <owner>
             <organization>
           <name>Internet Engineering Task Force</name>
       <abbreviation>IETF</abbreviation>
             </organization>
           </owner>
         </copyright>
         <series type="stream">
           <title>IETF</title>
         </series>
         <series type="intended">
         <title>std</title>
         </series>
         <ext>
  <doctype>rfc</doctype>
  <pi>
  <toc>yes</toc>
</pi>
  <ipr>*trust200902</ipr>
</ext>
       </bibdata>
              <sections>
  <terms id="A" obligation="normative">
  <title>Terms and definitions</title>
         <p>No terms and definitions are listed in this document.</p>
  <clause id="B" inline-header="false" obligation="normative">
  <title>Term1</title>
  <note id="C">
  <p id="D">This is a note</p>
</note>
</clause>
</terms>
</sections>
    INPUT
    expect(File.exist?("test.rfc.xml")).to be true
    expect(File.exist?("test.html")).to be true
    expect(File.read("test.html", encoding: "utf-8")).to include "No terms and definitions are listed in this document."
  end
end
