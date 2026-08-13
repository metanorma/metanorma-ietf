require "spec_helper"

# WS3 port of spec/isodoc/cleanup_spec.rb. Twelve of the fourteen old
# examples unit-tested the released converter's internal cleanup()
# post-pass on its private DEBUG intermediate vocabulary (fn/fnref
# pseudo-elements, nested figures, sourcecode carrying <t> children,
# asides inside <references>, back-matter <cref>s, raw non-ASCII
# before u-wrapping); the model-driven pipeline neither consumes nor
# produces that vocabulary — those normalisations happen at build
# time. Coverage map for the not-ported examples:
#
# - footnotes / footnotes in a section / table footnotes -> ported
#   footnotes_spec and table_spec (endnote form, first-use-sequential
#   shared numbering; cell footnotes adjudicated as document
#   endnotes in table_spec);
# - figures / inline figures -> blocks_spec figure/artwork coverage;
#   the unnesting and svg-file inlining are released-internal
#   restructurings of DEBUG output the pipeline never emits;
# - sourcecode cleanup -> transform_sourcecode normalise-at-source
#   (WS2 A-1) with its conservation-spec guard and blocks_spec
#   coverage;
# - annotated bibliography -> bibitem-borne notes render as
#   <annotation> (ref_spec); the aside-borne loose notes are
#   parse-ghosted on this vintage (ref_spec ledger);
# - definition lists -> lists_spec dl coverage; <bookmark> is
#   parse-ghosted (inline_spec ledger);
# - parsing errors on passthrough output -> <passthrough> is
#   parse-ghosted (inline_spec pendings); malformed output surfaces
#   through validate_spec's schema leg;
# - u tags -> Transformer.u_cleanup (N11) with conservation-spec
#   guards;
# - lists with single paragraphs -> the li single-t unwrap with
#   ordered-fragment replay (N7), covered in lists_spec/blocks_spec.
#
# The two full-conversion examples port below; expectations are
# regenerated against the pipeline (the old ones captured the
# released path's output).
RSpec.describe "IETF cleanup behaviours (WS3)" do
  it "cleans up abstracts" do
    # The abstract is standalone metadata: cross-references
    # flatten to text, preferring the presentation rendering
    # (semx fmt-xref — "ISO 712, Section 3.1") over local
    # citeas reconstruction; the example renders as an EXAMPLE
    # label t + content t; the note becomes a front <note>; the
    # table is dropped (abstract admits (dl|ol|t|ul)+ only).
    # GHOSTS (0.2.9 ledger): <em><strong>...</strong></em> —
    # EmRawElement drops the nested strong and its text, so the
    # empty em is suppressed; the <tt> inside display-texts is
    # dropped by the model, so its text is missing from the
    # flattened xref/eref renderings (the old path kept both).
    # <tt><link target="B"/></tt> IS recovered — via the semx
    # fmt-link that survives on TtElement.
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata>
      <title language="en" format="text/plain" type="main">The Holy Hand Grenade of Antioch</title>
      <docidentifier>draft-camelot-holy-grenade-01</docidentifier><docnumber>10</docnumber><contributor><role type="author"/><person>
      <name><completename>Arthur son of Uther Pendragon</completename></name></person></contributor>
      <ext><ipr>trust200902</ipr></ext>
      </bibdata>
      <preface><foreword id="X"><title>Abstract</title>
      <p>A. <em><strong>&lt;</strong></em> <tt><link target="B"/></tt> <xref target="http_1_1" format="title" relative="#abc"><display-text>Requirement <tt>/req/core/http</tt></display-text></xref> <eref type="inline" bibitemid="ISO712" citeas="ISO 712"><display-text>Requirement <tt>/req/core/http</tt></display-text></eref> <eref type="inline" bibitemid="ISO712" displayFormat="of" citeas="ISO 712" relative="xyz"><locality type="section"><referenceFrom>3.1</referenceFrom></locality></eref>
      </p>
      <note><p>Hello</p></note>
      <example><p>Hello</p></example>
      <table><tbody><tr><th>A</th></tr></tbody></table>
      </foreword>
      </preface>
      <bibliography><references id="_normative_references" obligation="informative"  normative="true"><title>Normative references</title>
      <bibitem id="ISO712" type="standard">
      <title format="text/plain">Cereals or cereal products</title>
      <title type="main" format="text/plain">Cereals and cereal products</title>
      <uri>http://www.example.com</uri>
      <docidentifier type="ISO">ISO 712</docidentifier>
      <contributor>
      <role type="publisher"/>
      <organization>
      <name>International Organization for Standardization</name>
      </organization>
      </contributor>
      </bibitem></references>
      </bibliography>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <?xml version="1.0" encoding="utf-8"?>
      <?rfc sortrefs="yes"?>
      <?rfc symrefs="yes"?>
      <?rfc tocdepth="4"?>
      <?rfc subcompact="no"?>
      <?rfc compact="yes"?>
      <?rfc strict="yes"?>
      <rfc category="std" ipr="trust200902" submissionType="IETF" docName="10" version="3" xml:lang="en">
        <front>
          <title>The Holy Hand Grenade of Antioch</title>
          <seriesInfo name="Internet-Draft" value="10" asciiName="Internet-Draft" status="Informational" stream="IETF"/>
          <author fullname="Arthur son of Uther Pendragon">
            <address/>
          </author>
          <date day="1" month="January" year="2000"/>
          <abstract anchor="X">
            <t>A.  <tt>B</tt> Requirement  Requirement  ISO 712, Section 3.1
      </t>
            <t keepWithNext="true">EXAMPLE</t>
            <t>Hello</t>
          </abstract>
          <note>
            <t>Hello</t>
          </note>
        </front>
        <middle/>
        <back>
          <references anchor="_normative_references">
            <name>Normative references</name>
            <reference anchor="ISO712">
              <front>
                <title>Cereals and cereal products</title>
                <author>
                  <organization ascii="International Organization for Standardization">International Organization for Standardization</organization>
                </author>
              </front>
              <refcontent>ISO 712</refcontent>
            </reference>
          </references>
        </back>
      </rfc>
    OUTPUT
    expect(strip_guid(feature_convert(input)))
      .to be_xml_equivalent_to strip_guid(output)
  end

  it "processes sourcecode with markup" do
    # inline elements in code text arrive twice from the
    # presentation layer (semantic original + semx rendering);
    # the originals are dropped and the rendered text kept, so
    # erefs carry their citation labels ("RFC 4918, Section
    # 14.24") and bare links their target URL. The double space
    # in the eref label is the presentation layer's join; the
    # old path's single space came from its own renderer.
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata>
      <title language="en" format="text/plain" type="main">The Holy Hand Grenade of Antioch</title>
      <docidentifier>draft-camelot-holy-grenade-01</docidentifier><docnumber>10</docnumber><contributor><role type="author"/><person>
      <name><completename>Arthur son of Uther Pendragon</completename></name></person></contributor>
      <ext><ipr>trust200902</ipr></ext>
      </bibdata>
      <sections>
      <clause id="F" obligation="informative">
      <title>Foreword</title>
      <sourcecode id="S" lang="ruby" filename="sourcecode1.rb" markers="true">
      <name>Caption</name>
      <body>
      puts "Hello, world." %w{a b c}.each do |x| puts x end
      <eref type="inline" bibitemid="RFC4918" citeas="RFC 4918"/>
      <eref type="inline" bibitemid="RFC4918" citeas="RFC 4918"><display-text>Hello</display-text></eref>
      <eref type="inline" bibitemid="RFC4918" citeas="RFC 4918"><localityStack><locality type="section"><referenceFrom>14.24</referenceFrom></locality></localityStack></eref>
      <eref type="inline" bibitemid="RFC4918" citeas="RFC 4918"><localityStack><locality type="section"><referenceFrom>14.24</referenceFrom></locality></localityStack><display-text>Hello</display-text></eref>
      <link target="http://www.example.com"/>
      <link target="http://www.example.com">example</link>
      <xref target="A"/>
      <xref target="A"><display-text>Goodbye</display-text></xref>
      </body>
      </sourcecode>
      </clause>
      </sections>
      <bibliography>
      <references id="A" normative="false" obligation="informative">
      <title>Bibliography</title>
      <bibitem id="RFC4918">
      <formattedref format="application/x-isodoc+xml">[NO INFORMATION AVAILABLE]</formattedref>
      <docidentifier>RFC 4918</docidentifier>
      <docnumber>4918</docnumber>
      </bibitem>
      </references>
      </bibliography>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <?xml version="1.0" encoding="utf-8"?>
      <?rfc sortrefs="yes"?>
      <?rfc symrefs="yes"?>
      <?rfc tocdepth="4"?>
      <?rfc subcompact="no"?>
      <?rfc compact="yes"?>
      <?rfc strict="yes"?>
      <rfc category="std" ipr="trust200902" submissionType="IETF" docName="10" version="3" xml:lang="en">
        <front>
          <title>The Holy Hand Grenade of Antioch</title>
          <seriesInfo name="Internet-Draft" value="10" asciiName="Internet-Draft" status="Informational" stream="IETF"/>
          <author fullname="Arthur son of Uther Pendragon">
            <address/>
          </author>
          <date day="1" month="January" year="2000"/>
        </front>
        <middle>
          <section anchor="F">
            <name>Foreword</name>
            <sourcecode anchor="S" name="sourcecode1.rb" type="ruby" markers="true">
      puts "Hello, world." %w{a b c}.each do |x| puts x end

        RFC 4918


        Hello


        RFC 4918,  Section 14.24


        Hello


        http://www.example.com


        example



          Bibliography



        Goodbye

      </sourcecode>
          </section>
        </middle>
        <back>
          <references anchor="A">
            <name>Bibliography</name>
            <reference anchor="RFC4918">
              <front>
                <title>[NO INFORMATION AVAILABLE]</title>
                <author surname="Unknown"/>
              </front>
            </reference>
          </references>
        </back>
      </rfc>
    OUTPUT
    expect(strip_guid(feature_convert(input)))
      .to be_xml_equivalent_to strip_guid(output)
  end

end
