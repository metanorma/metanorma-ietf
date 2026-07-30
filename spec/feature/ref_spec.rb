require "spec_helper"

# WS3 port of spec/isodoc/ref_spec.rb. Expectations are regenerated
# against the model-driven pipeline (the old ones captured the
# released path's DEBUG pre-cleanup output). Fixture corruption in
# the old inputs is repaired where it was accidental rather than
# under test: a mismatched </ompletename> closing tag (x3), an
# unterminated </title before <uri> in RFC2397, a stray <title>
# directly inside <references> outside any bibitem, and a stray ">"
# before a keyword vocab. The old inputs' <introduction> is ADAPTED
# to <clause>: <introduction> inside <sections> is parse-ghosted at
# the Sections level in metanorma-document 0.2.9 (present in
# element_order, no accessor — qa-plan ledger; re-test on 0.4.x),
# and the old path rendered it as a plain middle section anyway.
# See per-example comments for adjudications.
RSpec.describe "IETF references rendering (WS3)" do
  it "processes IsoXML bibliographies" do
    # Deviations from the old expectation, adjudicated (see file
    # header + qa-plan): the two loose <note>s after ISSN are
    # parse-ghosted (0.2.9 ledger) so ISSN loses its annotations;
    # <formatted-initials> is unmapped (FullName reads <initial>
    # only — 0.2.9 ledger) so Citizen/Third lose initials; the
    # ISO16634 bibitem-borne note renders as an annotation (the
    # released path dropped it); the I-D seriesInfo carries the
    # full draft name (the released path stripped it to
    # "aboba-context-802", which xml2rfc cannot resolve);
    # untyped/RDF/xml URIs are not targets (released parity);
    # IETF docids ride seriesInfo + anchor, never refcontent
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata>
      <title language="en" format="text/plain" type="main">The Holy Hand Grenade of Antioch</title>
      <docidentifier>draft-camelot-holy-grenade-01</docidentifier><docnumber>10</docnumber><contributor><role type="author"/><person>
      <name><completename>Arthur son of Uther Pendragon</completename></name></person></contributor>
      <ext><ipr>trust200902</ipr></ext>
      </bibdata>
      <sections><clause id="B"><title>Introduction</title>
      <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">
      <eref bibitemid="ISO712"/>
      <eref bibitemid="ISBN"/>
      <eref bibitemid="ISSN"/>
      <eref bibitemid="ISO16634"/>
      <eref bibitemid="ref11"/>
      </p>
      </clause>
      <clause id="A"><title>A-title</title><p>A</p></clause></sections>
      <bibliography><references id="_normative_references" obligation="informative"  normative="true"><title>Normative References</title>
      <bibitem id="RFC2119" type="standard" schema-version="v1.2.4">  <fetched>2023-11-06</fetched>
      <title type="main" format="text/plain">Key words for use in RFCs to Indicate Requirement Levels</title>
        <uri type="src">https://www.rfc-editor.org/info/rfc2119</uri>  <docidentifier type="IETF" primary="true">RFC 2119</docidentifier>  <docidentifier type="DOI">10.17487/RFC2119</docidentifier>  <docnumber>RFC2119</docnumber>  <date type="published">    <on>1997-03</on>  </date>  <contributor>    <role type="author"/>    <person>
      <name>        <completename language="en" script="Latn">S. Bradner</completename>      </name>
          </person>  </contributor>  <contributor>    <role type="publisher"/>    <organization>
      <name>RFC Publisher</name>
          </organization>  </contributor>  <contributor>    <role type="authorizer"/>    <organization>
      <name>RFC Series</name>
          </organization>  </contributor>  <language>en</language>  <script>Latn</script>  <abstract format="text/html" language="en" script="Latn">    <p id="_349eae68-a8a3-0c01-e665-a6dc84c36d2e">In many standards track documents several words are used to signify the requirements in the specification. These words are often capitalized. This document defines these words as they should be interpreted in IETF documents. This document specifies an Internet Best Current Practices for the Internet Community, and requests discussion and suggestions for improvements.</p>
        </abstract>  <series>
      <title format="text/plain">BCP</title>
          <number>14</number>  </series>  <series>
      <title format="text/plain">RFC</title>
          <number>2119</number>  </series>  <series type="stream">
      <title format="text/plain">IETF</title>
        </series>  <keyword><vocab>Standards</vocab></keyword>  <keyword><vocab>Track</vocab></keyword>  <keyword><vocab>Documents</vocab></keyword></bibitem>
        <bibitem anchor="RFC2397"  id="1" type="standard" schema-version="v1.2.4">
        <title type="main" format="text/plain">The "data" URL scheme</title>
      <uri type="src">https://www.rfc-editor.org/info/rfc2397</uri>
      <docidentifier type="IETF" primary="true">RFC 2397</docidentifier>
      <docidentifier type="DOI">10.17487/RFC2397</docidentifier>
      <docnumber>RFC2397</docnumber>
      <date type="published">
      <on>1998-08</on>
      </date>
      <contributor>
      <role type="author"/>
      <person>
      <name>
      <completename language="en" script="Latn">L. Masinter</completename>
      </name>
      </person>
      </contributor>
      <contributor>
      <role type="publisher"/>
      <organization>
      <name>RFC Publisher</name>
      </organization>
      </contributor>
      <contributor>
      <role type="authorizer"/>
      <organization>
      <name>RFC Series</name>
      </organization>
      </contributor>
      <language>en</language>
      <script>Latn</script>
      <abstract format="text/html" language="en" script="Latn">
      <p>A new URL scheme, "data", is defined. It allows inclusion of small data items as "immediate" data, as if it had been included externally. [STANDARDS-TRACK]</p>
      </abstract>
      <series>
      <title format="text/plain">RFC</title>
      <number>2397</number>
      </series>
      <series type="stream">
      <title format="text/plain">Legacy</title>
      </series>
      <keyword><vocab>DATA-URL</vocab></keyword>
      <keyword><vocab>uniform resource locator</vocab></keyword>
      <keyword><vocab>identifiers</vocab></keyword>
      <keyword><vocab>media type</vocab></keyword>
      <ext schema-version="v1.0.1">
      <stream>Legacy</stream>
      </ext>
      </bibitem>
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
      </bibitem>
      <bibitem id="ISO16634" type="standard">
      <title language="x" format="text/plain">Cereals, pulses, milled cereal products, xxxx, oilseeds and animal feeding stuffs</title>
      <title language="en" format="text/plain">Cereals, pulses, milled cereal products, oilseeds and animal feeding stuffs</title>
      <uri>http://www.example.com</uri>
      <uri type="RDF">http://www.example.com/rdf</uri>
      <docidentifier type="ISO">ISO 16634:-- (all parts)</docidentifier>
      <docidentifier type="DOI">1234</docidentifier>
      <date type="published"><on>--</on></date>
      <contributor>
      <role type="publisher"/>
      <organization>
      <abbreviation>ISO</abbreviation>
      </organization>
      </contributor>
      <contributor>
      <role type="editor"/>
      <organization>
      <name>International Supporters of Odium</name>
      <abbreviation>ISO1</abbreviation>
      </organization>
      </contributor>
      <keyword><vocab>keyword1</vocab></keyword>
      <keyword><vocab>keyword2</vocab></keyword>
      <abstract><p>This is an abstract</p></abstract>
      <note format="text/plain" reference="1">ISO DATE: Under preparation. (Stage at the time of publication ISO/DIS 16634)</note>
      <extent type="part">
      <referenceFrom>all</referenceFrom>
      </extent>
      </bibitem>
      <bibitem id="ISO20483" type="standard">
      <title format="text/plain">Cereals and pulses</title>
      <docidentifier type="ISO">ISO 20483:2013-2014</docidentifier>
      <date type="published"><from>2013</from><to>2014</to></date>
      <contributor>
      <role type="publisher"/>
      <organization>
      <name>International Organization for Standardization</name>
      </organization>
      </contributor>
      <contributor>
      <role type="author"/>
      <person>
      <name><completename>Ölaf Nürk</completename>
      <surname>Nürk</surname>
      <forename>Ölaf</forename>
      </name>
      </person>
      </contributor>
      <contributor>
      <role type="editor"/>
      <person>
      <name>
      <surname>Citizen</surname>
      <formatted-initials>A. B.</formatted-initials>
      </name>
      </person>
      </contributor>
      <abstract>This is an abstract</abstract>
      </bibitem>
      <bibitem id="ISO20484" type="standard">
      <title format="text/plain">Cereals and pulses II</title>
      <docidentifier type="ISO">ISO 20484:2013-2014</docidentifier>
      <date type="published"><from>2013</from><to>2014</to></date>
      <contributor>
      <role type="publisher"/>
      <organization>
      <name>International Organization for Standardization</name>
      </organization>
      </contributor>
      <contributor>
      <role type="author"/>
      <person>
      <name><completename>Ölaf Nürk</completename>
      <surname>Nürk</surname>
      <forename>Ölaf</forename>
      </name>
      </person>
      </contributor>
      <contributor>
      <role type="author"/>
      <person>
      <name>
      <surname>Citizen</surname>
      <formatted-initials>A. B.</formatted-initials>
      </name>
      </person>
      </contributor>
      <contributor>
      <role type="editor"/>
      <person>
      <name>
      <surname>Third</surname>
      <formatted-initials>Th.</formatted-initials>
      </name>
      </person>
      </contributor>
      <abstract>This is an abstract</abstract>
      </bibitem>
      <bibitem id="grail_film">
      <formattedref format="application/x-isodoc+xml">G. Chapman, J. Cleese, E. Idle, T. Gilliam, T. Jones, M. Palin. 1975. <em>Monty Python and the Holy Grail</em>.  &lt;<link target="https://www.w3.org/TR/2008/REC-xml-20081126/"/>&gt;.</formattedref>
      <docidentifier>Grail</docidentifier>
      </bibitem>
      </references><references id="_bibliography" obligation="informative" normative="false">
      <title>Bibliography</title>
      <bibitem id="ISBN" type="book">
      <title format="text/plain">Chemicals for analytical laboratory use</title>
      <docidentifier type="ISBN">ISBN</docidentifier>
      <docidentifier type="metanorma">[1]</docidentifier>
      <contributor>
      <role type="publisher"/>
      <organization>
      <name>International SBN</name>
      <abbreviation>ISBN</abbreviation>
      </organization>
      </contributor>
      </bibitem>
      <bibitem id="ISSN" type="journal">
      <title format="text/plain">Instruments for analytical laboratory use</title>
      <docidentifier type="ISSN">ISSN</docidentifier>
      <docidentifier type="metanorma">[2]</docidentifier>
      <contributor>
      <role type="publisher"/>
      <organization>
      <name>International SSN</name>
      <abbreviation>ISSN</abbreviation>
      </organization>
      </contributor>
      </bibitem>
      <note><p>This is an annotation of document ISSN.</p></note>
      <note><p>This is another annotation of document ISSN.</p></note>
      <bibitem id="ISO3696" type="standard">
      <title format="text/plain">Water for analytical laboratory use</title>
      <docidentifier type="ISO">ISO 3696</docidentifier>
      <contributor>
      <role type="publisher"/>
      <organization>
      <name>International Standards Organization</name>
      <abbreviation>ISO</abbreviation>
      </organization>
      </contributor>
      </bibitem>
      <bibitem id="ref11">
      <title>Internet Calendaring and Scheduling Core Object Specification (iCalendar)</title>
      <docidentifier type="IETF">RFC 10</docidentifier>
      <contributor>
      <role type="publisher"/>
      <organization>
      <name>Internet Engineering Task Force</name>
      <abbreviation>IETF</abbreviation>
      </organization>
      </contributor>
      <uri type="xml">https://xml2rfc.tools.ietf.org/10.xml</uri>
      </bibitem>
      <bibitem id="I-D.aboba-context-802" type="standard">  <fetched>2021-09-19</fetched>  <title format="text/plain" language="en" script="Latn">A Model for Context Transfer in IEEE 802</title>  <uri type="xml">https://raw.githubusercontent.com/relaton/relaton-data-ietf/master/data/reference.I-D.aboba-context-802.xml</uri>  <uri type="TXT">http://www.ietf.org/internet-drafts/draft-aboba-context-802-00.txt</uri>  <docidentifier type="IETF">I-D.aboba-context-802</docidentifier>  <docidentifier type="rfc-anchor">I-D.aboba-context-802</docidentifier>  <docidentifier type="Internet-Draft">draft-aboba-context-802-00</docidentifier>  <date type="published">    <on>2003-10</on>  </date>  <contributor>    <role type="author"/>    <person>      <name>        <completename language="en">Bernard Aboba</completename>      </name>      <affiliation>        <organization>          <name>Internet Engineering Task Force</name>          <abbreviation>IETF</abbreviation>        </organization>      </affiliation>    </person>  </contributor>  <contributor>    <role type="publisher"/>    <organization>      <name>Internet Engineering Task Force</name>      <abbreviation>IETF</abbreviation>    </organization>  </contributor>  <language>en</language>  <script>Latn</script>  <series type="main">    <title format="text/plain" language="en" script="Latn">Internet-Draft</title>    <number>draft-aboba-context-802-00</number>  </series>  <place>Fremont, CA</place></bibitem>
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
          <section anchor="B">
            <name>Introduction</name>
            <t anchor="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">
      <xref target="ISO712"/>
      <xref target="ISBN"/>
      <xref target="ISSN"/>
      <xref target="ISO16634"/>
      <xref target="ref11"/>
      </t>
          </section>
          <section anchor="A">
            <name>A-title</name>
            <t>A</t>
          </section>
        </middle>
        <back>
          <references anchor="_normative_references">
            <name>Normative References</name>
            <reference anchor="RFC2119" target="https://www.rfc-editor.org/info/rfc2119">
              <stream>IETF</stream>
              <front>
                <title>Key words for use in RFCs to Indicate Requirement Levels</title>
                <author fullname="S. Bradner"/>
                <date month="March" year="1997"/>
                <keyword>Standards</keyword>
                <keyword>Track</keyword>
                <keyword>Documents</keyword>
                <abstract>
                  <t>In many standards track documents several words are used to signify the requirements in the specification. These words are often capitalized. This document defines these words as they should be interpreted in IETF documents. This document specifies an Internet Best Current Practices for the Internet Community, and requests discussion and suggestions for improvements.</t>
                </abstract>
              </front>
              <seriesInfo name="DOI" value="10.17487/RFC2119"/>
              <seriesInfo name="BCP" value="14"/>
              <seriesInfo name="RFC" value="2119"/>
            </reference>
            <reference anchor="RFC2397" target="https://www.rfc-editor.org/info/rfc2397">
              <front>
                <title>The "data" URL scheme</title>
                <author fullname="L. Masinter"/>
                <date month="August" year="1998"/>
                <keyword>DATA-URL</keyword>
                <keyword>uniform resource locator</keyword>
                <keyword>identifiers</keyword>
                <keyword>media type</keyword>
                <abstract>
                  <t>A new URL scheme, "data", is defined. It allows inclusion of small data items as "immediate" data, as if it had been included externally. [STANDARDS-TRACK]</t>
                </abstract>
              </front>
              <seriesInfo name="DOI" value="10.17487/RFC2397"/>
              <seriesInfo name="RFC" value="2397"/>
            </reference>
            <reference anchor="ISO712">
              <front>
                <title>Cereals and cereal products</title>
                <author>
                  <organization>International Organization for Standardization</organization>
                </author>
              </front>
              <refcontent>ISO 712</refcontent>
            </reference>
            <reference anchor="ISO16634">
              <front>
                <title>Cereals, pulses, milled cereal products, xxxx, oilseeds and animal feeding stuffs</title>
                <author>
                  <organization abbrev="ISO1">International Supporters of Odium</organization>
                </author>
                <keyword>keyword1</keyword>
                <keyword>keyword2</keyword>
                <abstract>
                  <t>This is an abstract</t>
                </abstract>
              </front>
              <annotation>ISO DATE: Under preparation. (Stage at the time of publication ISO/DIS 16634)</annotation>
              <refcontent>ISO 16634:-- (all parts)</refcontent>
              <seriesInfo name="DOI" value="1234"/>
            </reference>
            <reference anchor="ISO20483">
              <front>
                <title>Cereals and pulses</title>
                <author initials="Ö." surname="Nürk" asciiSurname="Nurk" fullname="Ölaf Nürk" asciiFullname="Olaf Nurk"/>
                <author surname="Citizen"/>
                <date year="2013"/>
                <abstract>
                  <t>This is an abstract</t>
                </abstract>
              </front>
              <refcontent>ISO 20483:2013-2014</refcontent>
            </reference>
            <reference anchor="ISO20484">
              <front>
                <title>Cereals and pulses II</title>
                <author initials="Ö." surname="Nürk" asciiSurname="Nurk" fullname="Ölaf Nürk" asciiFullname="Olaf Nurk"/>
                <author surname="Citizen"/>
                <author surname="Third"/>
                <date year="2013"/>
                <abstract>
                  <t>This is an abstract</t>
                </abstract>
              </front>
              <refcontent>ISO 20484:2013-2014</refcontent>
            </reference>
            <reference anchor="grail_film">
              <front>
                <title>G. Chapman, J. Cleese, E. Idle, T. Gilliam, T. Jones, M. Palin. 1975. Monty Python and the Holy Grail.  &lt;https://www.w3.org/TR/2008/REC-xml-20081126/&gt;.</title>
                <author surname="Unknown"/>
              </front>
            </reference>
          </references>
          <references anchor="_bibliography">
            <name>Bibliography</name>
            <reference anchor="ISBN">
              <front>
                <title>Chemicals for analytical laboratory use</title>
                <author>
                  <organization abbrev="ISBN">International SBN</organization>
                </author>
              </front>
            </reference>
            <reference anchor="ISSN">
              <front>
                <title>Instruments for analytical laboratory use</title>
                <author>
                  <organization abbrev="ISSN">International SSN</organization>
                </author>
              </front>
            </reference>
            <reference anchor="ISO3696">
              <front>
                <title>Water for analytical laboratory use</title>
                <author>
                  <organization abbrev="ISO">International Standards Organization</organization>
                </author>
              </front>
              <refcontent>ISO 3696</refcontent>
            </reference>
            <reference anchor="ref11">
              <front>
                <title>Internet Calendaring and Scheduling Core Object Specification (iCalendar)</title>
                <author>
                  <organization abbrev="IETF">Internet Engineering Task Force</organization>
                </author>
              </front>
              <seriesInfo name="RFC" value="10"/>
            </reference>
            <reference anchor="I-D.aboba-context-802">
              <front>
                <title>A Model for Context Transfer in IEEE 802</title>
                <author fullname="Bernard Aboba"/>
                <date month="October" year="2003"/>
              </front>
              <seriesInfo name="Internet-Draft" value="draft-aboba-context-802-00"/>
            </reference>
          </references>
        </back>
      </rfc>
    OUTPUT
    expect(strip_guid(feature_convert(input)))
      .to be_xml_equivalent_to strip_guid(output)
  end

  it "processes IsoXML bibliographies without xinclude support" do
    # the released path offered a use_xinclude serialisation
    # option (IETF references with an xml2rfc URI emitted as
    # xi:include); the model-driven pipeline has no such option,
    # and the old expectation captured DEBUG output with no
    # xi:include in it anyway. Same input, plain bibliography.
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata>
      <title language="en" format="text/plain" type="main">The Holy Hand Grenade of Antioch</title>
      <docidentifier>draft-camelot-holy-grenade-01</docidentifier><docnumber>10</docnumber><contributor><role type="author"/><person>
      <name><completename>Arthur son of Uther Pendragon</completename></name></person></contributor>
      <ext><ipr>trust200902</ipr></ext>
      </bibdata>
      <sections><clause id="B"><title>Introduction</title>
      <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">
      <eref bibitemid="ISO712"/>
      <eref bibitemid="ISBN"/>
      <eref bibitemid="ISSN"/>
      <eref bibitemid="ISO16634"/>
      <eref bibitemid="ref11"/>
      </p>
      </clause>
      <clause id="A"><title>A-title</title><p>A</p></clause></sections>
      <bibliography><references id="_normative_references" obligation="informative" normative="true"><title>Normative References</title>
      <bibitem id="ISO712" type="standard">
      <title format="text/plain">Cereals or cereal products</title>
      <title type="main" format="text/plain">Cereals and cereal products</title>
      <uri>http://www.example.com</uri>
      <docidentifier type="ISO">ISO&#xa0;712</docidentifier>
      <contributor>
      <role type="publisher"/>
      <organization>
      <name>International Organization for Standardization</name>
      </organization>
      </contributor>
      </bibitem>
      <bibitem id="ISO16634" type="standard">
      <title language="x" format="text/plain">Cereals, pulses, milled cereal products, xxxx, oilseeds and animal feeding stuffs</title>
      <title language="en" format="text/plain">Cereals, pulses, milled cereal products, oilseeds and animal feeding stuffs</title>
      <uri>http://www.example.com</uri>
      <uri type="RDF">http://www.example.com/rdf</uri>
      <docidentifier type="ISO">ISO 16634:-- (all parts)</docidentifier>
      <docidentifier type="DOI">1234</docidentifier>
      <date type="published"><on>--</on></date>
      <contributor>
      <role type="publisher"/>
      <organization>
      <abbreviation>ISO</abbreviation>
      </organization>
      </contributor>
      <contributor>
      <role type="editor"/>
      <organization>
      <name>International Supporters of Odium</name>
      <abbreviation>ISO1</abbreviation>
      </organization>
      </contributor>
      <keyword><vocab>keyword1</vocab></keyword>
      <keyword><vocab>keyword2</vocab></keyword>
      <abstract><p>This is an abstract</p></abstract>
      <note format="text/plain" reference="1">ISO DATE: Under preparation. (Stage at the time of publication ISO/DIS 16634)</note>
      <extent type="part">
      <referenceFrom>all</referenceFrom>
      </extent>
      </bibitem>
      <bibitem id="ISO20483" type="standard">
      <title format="text/plain">Cereals and pulses</title>
      <docidentifier type="ISO">ISO 20483:2013-2014</docidentifier>
      <date type="published"><from>2013</from><to>2014</to></date>
      <contributor>
      <role type="publisher"/>
      <organization>
      <name>International Organization for Standardization</name>
      </organization>
      </contributor>
      <contributor>
      <role type="author"/>
      <person>
      <name><completename>Ölaf Nürk</completename>
      <surname>Nürk</surname>
      <forename>Ölaf</forename>
      </name>
      </person>
      </contributor>
      <contributor>
      <role type="author"/>
      <person>
      <name>
      <surname>Citizen</surname>
      <formatted-initials>A. B.</formatted-initials>
      </name>
      </person>
      </contributor>
      <abstract>This is an abstract</abstract>
      </bibitem>
      </references><references id="_bibliography" obligation="informative" normative="false">
      <title>Bibliography</title>
      <bibitem id="ISBN" type="book">
      <title format="text/plain">Chemicals for analytical laboratory use</title>
      <docidentifier type="ISBN">ISBN</docidentifier>
      <docidentifier type="metanorma">[1]</docidentifier>
      <contributor>
      <role type="publisher"/>
      <organization>
      <name>International SBN</name>
      <abbreviation>ISBN</abbreviation>
      </organization>
      </contributor>
      </bibitem>
      <bibitem id="ISSN" type="journal">
      <title format="text/plain">Instruments for analytical laboratory use</title>
      <docidentifier type="ISSN">ISSN</docidentifier>
      <docidentifier type="metanorma">[2]</docidentifier>
      <contributor>
      <role type="publisher"/>
      <organization>
      <name>International SSN</name>
      <abbreviation>ISSN</abbreviation>
      </organization>
      </contributor>
      </bibitem>
      <note><p>This is an annotation of document ISSN.</p></note>
      <note><p>This is another annotation of document ISSN.</p></note>
      <bibitem id="ISO3696" type="standard">
      <title format="text/plain">Water for analytical laboratory use</title>
      <docidentifier type="ISO">ISO 3696</docidentifier>
      <contributor>
      <role type="publisher"/>
      <organization>
      <name>International Standards Organization</name>
      <abbreviation>ISO</abbreviation>
      </organization>
      </contributor>
      </bibitem>
      <bibitem id="ref11">
      <title>Internet Calendaring and Scheduling Core Object Specification (iCalendar)</title>
      <docidentifier type="IETF">RFC 10</docidentifier>
      <contributor>
      <role type="publisher"/>
      <organization>
      <name>Internet Engineering Task Force</name>
      <abbreviation>IETF</abbreviation>
      </organization>
      </contributor>
      <uri type="xml">https://xml2rfc.tools.ietf.org/10.xml</uri>
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
          <section anchor="B">
            <name>Introduction</name>
            <t anchor="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">
      <xref target="ISO712"/>
      <xref target="ISBN"/>
      <xref target="ISSN"/>
      <xref target="ISO16634"/>
      <xref target="ref11"/>
      </t>
          </section>
          <section anchor="A">
            <name>A-title</name>
            <t>A</t>
          </section>
        </middle>
        <back>
          <references anchor="_normative_references">
            <name>Normative References</name>
            <reference anchor="ISO712">
              <front>
                <title>Cereals and cereal products</title>
                <author>
                  <organization>International Organization for Standardization</organization>
                </author>
              </front>
              <refcontent>ISO 712</refcontent>
            </reference>
            <reference anchor="ISO16634">
              <front>
                <title>Cereals, pulses, milled cereal products, xxxx, oilseeds and animal feeding stuffs</title>
                <author>
                  <organization abbrev="ISO1">International Supporters of Odium</organization>
                </author>
                <keyword>keyword1</keyword>
                <keyword>keyword2</keyword>
                <abstract>
                  <t>This is an abstract</t>
                </abstract>
              </front>
              <annotation>ISO DATE: Under preparation. (Stage at the time of publication ISO/DIS 16634)</annotation>
              <refcontent>ISO 16634:-- (all parts)</refcontent>
              <seriesInfo name="DOI" value="1234"/>
            </reference>
            <reference anchor="ISO20483">
              <front>
                <title>Cereals and pulses</title>
                <author initials="Ö." surname="Nürk" asciiSurname="Nurk" fullname="Ölaf Nürk" asciiFullname="Olaf Nurk"/>
                <author surname="Citizen"/>
                <date year="2013"/>
                <abstract>
                  <t>This is an abstract</t>
                </abstract>
              </front>
              <refcontent>ISO 20483:2013-2014</refcontent>
            </reference>
          </references>
          <references anchor="_bibliography">
            <name>Bibliography</name>
            <reference anchor="ISBN">
              <front>
                <title>Chemicals for analytical laboratory use</title>
                <author>
                  <organization abbrev="ISBN">International SBN</organization>
                </author>
              </front>
            </reference>
            <reference anchor="ISSN">
              <front>
                <title>Instruments for analytical laboratory use</title>
                <author>
                  <organization abbrev="ISSN">International SSN</organization>
                </author>
              </front>
            </reference>
            <reference anchor="ISO3696">
              <front>
                <title>Water for analytical laboratory use</title>
                <author>
                  <organization abbrev="ISO">International Standards Organization</organization>
                </author>
              </front>
              <refcontent>ISO 3696</refcontent>
            </reference>
            <reference anchor="ref11">
              <front>
                <title>Internet Calendaring and Scheduling Core Object Specification (iCalendar)</title>
                <author>
                  <organization abbrev="IETF">Internet Engineering Task Force</organization>
                </author>
              </front>
              <seriesInfo name="RFC" value="10"/>
            </reference>
          </references>
        </back>
      </rfc>
    OUTPUT
    expect(strip_guid(feature_convert(input)))
      .to be_xml_equivalent_to strip_guid(output)
  end

  it "processes nested bibliographies" do
    # typeless docidentifiers (B/D/F/H) are citation labels, not
    # citations: refcontent suppressed per the WS2 A-3 rule (the
    # old expectation carried them); the "Z" paragraph of the
    # relocated references-clause is dropped — RFC XML v3
    # <references> admits no <t> (the old DEBUG expectation
    # emitted it there, schema-invalid)
    input = <<~INPUT
      <ietf-standard  xmlns="http://riboseinc.com/isoxml">
      <sections><clause id="_clause" inline-header="false" obligation="normative">
      <title>Clause</title>
      <p id="_c401175c-2d9b-4758-ba27-d4f50ddb062a">A</p>
      </clause>
      <clause id="_references" inline-header="false" obligation="normative"><title>References</title><references id="_normative_references" normative="true" obligation="informative">
      <title>Normative references</title>
      <bibitem id="A">
      <title>X</title>
      <docidentifier>B</docidentifier>
      </bibitem>
      </references>
      <references id="_informative_references" normative="false" obligation="informative">
      <title>Bibliography</title><bibitem id="C">
      <title>Y</title>
      <docidentifier>D</docidentifier>
      </bibitem>
      </references></clause>
      <clause id="_references_2" inline-header="false" obligation="normative"><title>References 2</title><p id="_849e5255-ca89-4667-b517-743ab74a032e">Z</p>
      <references id="_normative_references_2" normative="false" obligation="informative">
      <title>Normative References</title><bibitem id="E">
      <title>X</title>
      <docidentifier>F</docidentifier>
      </bibitem>
      </references>
      <references id="_informative_references_2" normative="false" obligation="informative">
      <title>Informative References</title><bibitem id="G">
      <title>Y</title>
      <docidentifier>H</docidentifier>
      </bibitem>
      </references></clause></sections>
      </ietf-standard>
    INPUT
    output = <<~OUTPUT
      <?xml version="1.0" encoding="utf-8"?>
      <?rfc sortrefs="yes"?>
      <?rfc symrefs="yes"?>
      <?rfc tocdepth="4"?>
      <?rfc subcompact="no"?>
      <?rfc compact="yes"?>
      <?rfc strict="yes"?>
      <rfc category="std" ipr="trust200902" submissionType="IETF" version="3" xml:lang="en">
        <front>
          <title/>
          <seriesInfo name="Internet-Draft" value="" asciiName="Internet-Draft" status="Informational" stream="IETF"/>
          <date day="1" month="January" year="2000"/>
        </front>
        <middle>
          <section anchor="_clause">
            <name>Clause</name>
            <t anchor="_c401175c-2d9b-4758-ba27-d4f50ddb062a">A</t>
          </section>
        </middle>
        <back>
          <references anchor="_references">
            <name>References</name>
            <references anchor="_normative_references">
              <name>Normative references</name>
              <reference anchor="A">
                <front>
                  <title>X</title>
                  <author surname="Unknown"/>
                </front>
              </reference>
            </references>
            <references anchor="_informative_references">
              <name>Bibliography</name>
              <reference anchor="C">
                <front>
                  <title>Y</title>
                  <author surname="Unknown"/>
                </front>
              </reference>
            </references>
          </references>
          <references anchor="_references_2">
            <name>References 2</name>
            <references anchor="_normative_references_2">
              <name>Normative References</name>
              <reference anchor="E">
                <front>
                  <title>X</title>
                  <author surname="Unknown"/>
                </front>
              </reference>
            </references>
            <references anchor="_informative_references_2">
              <name>Informative References</name>
              <reference anchor="G">
                <front>
                  <title>Y</title>
                  <author surname="Unknown"/>
                </front>
              </reference>
            </references>
          </references>
        </back>
      </rfc>
    OUTPUT
    expect(strip_guid(feature_convert(input)))
      .to be_xml_equivalent_to strip_guid(output)
  end

  it "processes referencegroup" do
    # constituents come from <relation type="includes"> and run
    # the full reference pipeline: deterministic anchors from the
    # IETF docid (the old path generated GUIDs), STD/RFC
    # seriesInfo (the old path collapsed them into a refcontent
    # mislabelled "BCP 69" — classified old-path bug, WS2 log)
    input = <<~INPUT
      <ietf-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata>
      <title language="en" format="text/plain" type="main">The Holy Hand Grenade of Antioch</title>
      <docidentifier>draft-camelot-holy-grenade-01</docidentifier><docnumber>10</docnumber><contributor><role type="author"/><person>
      <name><completename>Arthur son of Uther Pendragon</completename></name></person></contributor>
      <ext><ipr>trust200902</ipr></ext>
      </bibdata>
      <sections><clause id="_clause" inline-header="false" obligation="normative">
      <title>Clause</title>
      <p id="_c401175c-2d9b-4758-ba27-d4f50ddb062a">A</p>
      </clause>
      <clause id="_references" inline-header="false" obligation="normative"><title>References</title><references id="_normative_references" normative="true" obligation="informative">
      <title>Normative references</title>
      <bibitem id="a" type="standard" schema-version="v1.2.8">  <fetched>2024-02-06</fetched>
      <title format="text/plain" language="en" script="Latn">Internet Standard technical specification 69</title>
      <uri type="src">https://www.rfc-editor.org/info/std69</uri>  <docidentifier type="IETF" primary="true">STD 69</docidentifier>  <docnumber>STD0069</docnumber>  <language>en</language>  <script>Latn</script>  <relation type="includes">    <bibitem type="standard">
      <title type="main" format="text/plain">Extensible Provisioning Protocol (EPP)</title>
      <uri type="src">https://www.rfc-editor.org/info/rfc5730</uri>      <docidentifier type="IETF" primary="true">RFC 5730</docidentifier>      <docidentifier type="DOI">10.17487/RFC5730</docidentifier>      <docnumber>RFC5730</docnumber>      <date type="published">        <on>2009-08</on>      </date>      <contributor>        <role type="author"/>        <person>
      <name>            <completename language="en" script="Latn">S. Hollenbeck</completename>          </name>
      </person>      </contributor>      <contributor>        <role type="publisher"/>        <organization>
      <name>RFC Publisher</name>
      </organization>      </contributor>      <contributor>        <role type="authorizer"/>        <organization>
      <name>RFC Series</name>
      </organization>      </contributor>      <language>en</language>      <script>Latn</script>      <abstract format="text/html" language="en" script="Latn">        <p id="_d066a1ec-5132-a20f-1f2b-4dbd3eb16e6f">This document describes an application-layer client-server protocol for the provisioning and management of objects stored in a shared central repository. Specified in XML, the protocol defines generic object management operations and an extensible framework that maps protocol operations to objects. This document includes a protocol specification, an object mapping template, and an XML media type registration. This document obsoletes RFC 4930. [STANDARDS-TRACK]</p>
      </abstract>      <series>
      <title format="text/plain">STD</title>
      <number>69</number>      </series>      <series>
      <title format="text/plain">RFC</title>
      <number>5730</number>      </series>      <series type="stream">
      <title format="text/plain">IETF</title>
      </series>      <keyword><vocab>shared framework mapping</vocab></keyword>    </bibitem>
      </relation>  <relation type="includes">    <bibitem type="standard">
      <title type="main" format="text/plain">Extensible Provisioning Protocol (EPP) Domain Name Mapping</title>
      <uri type="src">https://www.rfc-editor.org/info/rfc5731</uri>      <docidentifier type="IETF" primary="true">RFC 5731</docidentifier>      <docidentifier type="DOI">10.17487/RFC5731</docidentifier>      <docnumber>RFC5731</docnumber>      <date type="published">        <on>2009-08</on>      </date>      <contributor>        <role type="author"/>        <person>
      <name>            <completename language="en" script="Latn">S. Hollenbeck</completename>          </name>
      </person>      </contributor>      <contributor>        <role type="publisher"/>        <organization>
      <name>RFC Publisher</name>
      </organization>      </contributor>      <contributor>        <role type="authorizer"/>        <organization>
      <name>RFC Series</name>
      </organization>      </contributor>      <language>en</language>      <script>Latn</script>      <abstract format="text/html" language="en" script="Latn">        <p id="_1497824f-8380-202e-5a17-4a1dcff20b46">This document describes an Extensible Provisioning Protocol (EPP) mapping for the provisioning and management of Internet domain names stored in a shared central repository. Specified in XML, the mapping defines EPP command syntax and semantics as applied to domain names. This document obsoletes RFC 4931. [STANDARDS-TRACK]</p>
      </abstract>      <series>
      <title format="text/plain">STD</title>
      <number>69</number>      </series>      <series>
      <title format="text/plain">RFC</title>
      <number>5731</number>      </series>      <series type="stream">
      <title format="text/plain">IETF</title>
      </series>      <keyword><vocab>EPP</vocab></keyword>      <keyword><vocab>Extensible Provisioning Protocol</vocab></keyword>      <keyword><vocab>XML</vocab></keyword>      <keyword><vocab>domain</vocab></keyword>      <keyword><vocab>domain name</vocab></keyword>    </bibitem>
      </relation>  <relation type="includes">    <bibitem type="standard">
      <title type="main" format="text/plain">Extensible Provisioning Protocol (EPP) Host Mapping</title>
      <uri type="src">https://www.rfc-editor.org/info/rfc5732</uri>      <docidentifier type="IETF" primary="true">RFC 5732</docidentifier>      <docidentifier type="DOI">10.17487/RFC5732</docidentifier>      <docnumber>RFC5732</docnumber>      <date type="published">        <on>2009-08</on>      </date>      <contributor>        <role type="author"/>        <person>
      <name>            <completename language="en" script="Latn">S. Hollenbeck</completename>          </name>
      </person>      </contributor>      <contributor>        <role type="publisher"/>        <organization>
      <name>RFC Publisher</name>
      </organization>      </contributor>      <contributor>        <role type="authorizer"/>        <organization>
      <name>RFC Series</name>
      </organization>      </contributor>      <language>en</language>      <script>Latn</script>      <abstract format="text/html" language="en" script="Latn">        <p id="_38567886-68d2-829f-f17b-78074018d63a">This document describes an Extensible Provisioning Protocol (EPP) mapping for the provisioning and management of Internet host names stored in a shared central repository. Specified in XML, the mapping defines EPP command syntax and semantics as applied to host names. This document obsoletes RFC 4932. [STANDARDS-TRACK]</p>
      </abstract>      <series>
      <title format="text/plain">STD</title>
      <number>69</number>      </series>      <series>
      <title format="text/plain">RFC</title>
      <number>5732</number>      </series>      <series type="stream">
      <title format="text/plain">IETF</title>
      </series>      <keyword><vocab>EPP</vocab></keyword>      <keyword><vocab>Extensible Provisioning Protocol</vocab></keyword>      <keyword><vocab>XML</vocab></keyword>      <keyword><vocab>host</vocab></keyword>    </bibitem>
      </relation>  <relation type="includes">    <bibitem type="standard">
      <title type="main" format="text/plain">Extensible Provisioning Protocol (EPP) Contact Mapping</title>
      <uri type="src">https://www.rfc-editor.org/info/rfc5733</uri>      <docidentifier type="IETF" primary="true">RFC 5733</docidentifier>      <docidentifier type="DOI">10.17487/RFC5733</docidentifier>      <docnumber>RFC5733</docnumber>      <date type="published">        <on>2009-08</on>      </date>      <contributor>        <role type="author"/>        <person>
      <name>            <completename language="en" script="Latn">S. Hollenbeck</completename>          </name>
      </person>      </contributor>      <contributor>        <role type="publisher"/>        <organization>
      <name>RFC Publisher</name>
      </organization>      </contributor>      <contributor>        <role type="authorizer"/>        <organization>
      <name>RFC Series</name>
      </organization>      </contributor>      <language>en</language>      <script>Latn</script>      <abstract format="text/html" language="en" script="Latn">        <p id="_6cec650a-b014-69e7-fbb7-1e2a91530274">This document describes an Extensible Provisioning Protocol (EPP) mapping for the provisioning and management of individual or organizational social information identifiers (known as "contacts") stored in a shared central repository. Specified in Extensible Markup Language (XML), the mapping defines EPP command syntax and semantics as applied to contacts. This document obsoletes RFC 4933. [STANDARDS-TRACK]</p>
      </abstract>      <series>
      <title format="text/plain">STD</title>
      <number>69</number>      </series>      <series>
      <title format="text/plain">RFC</title>
      <number>5733</number>      </series>      <series type="stream">
      <title format="text/plain">IETF</title>
      </series>      <keyword><vocab>EPP</vocab></keyword>      <keyword><vocab>Extensible Provisioning Protocol</vocab></keyword>      <keyword><vocab>XML</vocab></keyword>      <keyword><vocab>contact</vocab></keyword>      <keyword><vocab>registrant</vocab></keyword>    </bibitem>
      </relation>  <relation type="includes">    <bibitem type="standard">
      <title type="main" format="text/plain">Extensible Provisioning Protocol (EPP) Transport over TCP</title>
      <uri type="src">https://www.rfc-editor.org/info/rfc5734</uri>      <docidentifier type="IETF" primary="true">RFC 5734</docidentifier>      <docidentifier type="DOI">10.17487/RFC5734</docidentifier>      <docnumber>RFC5734</docnumber>      <date type="published">        <on>2009-08</on>      </date>      <contributor>        <role type="author"/>        <person>
      <name>            <completename language="en" script="Latn">S. Hollenbeck</completename>          </name>
      </person>      </contributor>      <contributor>        <role type="publisher"/>        <organization>
      <name>RFC Publisher</name>
      </organization>      </contributor>      <contributor>        <role type="authorizer"/>        <organization>
      <name>RFC Series</name>
      </organization>      </contributor>      <language>en</language>      <script>Latn</script>      <abstract format="text/html" language="en" script="Latn">        <p id="_517d0846-27f6-8972-c4b0-221b1a54c3b3">This document describes how an Extensible Provisioning Protocol (EPP) session is mapped onto a single Transmission Control Protocol (TCP) connection. This mapping requires use of the Transport Layer Security (TLS) protocol to protect information exchanged between an EPP client and an EPP server. This document obsoletes RFC 4934. [STANDARDS-TRACK]</p>
      </abstract>      <series>
      <title format="text/plain">STD</title>
      <number>69</number>      </series>      <series>
      <title format="text/plain">RFC</title>
      <number>5734</number>      </series>      <series type="stream">
      <title format="text/plain">IETF</title>
      </series>      <keyword><vocab>EPP</vocab></keyword>      <keyword><vocab>Extensible Provisioning Protocol</vocab></keyword>      <keyword><vocab>XML</vocab></keyword>      <keyword><vocab>TCP</vocab></keyword>      <keyword><vocab>TLS</vocab></keyword>    </bibitem>
      </relation></bibitem>
      </references>
      </clause>
      </sections>
      </ietf-standard>
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
          <section anchor="_clause">
            <name>Clause</name>
            <t anchor="_c401175c-2d9b-4758-ba27-d4f50ddb062a">A</t>
          </section>
        </middle>
        <back>
          <references anchor="_references">
            <name>References</name>
            <references anchor="_normative_references">
              <name>Normative references</name>
              <referencegroup anchor="a" target="https://www.rfc-editor.org/info/std69">
                <reference anchor="RFC5730" target="https://www.rfc-editor.org/info/rfc5730">
                  <stream>IETF</stream>
                  <front>
                    <title>Extensible Provisioning Protocol (EPP)</title>
                    <author fullname="S. Hollenbeck"/>
                    <date month="August" year="2009"/>
                    <keyword>shared framework mapping</keyword>
                    <abstract>
                      <t>This document describes an application-layer client-server protocol for the provisioning and management of objects stored in a shared central repository. Specified in XML, the protocol defines generic object management operations and an extensible framework that maps protocol operations to objects. This document includes a protocol specification, an object mapping template, and an XML media type registration. This document obsoletes RFC 4930. [STANDARDS-TRACK]</t>
                    </abstract>
                  </front>
                  <seriesInfo name="DOI" value="10.17487/RFC5730"/>
                  <seriesInfo name="STD" value="69"/>
                  <seriesInfo name="RFC" value="5730"/>
                </reference>
                <reference anchor="RFC5731" target="https://www.rfc-editor.org/info/rfc5731">
                  <stream>IETF</stream>
                  <front>
                    <title>Extensible Provisioning Protocol (EPP) Domain Name Mapping</title>
                    <author fullname="S. Hollenbeck"/>
                    <date month="August" year="2009"/>
                    <keyword>EPP</keyword>
                    <keyword>Extensible Provisioning Protocol</keyword>
                    <keyword>XML</keyword>
                    <keyword>domain</keyword>
                    <keyword>domain name</keyword>
                    <abstract>
                      <t>This document describes an Extensible Provisioning Protocol (EPP) mapping for the provisioning and management of Internet domain names stored in a shared central repository. Specified in XML, the mapping defines EPP command syntax and semantics as applied to domain names. This document obsoletes RFC 4931. [STANDARDS-TRACK]</t>
                    </abstract>
                  </front>
                  <seriesInfo name="DOI" value="10.17487/RFC5731"/>
                  <seriesInfo name="STD" value="69"/>
                  <seriesInfo name="RFC" value="5731"/>
                </reference>
                <reference anchor="RFC5732" target="https://www.rfc-editor.org/info/rfc5732">
                  <stream>IETF</stream>
                  <front>
                    <title>Extensible Provisioning Protocol (EPP) Host Mapping</title>
                    <author fullname="S. Hollenbeck"/>
                    <date month="August" year="2009"/>
                    <keyword>EPP</keyword>
                    <keyword>Extensible Provisioning Protocol</keyword>
                    <keyword>XML</keyword>
                    <keyword>host</keyword>
                    <abstract>
                      <t>This document describes an Extensible Provisioning Protocol (EPP) mapping for the provisioning and management of Internet host names stored in a shared central repository. Specified in XML, the mapping defines EPP command syntax and semantics as applied to host names. This document obsoletes RFC 4932. [STANDARDS-TRACK]</t>
                    </abstract>
                  </front>
                  <seriesInfo name="DOI" value="10.17487/RFC5732"/>
                  <seriesInfo name="STD" value="69"/>
                  <seriesInfo name="RFC" value="5732"/>
                </reference>
                <reference anchor="RFC5733" target="https://www.rfc-editor.org/info/rfc5733">
                  <stream>IETF</stream>
                  <front>
                    <title>Extensible Provisioning Protocol (EPP) Contact Mapping</title>
                    <author fullname="S. Hollenbeck"/>
                    <date month="August" year="2009"/>
                    <keyword>EPP</keyword>
                    <keyword>Extensible Provisioning Protocol</keyword>
                    <keyword>XML</keyword>
                    <keyword>contact</keyword>
                    <keyword>registrant</keyword>
                    <abstract>
                      <t>This document describes an Extensible Provisioning Protocol (EPP) mapping for the provisioning and management of individual or organizational social information identifiers (known as "contacts") stored in a shared central repository. Specified in Extensible Markup Language (XML), the mapping defines EPP command syntax and semantics as applied to contacts. This document obsoletes RFC 4933. [STANDARDS-TRACK]</t>
                    </abstract>
                  </front>
                  <seriesInfo name="DOI" value="10.17487/RFC5733"/>
                  <seriesInfo name="STD" value="69"/>
                  <seriesInfo name="RFC" value="5733"/>
                </reference>
                <reference anchor="RFC5734" target="https://www.rfc-editor.org/info/rfc5734">
                  <stream>IETF</stream>
                  <front>
                    <title>Extensible Provisioning Protocol (EPP) Transport over TCP</title>
                    <author fullname="S. Hollenbeck"/>
                    <date month="August" year="2009"/>
                    <keyword>EPP</keyword>
                    <keyword>Extensible Provisioning Protocol</keyword>
                    <keyword>XML</keyword>
                    <keyword>TCP</keyword>
                    <keyword>TLS</keyword>
                    <abstract>
                      <t>This document describes how an Extensible Provisioning Protocol (EPP) session is mapped onto a single Transmission Control Protocol (TCP) connection. This mapping requires use of the Transport Layer Security (TLS) protocol to protect information exchanged between an EPP client and an EPP server. This document obsoletes RFC 4934. [STANDARDS-TRACK]</t>
                    </abstract>
                  </front>
                  <seriesInfo name="DOI" value="10.17487/RFC5734"/>
                  <seriesInfo name="STD" value="69"/>
                  <seriesInfo name="RFC" value="5734"/>
                </reference>
              </referencegroup>
            </references>
          </references>
        </back>
      </rfc>
    OUTPUT
    expect(strip_guid(feature_convert(input)))
      .to be_xml_equivalent_to strip_guid(output)
  end

  it "renders formattedref with literal bracketed URL as text, " \
     "not fabricated markup (#267)" do
    # A formattedref carrying a literal "<" + <link/> + ">" used to be
    # flattened into the title via a string -> XML reparse, fabricating
    # an element named "http:" -- a QName violation fatal to xml2rfc
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata>
      <title language="en" format="text/plain" type="main">Test</title>
      <docidentifier>draft-test-formattedref-01</docidentifier><docnumber>10</docnumber>
      <contributor><role type="author"/><person>
      <name><completename>Arthur son of Uther Pendragon</completename></name></person></contributor>
      <ext><ipr>trust200902</ipr></ext>
      </bibdata>
      <sections><clause id="A"><title>A-title</title><p>A</p></clause></sections>
      <bibliography><references id="_bibliography" obligation="informative" normative="false">
      <title>Bibliography</title>
      <bibitem anchor="IERS" id="_iers001">
        <formattedref format="application/x-isodoc+xml">International Earth Rotation Service Bulletins, &lt;<link target="http://hpiers.obspm.fr/eop-pc/products/bulletins.html"/>&gt;.</formattedref>
        <docidentifier>IERS</docidentifier>
      </bibitem>
      </references></bibliography>
      </iso-standard>
    INPUT
    xml = feature_convert(input)
    expect(xml).not_to include("<http:")
    ref = xml[%r{<reference anchor="IERS".*?</reference>}m]
    expect(strip_guid(ref)).to be_xml_equivalent_to <<~OUTPUT
      <reference anchor="IERS">
        <front>
          <title>International Earth Rotation Service Bulletins, &#x3c;http://hpiers.obspm.fr/eop-pc/products/bulletins.html&#x3e;.</title>
          <author surname="Unknown"/>
        </front>
      </reference>
    OUTPUT
  end

  it "normalises reference stream to the xml2rfc enumeration (#270)" do
    # relaton stream values arrive in arbitrary case (INDEPENDENT), but
    # <stream> admits only IAB/IETF/IRTF/independent; unknown streams
    # are omitted rather than emitted verbatim, which was xml2rfc-fatal
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata>
      <title language="en" format="text/plain" type="main">Test</title>
      <docidentifier>draft-test-stream-01</docidentifier><docnumber>10</docnumber>
      <contributor><role type="author"/><person>
      <name><completename>Arthur son of Uther Pendragon</completename></name></person></contributor>
      <ext><ipr>trust200902</ipr></ext>
      </bibdata>
      <sections><clause id="A"><title>A-title</title><p>A</p></clause></sections>
      <bibliography><references id="_bibliography" obligation="informative" normative="false">
      <title>Bibliography</title>
      <bibitem anchor="RFC1149" id="_r1" type="standard">
        <title format="text/plain">Avian carriers</title>
        <docidentifier type="IETF" primary="true">RFC 1149</docidentifier>
        <series type="stream"><title format="text/plain">INDEPENDENT</title></series>
      </bibitem>
      <bibitem anchor="XYZ" id="_r2" type="standard">
        <title format="text/plain">Mystery stream</title>
        <docidentifier type="XYZ" primary="true">XYZ 1</docidentifier>
        <series type="stream"><title format="text/plain">Homebrew</title></series>
      </bibitem>
      </references></bibliography>
      </iso-standard>
    INPUT
    xml = feature_convert(input)
    ref1 = xml[%r{<reference anchor="RFC1149".*?</reference>}m]
    expect(ref1).to include("<stream>independent</stream>")
    ref2 = xml[%r{<reference anchor="XYZ".*?</reference>}m]
    expect(ref2).not_to include("<stream>")
  end

end
