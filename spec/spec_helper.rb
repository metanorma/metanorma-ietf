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

def dtd_absolute_path
  File.join(File.expand_path('..', File.dirname(__FILE__)), "rfc2629.dtd")
end

ASCIIDOC_BLANK_HDR = <<~"HDR"
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:

HDR

VALIDATING_BLANK_HDR = <<~"HDR"
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:

HDR

BLANK_HDR = <<~"HDR"
       <?xml version="1.0" encoding="UTF-8"?>
       <csd-standard xmlns="https://www.calconnect.org/standards/csd">
       <bibdata type="standard">

         <docidentifier type="csd">CC ???</docidentifier>
         <contributor>
           <role type="author"/>
           <organization>
             <name>IETF</name>
           </organization>
         </contributor>
         <contributor>
           <role type="publisher"/>
           <organization>
             <name>IETF</name>
           </organization>
         </contributor>

         <language>en</language>
         <script>Latn</script>

         <copyright>
           <from>#{Time.new.year}</from>
           <owner>
             <organization>
               <name>IETF</name>
             </organization>
           </owner>
         </copyright>
         <editorialgroup>
           <technical-committee/>
         </editorialgroup>
       </bibdata>
HDR

HTML_HDR = <<~"HDR"
         <body lang="EN-US" link="blue" vlink="#954F72" xml:lang="EN-US" class="container">
           <div class="title-section">
             <p>&#160;</p>
           </div>
           <br/>
           <div class="prefatory-section">
             <p>&#160;</p>
           </div>
           <br/>
           <div class="main-section">
HDR

XML_HDR = <<~"HDR"
      <?xml version="1.0" encoding="US-ASCII"?>
      <?xml-stylesheet type="text/xsl" href="rfc2629.xslt"?>
      <!DOCTYPE rfc SYSTEM "#{dtd_absolute_path}">
      <?rfc strict="yes"?>
      <?rfc compact="yes"?>
      <?rfc subcompact="no"?>
      <?rfc toc="yes"?>
      <?rfc tocdepth="4"?>
      <?rfc symrefs="yes"?>
      <?rfc sortrefs="yes"?>
HDR
