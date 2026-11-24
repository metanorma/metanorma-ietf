require "spec_helper"
require "metanorma-core"

RSpec.describe Metanorma::Ietf::Processor do
  registry = Metanorma::Registry.instance
  registry.register(Metanorma::Ietf::Processor)
  processor = registry.find_processor(:ietf)

  it "registers against metanorma" do
    expect(processor).not_to be nil
  end

  it "registers output formats against metanorma" do
    output = <<~OUTPUT
      [[:html, "html"], [:pdf, "pdf"], [:rfc, "rfc.xml"], [:rxl, "rxl"], [:txt, "txt"], [:xml, "xml"]]
    OUTPUT
    expect(processor.output_formats.sort.to_s).to eq output.strip
  end

  it "registers version against metanorma" do
    expect(processor.version.to_s).to match(%r{^Metanorma::Ietf })
  end

  it "generates IsoDoc XML from a blank document" do
    output = <<~OUTPUT
            #{BLANK_HDR_AUTHOR}
      <sections/>
      </metanorma>
    OUTPUT
    expect(strip_guid(processor.input_to_isodoc(ASCIIDOC_BLANK_HDR, nil)))
      .to be_xml_equivalent_to strip_guid(output.strip)
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

  it "renders the :rfc leg through the presentation stage" do
    semantic = File.read("spec/fixtures/transformer/input/example.xml")
    FileUtils.rm_f "test.rfc.xml"
    processor.output(semantic, "test.xml", "test.rfc.xml", :rfc)
    expect(File.exist?("test.rfc.xml")).to be true
    # the full stem text proves embedded MathML survived the narrow
    # namespace strip (N13); the "(1)" proves the presentation stage
    # ran (formula autonumber)
    expect(File.read("test.rfc.xml"))
      .to include("$$ y^(2) = x^(3) + a x + b $$    (1)")
  end

  it "quarantines invalid RFC XML to .err and halts (#302)" do
    semantic = <<~INPUT
      #{BLANK_HDR_AUTHOR}
      <sections><clause id="c1"><title>Body</title>
      <p id="p1">See <xref target="nonexistent-anchor"/>.</p>
      </clause></sections>
      </metanorma>
    INPUT
    FileUtils.rm_f ["quarantine.rfc.xml", "quarantine.rfc.xml.err"]
    expect do
      processor.output(semantic, "quarantine.xml", "quarantine.rfc.xml",
                       :rfc)
    end.to output(/Cannot continue processing/).to_stderr
    expect(File.exist?("quarantine.rfc.xml")).to be false
    expect(File.exist?("quarantine.rfc.xml.err")).to be true
    FileUtils.rm_f "quarantine.rfc.xml.err"
  end

  it "escapes bare ampersands on the processor leg (#302)" do
    semantic = <<~INPUT
      #{BLANK_HDR_AUTHOR}
      <preface><abstract id="ab1"><p>Abstract.</p></abstract></preface>
      <sections><clause id="c1"><title>Body</title>
      <p id="p1">Pilcrow entity &amp;para; end.</p>
      </clause></sections>
      </metanorma>
    INPUT
    FileUtils.rm_f "escape.rfc.xml"
    processor.output(semantic, "escape.xml", "escape.rfc.xml", :rfc)
    expect(File.exist?("escape.rfc.xml")).to be true
    out = File.read("escape.rfc.xml")
    expect(out).to include("&amp;para;")
    expect { Nokogiri::XML(out) { |c| c.strict } }.not_to raise_error
    FileUtils.rm_f "escape.rfc.xml"
  end

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

RSpec.describe Metanorma::Ietf::Processor, "preptool warnings" do
  before do
    @processor = Metanorma::Ietf::Processor.new
  end

  it "records xml2rfc warnings in the log" do
    v = Metanorma::Ietf::RfcValidate.new
    @processor.instance_variable_set(:@rfc_validator, v)
    @processor.record_preptool_warnings(
      "probe.rfc.xml(20): Warning: Duplicate xsd:ID attribute anchor=\"dup\" found.\n" \
      "  WARNING:  legacy uppercase form\n", "probe.rfc.xml",
    )
    expect(v.entries?).to be true
    report = v.write("preptool.rfc.xml")
    text = File.read(report).gsub(/<[^>]+>/, " ")
    expect(text).to include("xml2rfc preptool warning: Duplicate")
      .and include("xml2rfc preptool warning: legacy uppercase form")
    FileUtils.rm_f(report)
  end

  # the txt lane wires the validator through the xml2rfc run; a clean
  # document renders without raising through the capture path
  it "renders the txt lane with the validator wired", :if => system("sh", "-c", "command -v xml2rfc >/dev/null") do
    sem = <<~INPUT
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic">
      <bibdata type="standard">
      <title language="en" type="main">T</title>
      <contributor><role type="author"/><person>
      <name><forename>A</forename><initial>A.</initial><surname>U</surname></name>
      </person></contributor>
      <language>en</language><script>Latn</script>
      <series type="stream"><title>independent</title></series>
      <date type="published"><on>2026-11-24</on></date>
      <copyright><from>2026</from><owner>
      <organization><name>Internet Engineering Task Force</name></organization>
      </owner></copyright>
      <ext><doctype>internet-draft</doctype></ext>
      </bibdata>
      <preface><abstract id="ab1"><p>Abstract.</p></abstract></preface>
      <sections>
      <clause id="c1"><title>Body</title>
      <p id="p1">Text.</p>
      </clause>
      </sections>
      </metanorma>
    INPUT
    FileUtils.rm_f ["pt.rfc.xml", "pt.rfc.xml.err", "pt.rfc.err.html", "pt.txt"]
    @processor.output(sem, "pt.xml", "pt.txt", :txt)
    expect(File.exist?("pt.txt")).to be true
    FileUtils.rm_f ["pt.rfc.xml", "pt.rfc.xml.err", "pt.rfc.err.html", "pt.txt"]
  end
end
