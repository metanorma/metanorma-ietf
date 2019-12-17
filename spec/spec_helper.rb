require "vcr"

VCR.configure do |config|
  config.cassette_library_dir = "spec/vcr_cassettes"
  config.hook_into :webmock
end

require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
end

require "bundler/setup"
require "asciidoctor"
require "metanorma-ietf"
# require "asciidoctor/standoc/converter"
require "rspec/matchers"
require "timecop"
require "equivalent-xml"
require "htmlentities"
require "rexml/document"

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

def htmlencode(x)
  HTMLEntities.new.encode(x, :hexadecimal).gsub(/&#x3e;/, ">").gsub(/&#xa;/, "\n").
    gsub(/&#x22;/, '"').gsub(/&#x3c;/, "<").gsub(/&#x26;/, '&').gsub(/&#x27;/, "'").
    gsub(/\\u(....)/) { |s| "&#x#{$1.downcase};" }
end

def strip_guid(x)
  x.gsub(%r{ id="_[^"]+"}, ' id="_"').gsub(%r{ target="_[^"]+"}, ' target="_"')
end

def xmlpp(x)
  s = ""
  f = REXML::Formatters::Pretty.new(2)
  f.compact = true
  f.write(REXML::Document.new(x),s)
  s
end

def dtd_absolute_path
  Metanorma::Ietf::RFC2629DTD_URL
end

ASCIIDOC_BLANK_HDR = <<~"HDR"
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib:

HDR

VALIDATING_BLANK_HDR = <<~"HDR"
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:

HDR

BLANK_HDR = <<~"HDR"
<?xml version='1.0' encoding='UTF-8'?>
       <ietf-standard xmlns="https://open.ribose.com/standards/ietf">
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
  <doctype>Internet-Draft</doctype>
</ext>
       </bibdata>
HDR

=begin
      <?xml version="1.0" encoding="US-ASCII"?>
      <?xml-stylesheet type="text/xsl" href="rfc2629.xslt"?>
      <!DOCTYPE rfc SYSTEM "#{dtd_absolute_path}">
=end

XML_HDR = <<~"HDR"
<rfc xmlns:xi='http://www.w3.org/2001/XInclude' version='3' prepTime='2000-01-01T05:00:00Z'>
  <front>
  <seriesInfo value='' name='RFC' asciiName='RFC'/>
    <abstract>
HDR

RFC_HDR = <<~"HDR"
       <rfc xmlns:xi='http://www.w3.org/2001/XInclude' version='3' prepTime='2000-01-01T05:00:00Z'>
         <front>
  <seriesInfo value='' name='RFC' asciiName='RFC'/>
</front>
HDR
