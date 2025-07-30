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
    expect(strip_guid(Canon.format_xml(processor.input_to_isodoc(ASCIIDOC_BLANK_HDR, nil))))
      .to be_equivalent_to strip_guid(Canon.format_xml(<<~"OUTPUT"))
            #{BLANK_HDR}
        <sections/>
        </metanorma>
      OUTPUT
  end

  input = <<~INPUT
                 <metanorma xmlns="https://open.ribose.com/standards/ietf">
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
             <relation type="derivedFrom">
    <bibitem>
    <title id="_">--</title>
    <docidentifier>https://www.rfc-editor.org/rfc/rfc1149.txt</docidentifier>
    </bibitem>
    </relation>
             <series type="stream">
               <title id="_">IETF</title>
             </series>
             <series type="intended">
             <title id="_">std</title>
             </series>
             <ext>
      <doctype>rfc</doctype>
                 <flavor>ietf</flavor>
      <pi>
      <tocinclude>yes</tocinclude>
    </pi>
      <ipr>trust200902</ipr>
    </ext>
           </bibdata>
                  <sections>
      <terms id="A" obligation="normative">
      <title id="_">Terms and definitions</title>
             <p>No terms and definitions are listed in this document.</p>
      <clause id="B" inline-header="false" obligation="normative">
      <title id="_">Term1</title>
      <note id="C">
      <p id="D">This is a note</p>
    </note>
    </clause>
    </terms>
    </sections>
  INPUT

  it "does not find xml2rfc" do
    FileUtils.rm_f "test.xml"
    FileUtils.rm_f "test.html"
    FileUtils.rm_f "test.rfc.xml"
    allow_any_instance_of(Metanorma::Ietf::Processor)
      .to receive(:which).with("xml2rfc").and_return(nil)
    begin
      expect { processor.output(input, "test.xml", "test.html", :html) }
        .to raise_error(RuntimeError)
    rescue RuntimeError
    end
  end
end
