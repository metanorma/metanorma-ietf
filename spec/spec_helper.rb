require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
end

require "bundler/setup"
require "asciidoctor"
require "metanorma-ietf"
# require "metanorma/standoc/converter"
require "rspec/matchers"
require "timecop"
require "equivalent-xml"
require "htmlentities"
require "xml-c14n"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  # NOTE: we're working with timestamped documents. If we don't freeze time
  #   we'll have a bad time matching the headers.
  config.around(:example) do |example|
    # we won't use time=0, since we want to confirm meaningful time value
    Timecop.freeze Time.at(946702800).utc
    example.run
    Timecop.return
  end
end

OPTIONS = [backend: :ietf, header_footer: true].freeze

def htmlencode(xml)
  HTMLEntities.new.encode(xml, :hexadecimal).gsub(/&#x3e;/, ">").gsub(/&#xa;/, "\n")
    .gsub(/&#x22;/, '"').gsub(/&#x3c;/, "<").gsub(/&#x26;/, "&").gsub(/&#x27;/, "'")
    .gsub(/\\u(....)/) do |_s|
    "&#x#{$1.downcase};"
  end
end

def strip_guid(xml)
  xml.gsub(%r{ id="_[^"]+"}, ' id="_"')
    .gsub(%r{ from="_[^"]+"}, ' from="_"')
    .gsub(%r{ to="_[^"]+"}, ' to="_"')
    .gsub(%r{ target="_[^"]+"}, ' target="_"')
    .gsub(%r( anchor="_[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"), ' anchor="_"')
    .gsub(%r( bibitemid="_[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"), ' bibitemid="_"')
    .gsub(%r{<fetched>[^<]+</fetched>}, "<fetched/>")
    .gsub(%r{ schema-version="[^"]+"}, "")
end

def dtd_absolute_path
  Metanorma::Ietf::RFC2629DTD_URL
end

ASCIIDOC_BLANK_HDR = <<~"HDR".freeze
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :novalid:
  :no-isobib:
  :data-uri-image: false

HDR

VALIDATING_BLANK_HDR = <<~"HDR".freeze
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :data-uri-image: false

HDR

LOCAL_CACHED_ISOBIB_BLANK_HDR = <<~HDR.freeze
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :novalid:
  :local-cache: spec/relatondb

HDR

BLANK_HDR = <<~"HDR".freeze
  <?xml version='1.0' encoding='UTF-8'?>
         <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" version="#{Metanorma::Ietf::VERSION}" flavor="ietf">
         <bibdata type="standard">
          <title language="en" type="main" format="text/plain">Document title</title>
           <contributor>
             <role type="publisher"/>
             <organization>
             <name>Internet Engineering Task Force</name>
         <abbreviation>IETF</abbreviation>
             </organization>
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
           <ext>
    <doctype>internet-draft</doctype>
    <flavor>ietf</flavor>
    <ipr>trust200902</ipr>
    <pi>
    <tocinclude>yes</tocinclude>
  </pi>
  </ext>
         </bibdata>
                   <metanorma-extension>
            <presentation-metadata>
              <name>TOC Heading Levels</name>
              <value>2</value>
            </presentation-metadata>
            <presentation-metadata>
              <name>HTML TOC Heading Levels</name>
              <value>2</value>
            </presentation-metadata>
            <presentation-metadata>
              <name>DOC TOC Heading Levels</name>
              <value>2</value>
            </presentation-metadata>
            <presentation-metadata>
              <name>PDF TOC Heading Levels</name>
              <value>2</value>
            </presentation-metadata>
          </metanorma-extension>
HDR

XML_HDR = <<~"HDR".freeze
  <?xml version='1.0'?>
  <?rfc strict="yes"?>
  <?rfc compact="yes"?>
  <?rfc subcompact="no"?>
  <?rfc tocdepth="4"?>
  <?rfc symrefs="yes"?>
  <?rfc sortrefs="yes"?>
  <rfc xmlns:xi='http://www.w3.org/2001/XInclude' category='std' submissionType='IETF' version='3'>
    <front>
    <seriesInfo value='' name='RFC' asciiName='RFC'/>
      <abstract>
HDR

RFC_HDR = <<~"HDR".freeze
  <?xml version='1.0'?>
  <?rfc strict="yes"?>
  <?rfc compact="yes"?>
  <?rfc subcompact="no"?>
  <?rfc tocdepth="4"?>
  <?rfc symrefs="yes"?>
  <?rfc sortrefs="yes"?>
         <rfc xmlns:xi='http://www.w3.org/2001/XInclude' category='std' submissionType='IETF' version='3'>
           <front>
    <seriesInfo value='' name='RFC' asciiName='RFC'/>
  </front>
HDR

def mock_pdf
  allow(Mn2pdf).to receive(:convert) do |url, output, _c, _d|
    FileUtils.cp(url.gsub(/"/, ""), output.gsub(/"/, ""))
  end
end
