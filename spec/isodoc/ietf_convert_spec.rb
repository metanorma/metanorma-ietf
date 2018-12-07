# require "spec_helper"
# require "fileutils"
#
# RSpec.describe Asciidoctor::Ietf do
#   it "processes default metadata" do
#     csdc = IsoDoc::Ietf::HtmlConvert.new({})
#     docxml, filename, dir = csdc.convert_init(<<~"INPUT", "test", true)
# <csd-standard xmlns="https://www.calconnect.org/standards/csd">
# <bibdata type="standard">
#   <title language="en" format="plain">Main Title</title>
#   <docidentifier>CC/WD 1000:2001</docidentifier>
#   <contributor>
#     <role type="author"/>
#     <organization>
#       <name>IETF</name>
#     </organization>
#   </contributor>
#            <contributor>
#            <role type="editor"/>
#            <person>
#              <name>
#                <completename>Fred Flintstone</completename>
#              </name>
#            </person>
#          </contributor>
#          <contributor>
#            <role type="author"/>
#            <person>
#              <name>
#                <forename>Barney</forename>
#                <surname>Rubble</surname>
#              </name>
#            </person>
#          </contributor>
#   <contributor>
#     <role type="publisher"/>
#     <organization>
#       <name>IETF</name>
#     </organization>
#   </contributor>
#   <language>en</language>
#   <script>Latn</script>
#   <status format="plain">working-draft</status>
#   <copyright>
#     <from>2001</from>
#     <owner>
#       <organization>
#         <name>IETF</name>
#       </organization>
#     </owner>
#   </copyright>
#   <editorialgroup>
#     <technical-committee type="A">TC</technical-committee>
#   </editorialgroup>
# </bibdata><version>
#   <edition>2</edition>
#   <revision-date>2000-01-01</revision-date>
#   <draft>3.4</draft>
# </version>
# <sections/>
# </csd-standard>
#     INPUT
#     expect(htmlencode(Hash[csdc.info(docxml, nil).sort].to_s)).to be_equivalent_to <<~"OUTPUT"
#     {:accesseddate=>"XXX", :authors=>["Barney Rubble"], :confirmeddate=>"XXX", :createddate=>"XXX", :docnumber=>"CC/WD 1000:2001", :doctitle=>"Main Title", :doctype=>"Standard", :docyear=>"2001", :draft=>"3.4", :draftinfo=>" (draft 3.4, 2000-01-01)", :editorialgroup=>[], :editors=>["Fred Flintstone"], :ics=>"XXX", :implementeddate=>"XXX", :issueddate=>"XXX", :obsoleteddate=>"XXX", :obsoletes=>nil, :obsoletes_part=>nil, :publisheddate=>"XXX", :receiveddate=>"XXX", :revdate=>"2000-01-01", :sc=>"XXXX", :secretariat=>"XXXX", :status=>"Working Draft", :tc=>"TC", :unpublished=>false, :updateddate=>"XXX", :wg=>"XXXX"}
#     OUTPUT
#   end
#
#   it "processes pre" do
#     expect(IsoDoc::Ietf::HtmlConvert.new({}).convert("test", <<~"INPUT", true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>}, "</body>")).to be_equivalent_to <<~"OUTPUT"
# <csd-standard xmlns="https://www.calconnect.org/standards/csd">
# <preface><foreword>
# <pre>ABC</pre>
# </foreword></preface>
# </csd-standard>
#     INPUT
#     #{HTML_HDR}
#              <br/>
#              <div>
#                <h1 class="ForewordTitle">Foreword</h1>
#                <pre>ABC</pre>
#              </div>
#              <p class="zzSTDTitle1"/>
#            </div>
#          </body>
#     OUTPUT
#   end
#
#   it "processes keyword" do
#     expect(IsoDoc::Ietf::HtmlConvert.new({}).convert("test", <<~"INPUT", true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>}, "</body>")).to be_equivalent_to <<~"OUTPUT"
# <csd-standard xmlns="https://www.calconnect.org/standards/csd">
# <preface><foreword>
# <keyword>ABC</keyword>
# </foreword></preface>
# </csd-standard>
#     INPUT
#         #{HTML_HDR}
#              <br/>
#              <div>
#                <h1 class="ForewordTitle">Foreword</h1>
#                <span class="keyword">ABC</span>
#              </div>
#              <p class="zzSTDTitle1"/>
#            </div>
#          </body>
#     OUTPUT
#   end
#
#   it "processes simple terms & definitions" do
#     expect(IsoDoc::Ietf::HtmlConvert.new({}).convert("test", <<~"INPUT", true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>}, "</body>")).to be_equivalent_to <<~"OUTPUT"
#                <csd-standard xmlns="http://riboseinc.com/isoxml">
#        <sections>
#        <terms id="H" obligation="normative"><title>Terms, Definitions, Symbols and Abbreviated Terms</title>
#          <term id="J">
#          <preferred>Term2</preferred>
#        </term>
#         </terms>
#         </sections>
#         </csd-standard>
#     INPUT
#         #{HTML_HDR}
#                <p class="zzSTDTitle1"/>
#                <div id="H"><h1>1.&#160; Terms and definitions</h1><p>For the purposes of this document,
#            the following terms and definitions apply.</p>
#        <p class="TermNum" id="J">1.1</p>
#          <p class="Terms" style="text-align:left;">Term2</p>
#        </div>
#              </div>
#            </body>
#     OUTPUT
#   end
#
#   it "processes terms & definitions with external source" do
#     expect(IsoDoc::Ietf::HtmlConvert.new({}).convert("test", <<~"INPUT", true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>}, "</body>")).to be_equivalent_to <<~"OUTPUT"
#                <csd-standard xmlns="http://riboseinc.com/isoxml">
#          <termdocsource type="inline" bibitemid="ISO712"/>
#        <sections>
#        <terms id="H" obligation="normative"><title>Terms, Definitions, Symbols and Abbreviated Terms</title>
#          <term id="J">
#          <preferred>Term2</preferred>
#        </term>
#        </terms>
#         </sections>
#         <bibliography>
#         <references id="_normative_references" obligation="informative"><title>Normative References</title>
# <bibitem id="ISO712" type="standard">
#   <title format="text/plain">Cereals and cereal products?~@~I?~@~T?~@~IDetermination of moisture content?~@~I?~@~T?~@~IReference method</title>
#   <docidentifier>ISO 712</docidentifier>
#   <contributor>
#     <role type="publisher"/>
#     <organization>
#       <name>International Organization for Standardization</name>
#     </organization>
#   </contributor>
# </bibitem></references>
# </bibliography>
#         </csd-standard>
#     INPUT
#         #{HTML_HDR}
#                <p class="zzSTDTitle1"/>
#                <div>
#                  <h1>1.&#160; Normative references</h1>
#                  <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
#                  <p id="ISO712" class="NormRef">ISO 712, <i> Cereals and cereal products?~@~I?~@~T?~@~IDetermination of moisture content?~@~I?~@~T?~@~IReference method</i></p>
#                </div>
#                <div id="H"><h1>2.&#160; Terms and definitions</h1><p>For the purposes of this document, the terms and definitions
#          given in <a href="#ISO712">ISO 712</a> and the following apply.</p>
#        <p class="TermNum" id="J">2.1</p>
#                 <p class="Terms" style="text-align:left;">Term2</p>
#               </div>
#              </div>
#            </body>
#     OUTPUT
#   end
#
#   it "processes empty terms & definitions" do
#     expect(IsoDoc::Ietf::HtmlConvert.new({}).convert("test", <<~"INPUT", true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>}, "</body>")).to be_equivalent_to <<~"OUTPUT"
#                <csd-standard xmlns="http://riboseinc.com/isoxml">
#        <sections>
#        <terms id="H" obligation="normative"><title>Terms, Definitions, Symbols and Abbreviated Terms</title>
#        </terms>
#         </sections>
#         </csd-standard>
#     INPUT
#         #{HTML_HDR}
#                <p class="zzSTDTitle1"/>
#                <div id="H"><h1>1.&#160; Terms and definitions</h1><p>No terms and definitions are listed in this document.</p>
#        </div>
#              </div>
#            </body>
#     OUTPUT
#   end
#
#     it "rearranges term headers" do
#     expect(IsoDoc::Ietf::HtmlConvert.new({}).cleanup(Nokogiri::XML(<<~"INPUT")).to_s).to be_equivalent_to <<~"OUTPUT"
#     <html>
#            <body lang="EN-US" link="blue" vlink="#954F72" xml:lang="EN-US" class="container">
#              <div class="title-section">
#                <p>&#160;</p>
#              </div>
#              <br/>
#              <div class="WordSection2">
#                <p>&#160;</p>
#              </div>
#              <br/>
#              <div class="WordSection3">
#                <p class="zzSTDTitle1"/>
#                <div id="H"><h1>1.&#160; Terms and definitions</h1><p>For the purposes of this document,
#            the following terms and definitions apply.</p>
#        <p class="TermNum" id="J">1.1</p>
#          <p class="Terms" style="text-align:left;">Term2</p>
#        </div>
#              </div>
#            </body>
#            </html>
#            INPUT
#                  <?xml version="1.0"?>
#        <html>
#               <body lang="EN-US" link="blue" vlink="#954F72" xml:lang="EN-US" class="container">
#                 <div class="title-section">
#                   <p>&#xA0;</p>
#                 </div>
#                 <br/>
#                 <div class="WordSection2">
#                   <p>&#xA0;</p>
#                 </div>
#                 <br/>
#                 <div class="WordSection3">
#                   <p class="zzSTDTitle1"/>
#                   <div id="H"><h1>1.&#xA0; Terms and definitions</h1><p>For the purposes of this document,
#               the following terms and definitions apply.</p>
#           <p class="TermNum" id="J">1.1&#xA0;<p class="Terms" style="text-align:left;">Term2</p></p>
#
#           </div>
#                 </div>
#               </body>
#               </html>
#     OUTPUT
#   end
#
#
#   it "processes section names" do
#     expect(IsoDoc::Ietf::HtmlConvert.new({}).convert("test", <<~"INPUT", true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>}, "</body>")).to be_equivalent_to <<~"OUTPUT"
#                <csd-standard xmlns="http://riboseinc.com/isoxml">
#       <preface>
#       <foreword obligation="informative">
#          <title>Foreword</title>
#          <p id="A">This is a preamble</p>
#        </foreword>
#         <introduction id="B" obligation="informative"><title>Introduction</title><clause id="C" inline-header="false" obligation="informative">
#          <title>Introduction Subsection</title>
#        </clause>
#        </introduction></preface><sections>
#        <clause id="D" obligation="normative">
#          <title>Scope</title>
#          <p id="E">Text</p>
#        </clause>
#
#        <clause id="H" obligation="normative"><title>Terms, Definitions, Symbols and Abbreviated Terms</title><terms id="I" obligation="normative">
#          <title>Normal Terms</title>
#          <term id="J">
#          <preferred>Term2</preferred>
#        </term>
#        </terms>
#        <definitions id="K">
#          <dl>
#          <dt>Symbol</dt>
#          <dd>Definition</dd>
#          </dl>
#        </definitions>
#        </clause>
#        <definitions id="L">
#          <dl>
#          <dt>Symbol</dt>
#          <dd>Definition</dd>
#          </dl>
#        </definitions>
#        <clause id="M" inline-header="false" obligation="normative"><title>Clause 4</title><clause id="N" inline-header="false" obligation="normative">
#          <title>Introduction</title>
#        </clause>
#        <clause id="O" inline-header="false" obligation="normative">
#          <title>Clause 4.2</title>
#        </clause></clause>
#
#        </sections><annex id="P" inline-header="false" obligation="normative">
#          <title>Annex</title>
#          <clause id="Q" inline-header="false" obligation="normative">
#          <title>Annex A.1</title>
#          <clause id="Q1" inline-header="false" obligation="normative">
#          <title>Annex A.1a</title>
#          </clause>
#        </clause>
#        </annex><bibliography><references id="R" obligation="informative">
#          <title>Normative References</title>
#        </references><clause id="S" obligation="informative">
#          <title>Bibliography</title>
#          <references id="T" obligation="informative">
#          <title>Bibliography Subsection</title>
#        </references>
#        </clause>
#        </bibliography>
#        </csd-standard>
#     INPUT
#         #{HTML_HDR}
#              <br/>
#              <div>
#                  <h1 class="ForewordTitle">Foreword</h1>
#                  <p id="A">This is a preamble</p>
#                </div>
#                <br/>
#                <div class="Section3" id="B">
#                  <h1 class="IntroTitle">Introduction</h1>
#                  <div id="C">
#           <h2>Introduction Subsection</h2>
#         </div>
#                </div>
#                <p class="zzSTDTitle1"/>
#                <div id="D">
#                  <h1>1.&#160; Scope</h1>
#                  <p id="E">Text</p>
#                </div>
#                <div>
#                  <h1>2.&#160; Normative references</h1>
#                  <p>There are no normative references in this document.</p>
#                </div>
#                <div id="H"><h1>3.&#160; Terms, definitions, symbols and abbreviated terms</h1><p>For the purposes of this document,
#            the following terms and definitions apply.</p>
#        <div id="I">
#           <h2>3.1. Normal Terms</h2>
#           <p class="TermNum" id="J">3.1.1</p>
#           <p class="Terms" style="text-align:left;">Term2</p>
#
#         </div><div id="K"><h2>3.2. Symbols and abbreviated terms</h2>
#           <dl><dt><p>Symbol</p></dt><dd>Definition</dd></dl>
#         </div></div>
#                <div id="L" class="Symbols">
#                  <h1>4.&#160; Symbols and abbreviated terms</h1>
#                  <dl>
#                    <dt>
#                      <p>Symbol</p>
#                    </dt>
#                    <dd>Definition</dd>
#                  </dl>
#                </div>
#                <div id="M">
#                  <h1>5.&#160; Clause 4</h1>
#                  <div id="N">
#           <h2>5.1. Introduction</h2>
#         </div>
#                  <div id="O">
#           <h2>5.2. Clause 4.2</h2>
#         </div>
#                </div>
#                <br/>
#                <div id="P" class="Section3">
#                  <h1 class="Annex"><b>Appendix A</b><br/>(normative) <br/><b>Annex</b></h1>
#                  <div id="Q">
#           <h2>A.1. Annex A.1</h2>
#           <div id="Q1">
#           <h3>A.1.1. Annex A.1a</h3>
#           </div>
#         </div>
#                </div>
#                <br/>
#                <div>
#                  <h1 class="Section3">Bibliography</h1>
#                  <div>
#                    <h2 class="Section3">Bibliography Subsection</h2>
#                  </div>
#                </div>
#              </div>
#            </body>
#     OUTPUT
#   end
#
#   it "injects JS into blank html" do
#     FileUtils.rm_f "test.html"
#     expect(Asciidoctor.convert(<<~"INPUT", backend: :csd, header_footer: true)).to be_equivalent_to <<~"OUTPUT"
#       = Document title
#       Author
#       :docfile: test.adoc
#       :novalid:
#     INPUT
#     #{BLANK_HDR}
# <sections/>
# </csd-standard>
#     OUTPUT
#     html = File.read("test.html", encoding: "utf-8")
#     expect(html).to match(%r{jquery\.min\.js})
#     expect(html).to match(%r{Overpass})
#     expect(html).to match(%r{<main class="main-section"><button})
#   end
#
#
# end
