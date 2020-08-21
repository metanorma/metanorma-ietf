require "spec_helper"

RSpec.describe IsoDoc::Ietf::RfcConvert do
  it "validates document against ISO XML schema" do
    FileUtils.rm_f "test.rfc.xml"
    expect {IsoDoc::Ietf::RfcConvert.new({}).postprocess(<<~"INPUT", "test.rfc.xml", nil)}.to output(/RFC XML: Line \d+:\d+ element "rfc" incomplete; missing required element "middle"/).to_stderr
    <rfc xmlns:xi="http://www.w3.org/2001/XInclude" docName="draft-camelot-holy-grenade-01" category="info" sortRefs="true" tocInclude="true" submissionType="independent" xml:lang="en" version="3" >
  <front>
    <title abbrev="Hand Grenade of Antioch">The Holy Hand Grenade of Antioch</title>
    <seriesInfo value="draft-camelot-holy-grenade-01" status="Informational" stream="independent" name="Internet-Draft" asciiName="Internet-Draft"></seriesInfo>
    <seriesInfo name="" value="" status="informational"></seriesInfo>
    <author fullname="Arthur son of Uther Pendragon">
      <address>
        <postal></postal>
        <email>arthur.pendragon@ribose.com</email>
        <uri></uri>
      </address>
    </author>
    <area>General</area>
    <area>Operations and Management</area>
    <abstract anchor="_absttacr">
<t anchor="_2cf15089-1c6a-4156-a904-94376faa6cd1">Abc
Def</t>
</abstract>
  </front>
  </rfc>
INPUT
  end

  it "aborts if content error" do
    FileUtils.rm_f "test.rfc.xml"
    FileUtils.rm_f "test.rfc.xml.err"
    expect {IsoDoc::Ietf::RfcConvert.new({}).postprocess(<<~"INPUT", "test.rfc.xml", nil)}.to output(/Cannot continue processing/).to_stderr
    <rfc xmlns:xi="http://www.w3.org/2001/XInclude" docName="draft-camelot-holy-grenade-01" ipr="trust200902" category="info" sortRefs="true" tocInclude="true" submissionType="independent" xml:lang="en" version="3" >
  <front>
    <title abbrev="Hand Grenade of Antioch">The Holy Hand Grenade of Antioch</title>
    <seriesInfo value="draft-camelot-holy-grenade-01" status="Informational" stream="independent" name="Internet-Draft" asciiName="Internet-Draft"></seriesInfo>
    <seriesInfo name="" value="" status="informational"></seriesInfo>
    <author fullname="Arthur son of Uther Pendragon">
      <address>
        <postal></postal>
        <email>arthur.pendragon@ribose.com</email>
        <uri></uri>
      </address>
    </author>
    <area>General</area>
    <area>Operations and Management</area>
    <abstract anchor="_absttacr">
<t anchor="_2cf15089-1c6a-4156-a904-94376faa6cd1">Abc
Def</t>
</abstract>
  </front>
  <middle>
  <section anchor="A" numbered="false">
  <name>Clause</name>
  <section numbered="true">
  <name>Subclause</name>
  </section>
  </section>
  </middle>
  </rfc>
INPUT
expect(File.exist?("test.rfc.xml")).to be false
expect(File.exist?("test.rfc.xml.err")).to be true
  end

    it "does not abort if no content error" do
    FileUtils.rm_f "test.rfc.xml"
    FileUtils.rm_f "test.rfc.xml.err"
    expect {IsoDoc::Ietf::RfcConvert.new({}).postprocess(<<~"INPUT", "test.rfc.xml", nil)}.not_to output(/Cannot continue processing/).to_stderr
    <rfc xmlns:xi="http://www.w3.org/2001/XInclude" docName="draft-camelot-holy-grenade-01" ipr="trust200902" category="info" sortRefs="true" tocInclude="true" submissionType="independent" xml:lang="en" version="3" >
  <front>
    <title abbrev="Hand Grenade of Antioch">The Holy Hand Grenade of Antioch</title>
    <seriesInfo value="draft-camelot-holy-grenade-01" status="Informational" stream="independent" name="Internet-Draft" asciiName="Internet-Draft"></seriesInfo>
    <seriesInfo name="" value="" status="informational"></seriesInfo>
    <author fullname="Arthur son of Uther Pendragon">
      <address>
        <postal></postal>
        <email>arthur.pendragon@ribose.com</email>
        <uri></uri>
      </address>
    </author>
    <area>General</area>
    <area>Operations and Management</area>
    <abstract anchor="_absttacr">
<t anchor="_2cf15089-1c6a-4156-a904-94376faa6cd1">Abc
Def</t>
</abstract>
  </front>
  <middle>
  <section anchor="A" numbered="true">
  <name>Clause</name>
  <section numbered="true">
  <name>Subclause</name>
  </section>
  </section>
  </middle>
  </rfc>
INPUT
expect(File.exist?("test.rfc.xml")).to be true
expect(File.exist?("test.rfc.xml.err")).to be false
  end

    it "reports error on section numbering" do
      rfc = <<~INPUT
    <rfc xmlns:xi="http://www.w3.org/2001/XInclude" docName="draft-camelot-holy-grenade-01" ipr="trust200902" category="info" sortRefs="true" tocInclude="true" submissionType="independent" xml:lang="en" version="3" >
  <front>
    <title abbrev="Hand Grenade of Antioch">The Holy Hand Grenade of Antioch</title>
    <seriesInfo value="draft-camelot-holy-grenade-01" status="Informational" stream="independent" name="Internet-Draft" asciiName="Internet-Draft"></seriesInfo>
    <seriesInfo name="" value="" status="informational"></seriesInfo>
    <author fullname="Arthur son of Uther Pendragon">
      <address>
        <postal></postal>
        <email>arthur.pendragon@ribose.com</email>
        <uri></uri>
      </address>
    </author>
    <area>General</area>
    <area>Operations and Management</area>
    <abstract anchor="_absttacr">
<t anchor="_2cf15089-1c6a-4156-a904-94376faa6cd1">Abc
Def</t>
</abstract>
  </front>
  <middle>
  <section anchor="A" numbered="false">
  <name>Clause</name>
  <section numbered="true">
  <name>Subclause</name>
  </section>
  <section anchor="B">
  </section>
  </section>
  <section numbered="true">
  <name>New Clause</name>
  </section>
  <section anchor="C">
  </section>
  </middle>
  </rfc>
INPUT
      expect {IsoDoc::Ietf::RfcConvert.new({}).postprocess(rfc, "test.rfc.xml", nil)}.to output(/RFC XML: Numbered section Subclause under unnumbered section Clause/).to_stderr
      expect {IsoDoc::Ietf::RfcConvert.new({}).postprocess(rfc, "test.rfc.xml", nil)}.to output(/RFC XML: Numbered section B under unnumbered section Clause/).to_stderr
      expect {IsoDoc::Ietf::RfcConvert.new({}).postprocess(rfc, "test.rfc.xml", nil)}.to output(/RFC XML: Numbered section New Clause following unnumbered section Clause/).to_stderr
      expect {IsoDoc::Ietf::RfcConvert.new({}).postprocess(rfc, "test.rfc.xml", nil)}.to output(/RFC XML: Numbered section C following unnumbered section Clause/).to_stderr
  end

 it "reports error on table of content tagging" do
      rfc = <<~INPUT
    <rfc xmlns:xi="http://www.w3.org/2001/XInclude" docName="draft-camelot-holy-grenade-01" ipr="trust200902" category="info" sortRefs="true" tocInclude="true" submissionType="independent" xml:lang="en" version="3" >
  <front>
    <title abbrev="Hand Grenade of Antioch">The Holy Hand Grenade of Antioch</title>
    <seriesInfo value="draft-camelot-holy-grenade-01" status="Informational" stream="independent" name="Internet-Draft" asciiName="Internet-Draft"></seriesInfo>
    <seriesInfo name="" value="" status="informational"></seriesInfo>
    <author fullname="Arthur son of Uther Pendragon">
      <address>
        <postal></postal>
        <email>arthur.pendragon@ribose.com</email>
        <uri></uri>
      </address>
    </author>
    <area>General</area>
    <area>Operations and Management</area>
    <abstract anchor="_absttacr">
<t anchor="_2cf15089-1c6a-4156-a904-94376faa6cd1">Abc
Def</t>
</abstract>
  </front>
  <middle>
  <section anchor="A" numbered="true" toc="exclude">
  <name>Clause</name>
  <section numbered="true" toc="include">
  <name>Subclause</name>
  </section>
  </section>
  </middle>
  </rfc>
INPUT
      expect {IsoDoc::Ietf::RfcConvert.new({}).postprocess(rfc, "test.rfc.xml", nil)}.to output(/RFC XML: Section Subclause with toc=include is included in section Clause with toc=exclude/).to_stderr
  end

 it "reports error on references" do
      rfc = <<~INPUT
    <rfc xmlns:xi="http://www.w3.org/2001/XInclude" docName="draft-camelot-holy-grenade-01" ipr="trust200902" category="info" sortRefs="true" tocInclude="true" submissionType="independent" xml:lang="en" version="3" >
  <front>
    <title abbrev="Hand Grenade of Antioch">The Holy Hand Grenade of Antioch</title>
    <seriesInfo value="draft-camelot-holy-grenade-01" status="Informational" stream="independent" name="Internet-Draft" asciiName="Internet-Draft"></seriesInfo>
    <seriesInfo name="" value="" status="informational"></seriesInfo>
    <author fullname="Arthur son of Uther Pendragon">
      <address>
        <postal></postal>
        <email>arthur.pendragon@ribose.com</email>
        <uri></uri>
      </address>
    </author>
    <area>General</area>
    <area>Operations and Management</area>
    <abstract anchor="_absttacr">
<t anchor="_2cf15089-1c6a-4156-a904-94376faa6cd1">Abc
Def</t>
</abstract>
  </front>
  <middle>
  <section anchor="A" numbered="true" toc="exclude">
  <name>Clause</name>
  <section numbered="true" toc="include" anchor="B">
  </section>
  </section>
  </middle>
  <back>
  <references anchor="_normative_references">
  <reference anchor="RFC2119">
        <front>
          <title>Key words for use in RFCs to Indicate Requirement Levels</title>
          <author fullname="S. Bradner" asciiFullname="S. Bradner"></author>
          <date month="March" year="1997"></date>
          <abstract>
            <t>In many standards track documents several words are used to signify the requirements in the specification.  These words are often capitalized. This document defines these words as they should be interpreted in IETF documents.  This document specifies an Internet Best Current Practices for the Internet Community, and requests discussion and suggestions for improvements.</t>
          </abstract>
        </front>
        <format target="https://xml2rfc.tools.ietf.org/public/rfc/bibxml/reference.RFC.2119.xml" type="xml"></format>
        <format target="https://www.rfc-editor.org/info/rfc2119" type="src"></format>
        <refcontent>IETF RFC 2119</refcontent>
        <seriesInfo name="RFC"></seriesInfo>
        <seriesInfo value="10.17487/RFC2119" name="DOI"></seriesInfo>
      </reference>
      <reference target="https://www.rfc-editor.org/info/rfc7991" anchor="RFC7991">
        <front>
          <title>The "xml2rfc" Version 3 Vocabulary</title>
          <author fullname="P. Hoffman" asciiFullname="P. Hoffman"></author>
          <date month="December" year="2016"></date>
          <abstract>
            <t>This document defines the "xml2rfc" version 3 vocabulary: an XML-based language used for writing RFCs and Internet-Drafts.  It is heavily derived from the version 2 vocabulary that is also under discussion.  This document obsoletes the v2 grammar described in RFC 7749.</t>
          </abstract>
        </front>
        <format target="https://xml2rfc.tools.ietf.org/public/rfc/bibxml/reference.RFC.7991.xml" type="xml"></format>
        <format target="https://www.rfc-editor.org/info/rfc7991" type="src"></format>
        <refcontent>IETF RFC 7991</refcontent>
        <seriesInfo name="RFC"></seriesInfo>
        <seriesInfo value="10.17487/RFC7991" name="DOI"></seriesInfo>
      </reference>
  </references>
  </back>
  </rfc>
INPUT
      expect {IsoDoc::Ietf::RfcConvert.new({}).postprocess(rfc, "test.rfc.xml", nil)}.to output(/RFC XML: Cannot generate table of contents entry for B, as it has no title/).to_stderr
      expect {IsoDoc::Ietf::RfcConvert.new({}).postprocess(rfc, "test.rfc.xml", nil)}.to output(/RFC XML: Cannot generate table of contents entry for _normative_references, as it has no title/).to_stderr
      expect {IsoDoc::Ietf::RfcConvert.new({}).postprocess(rfc, "test.rfc.xml", nil)}.to output(/RFC XML: for reference RFC2119, the seriesInfo with name=RFC has been given no value/).to_stderr
      expect {IsoDoc::Ietf::RfcConvert.new({}).postprocess(rfc, "test.rfc.xml", nil)}.not_to output(/RFC XML: for reference RFC7991, the seriesInfo with name=RFC has been given no value/).to_stderr
  end

it "reports error on xref and relref" do
      rfc = <<~INPUT
    <rfc xmlns:xi="http://www.w3.org/2001/XInclude" docName="draft-camelot-holy-grenade-01" ipr="trust200902" category="info" sortRefs="true" tocInclude="true" submissionType="independent" xml:lang="en" version="3" >
  <front>
    <title abbrev="Hand Grenade of Antioch">The Holy Hand Grenade of Antioch</title>
    <seriesInfo value="draft-camelot-holy-grenade-01" status="Informational" stream="independent" name="Internet-Draft" asciiName="Internet-Draft"></seriesInfo>
    <seriesInfo name="" value="" status="informational"></seriesInfo>
    <author fullname="Arthur son of Uther Pendragon" anchor="AUTH">
      <address>
        <postal></postal>
        <email>arthur.pendragon@ribose.com</email>
        <uri></uri>
      </address>
    </author>
    <area>General</area>
    <area>Operations and Management</area>
    <abstract anchor="_absttacr">      
<t anchor="_2cf15089-1c6a-4156-a904-94376faa6cd1">Abc
Def</t>
</abstract>
  </front>
  <middle>
  <section anchor="A" numbered="true" toc="exclude">
  <name>Clause</name>
  <section numbered="true" toc="include" anchor="B">
  <t><xref target="_normative_references"/><xref target="_normative_references1"/>
  <relref target="RFC2119"/><relref target="RFC21191"/>
  <relref format="title" target="RFC2119"/>
  <relref format="title" target="RFC7991"/>
  <xref format="counter" target="C1"/>
  <xref format="counter" target="C"/>
  <relref format="counter" target="RFC2119"/>
  <relref format="counter" target="RFC7991" section="3"/>
  <xref format="counter" target="C2"/>
  <xref format="counter" target="C4"/>
  <xref format="title" target="AUTH"/>
  <relref format="counter" target="RFC2119" relative="A"/>
  <relref format="counter" target="RFC7991" relative="A" section="3"/>
  <xref format="counter" target="C" section="A"/>
  <xref format="counter" target="C" relative="A"/>
  <relref format="counter" target="ACVP" section="3"/>
  <relref format="counter" target="ACVP" relative="B"/>
  <relref format="counter" target="ACVP1" relative="B"/>
  </t>
  </section>
  <section anchor="C">
  <ol anchor="C1">
  <li anchor="C2">B</li>
  </ol>
  <ul anchor="C3">
  <li anchor="C4">B</li>
  </ul>
  </section>
  </section>
  </middle>
  <back>
  <references anchor="_normative_references">
  <reference anchor="RFC2119">
        <front>
          <author fullname="S. Bradner" asciiFullname="S. Bradner"></author>
          <date month="March" year="1997"></date>
          <abstract>
            <t>In many standards track documents several words are used to signify the requirements in the specification.  These words are often capitalized. This document defines these words as they should be interpreted in IETF documents.  This document specifies an Internet Best Current Practices for the Internet Community, and requests discussion and suggestions for improvements.</t>
          </abstract>
        </front>
        <format target="https://xml2rfc.tools.ietf.org/public/rfc/bibxml/reference.RFC.2119.xml" type="xml"></format>
        <format target="https://www.rfc-editor.org/info/rfc2119" type="src"></format>
        <refcontent>IETF RFC 2119</refcontent>
        <seriesInfo name="RFC"></seriesInfo>
        <seriesInfo value="10.17487/RFC2119" name="DOI"></seriesInfo>
      </reference>
      <reference target="https://www.rfc-editor.org/info/rfc7991" anchor="RFC7991">
        <front>
          <title>The "xml2rfc" Version 3 Vocabulary</title>
          <author fullname="P. Hoffman" asciiFullname="P. Hoffman"></author>
          <date month="December" year="2016"></date>
          <abstract>
            <t>This document defines the "xml2rfc" version 3 vocabulary: an XML-based language used for writing RFCs and Internet-Drafts.  It is heavily derived from the version 2 vocabulary that is also under discussion.  This document obsoletes the v2 grammar described in RFC 7749.</t>
          </abstract>
        </front>
        <format target="https://xml2rfc.tools.ietf.org/public/rfc/bibxml/reference.RFC.7991.xml" type="xml"></format>
        <format target="https://www.rfc-editor.org/info/rfc7991" type="src"></format>
        <refcontent>IETF RFC 7991</refcontent>
        <seriesInfo name="RFC"></seriesInfo>
        <seriesInfo value="10.17487/RFC7991" name="DOI"></seriesInfo>
      </reference>
      <reference anchor="ACVP">
        <front>
          <title>Automatic Cryptographic Validation Protocol</title>
          <author>
            <organization ascii="National Institute of Standards and Technology" abbrev="NIST">National Institute of Standards and Technology</organization>
          </author>
          <date year="2019"></date>
        </front>
      </reference>
      <reference anchor="ACVP1" target="http://www.example.com">
        <front>
          <title>Automatic Cryptographic Validation Protocol</title>
          <author>
            <organization ascii="National Institute of Standards and Technology" abbrev="NIST">National Institute of Standards and Technology</organization>
          </author>
          <date year="2019"></date>
        </front>
      </reference>
      </references>
</back>
</rfc>
INPUT
      expect {IsoDoc::Ietf::RfcConvert.new({}).postprocess(rfc, "test.rfc.xml", nil)}.to output(/RFC XML: xref target _normative_references1 does not exist in the document/).to_stderr
      expect {IsoDoc::Ietf::RfcConvert.new({}).postprocess(rfc, "test.rfc.xml", nil)}.not_to output(/RFC XML: xref target _normative_references does not exist in the document/).to_stderr
      expect {IsoDoc::Ietf::RfcConvert.new({}).postprocess(rfc, "test.rfc.xml", nil)}.to output(/RFC XML: relref target RFC21191 does not exist in the document/).to_stderr
      expect {IsoDoc::Ietf::RfcConvert.new({}).postprocess(rfc, "test.rfc.xml", nil)}.not_to output(/RFC XML: relref target RFC2119 does not exist in the document/).to_stderr
      expect {IsoDoc::Ietf::RfcConvert.new({}).postprocess(rfc, "test.rfc.xml", nil)}.to output(/RFC XML: reference RFC2119 has been referenced by relref with format=title, but the reference has no title/).to_stderr
      expect {IsoDoc::Ietf::RfcConvert.new({}).postprocess(rfc, "test.rfc.xml", nil)}.not_to output(/RFC XML: reference RFC7991 has been referenced by relref with format=title, but the reference has no title/).to_stderr
      expect {IsoDoc::Ietf::RfcConvert.new({}).postprocess(rfc, "test.rfc.xml", nil)}.to output(%r{<xref format="counter" target="C1"/> with format=counter is only allowed for clauses, tables, figures, list entries, definition terms, paragraphs, bibliographies, and bibliographic entries}).to_stderr
      expect {IsoDoc::Ietf::RfcConvert.new({}).postprocess(rfc, "test.rfc.xml", nil)}.not_to output(%r{<xref format="counter" target="C"/> with format=counter is only allowed for clauses, tables, figures, list entries, definition terms, paragraphs, bibliographies, and bibliographic entries}).to_stderr
      expect {IsoDoc::Ietf::RfcConvert.new({}).postprocess(rfc, "test.rfc.xml", nil)}.to output(%r{reference RFC2119 has been referenced by xref <relref format="counter" target="RFC2119"/> with format=counter, which requires a section attribute}).to_stderr
      expect {IsoDoc::Ietf::RfcConvert.new({}).postprocess(rfc, "test.rfc.xml", nil)}.not_to output(%r{reference RFC7991 has been referenced by xref <relref format="counter" target="RFC7991"/> with format=counter, which requires a section attribute}).to_stderr
      expect {IsoDoc::Ietf::RfcConvert.new({}).postprocess(rfc, "test.rfc.xml", nil)}.to output(%r{<xref format="counter" target="C4"/> with format=counter refers to an unnumbered list entry}).to_stderr
      expect {IsoDoc::Ietf::RfcConvert.new({}).postprocess(rfc, "test.rfc.xml", nil)}.not_to output(%r{<xref format="counter" target="C2"/> with format=counter refers to an unnumbered list entry}).to_stderr
      expect {IsoDoc::Ietf::RfcConvert.new({}).postprocess(rfc, "test.rfc.xml", nil)}.to output(%r{<xref format="title" target="AUTH"/> with format=title cannot reference a <author> element}).to_stderr
      expect {IsoDoc::Ietf::RfcConvert.new({}).postprocess(rfc, "test.rfc.xml", nil)}.not_to output(%r{<relref format="title" target="RFC2119"/> with format=title cannot reference a <reference> element}).to_stderr
      expect {IsoDoc::Ietf::RfcConvert.new({}).postprocess(rfc, "test.rfc.xml", nil)}.to output(%r{<relref format="counter" target="RFC2119" relative="A"/> with relative attribute requires a section attribute}).to_stderr
      expect {IsoDoc::Ietf::RfcConvert.new({}).postprocess(rfc, "test.rfc.xml", nil)}.not_to output(%r{<relref format="counter" target="RFC7991" relative="A" section="3"/> with relative attribute requires a section attribute}).to_stderr
      expect {IsoDoc::Ietf::RfcConvert.new({}).postprocess(rfc, "test.rfc.xml", nil)}.to output(%r{<xref format="counter" target="C" relative="A"/> has a relative attribute, but C points to a section}).to_stderr
      expect {IsoDoc::Ietf::RfcConvert.new({}).postprocess(rfc, "test.rfc.xml", nil)}.to output(%r{<xref format="counter" target="C" section="A"/> has a section attribute, but C points to a section}).to_stderr
      expect {IsoDoc::Ietf::RfcConvert.new({}).postprocess(rfc, "test.rfc.xml", nil)}.not_to output(%r{<relref format="counter" target="RFC7991" relative="A" section="3"/> has a relative attribute, but C points to a reference}).to_stderr
      expect {IsoDoc::Ietf::RfcConvert.new({}).postprocess(rfc, "test.rfc.xml", nil)}.not_to output(%r{<relref format="counter" target="RFC7991" relative="A" section="3"/> has a section attribute, but C points to a reference}).to_stderr
      expect {IsoDoc::Ietf::RfcConvert.new({}).postprocess(rfc, "test.rfc.xml", nil)}.to output(%r{<relref format="counter" target="ACVP" section="3"/> must use a relative attribute, since it does not point to a RFC or Internet-Draft reference}).to_stderr
      expect {IsoDoc::Ietf::RfcConvert.new({}).postprocess(rfc, "test.rfc.xml", nil)}.not_to output(%r{<relref format="counter" target="ACVP" section="3" relative="B"/> must use a relative attribute, since it does not point to a RFC or Internet-Draft reference}).to_stderr
      expect {IsoDoc::Ietf::RfcConvert.new({}).postprocess(rfc, "test.rfc.xml", nil)}.not_to output(%r{<relref format="counter" target="RFC7991" section="3"/> must use a relative attribute, since it does not point to a RFC or Internet-Draft reference}).to_stderr
      expect {IsoDoc::Ietf::RfcConvert.new({}).postprocess(rfc, "test.rfc.xml", nil)}.to output(%r{need an explicit target= URL attribute in the reference pointed to by <relref format="counter" target="ACVP" relative="B"/>}).to_stderr
      expect {IsoDoc::Ietf::RfcConvert.new({}).postprocess(rfc, "test.rfc.xml", nil)}.not_to output(%r{need an explicit target= URL attribute in the reference pointed to by <relref format="counter" target="ACVP1" relative="B"/>}).to_stderr
      expect {IsoDoc::Ietf::RfcConvert.new({}).postprocess(rfc, "test.rfc.xml", nil)}.not_to output(%r{need an explicit target= URL attribute in the reference pointed to by <relref format="counter" target="RFC2119" relative="A"/>}).to_stderr
end

 it "reports error on metadata" do
      rfc = <<~INPUT
    <rfc xmlns:xi="http://www.w3.org/2001/XInclude" number="draft-camelot-holy-grenade-01" ipr="trust200902" category="info" sortRefs="true" tocInclude="true" submissionType="independent" xml:lang="en" version="3" >
  <front>
    <title abbrev="Hand Grenade of Antioch">The Holy Hand Grenade of Antioch</title>
    <seriesInfo value="draft-camelot-holy-grenade-02" status="Informational" stream="independent" name="RFC" asciiName="RFC"></seriesInfo>
    <seriesInfo name="" value="" status="informational"></seriesInfo>
    <author fullname="Arthur son of Uther Pendragon">
      <address>
        <postal></postal>
        <email>arthur.pendragon@ribose.com</email>
        <uri></uri>
      </address>
    </author>
    <area>General</area>
    <area>Operations and Management</area>
    <abstract anchor="_absttacr">
<t anchor="_2cf15089-1c6a-4156-a904-94376faa6cd1">Abc
Def</t>
</abstract>
  </front>
  <link rel="convertedFrom">https://datatracker.ietf.org/doc/undraft-1</link>
  <middle>
  <section anchor="A" numbered="true" toc="exclude">
  <name>Clause</name>
  <section numbered="true" toc="include">
  <name>Subclause</name>
  </section>
  </section>
  </middle>
  </rfc>
INPUT
      expect {IsoDoc::Ietf::RfcConvert.new({}).postprocess(rfc, "test.rfc.xml", nil)}.to output(%r{RFC XML: <link rel='convertedFrom'> \(:derived-from: document attribute\) must start with https://datatracker.ietf.org/doc/draft-}).to_stderr
      expect {IsoDoc::Ietf::RfcConvert.new({}).postprocess(rfc, "test.rfc.xml", nil)}.to output(%r{Mismatch between <rfc number='draft-camelot-holy-grenade-01'> \(:docnumber: NUMBER\) and <seriesInfo name='RFC' value='draft-camelot-holy-grenade-02'> \(:intended-series: TYPE NUMBER\)}).to_stderr
      expect {IsoDoc::Ietf::RfcConvert.new({}).postprocess(rfc, "test.rfc.xml", nil)}.to output(%r{RFC XML: RFC identifier <rfc number='draft-camelot-holy-grenade-01'> \(:docnumber: NUMBER\) must be a number}).to_stderr
 end

 it "does not reports non-error on metadata, 1" do
      rfc = <<~INPUT
    <rfc xmlns:xi="http://www.w3.org/2001/XInclude" number="draft-camelot-holy-grenade-01" ipr="none" category="info" sortRefs="true" tocInclude="true" submissionType="independent" xml:lang="en" version="3" >
  <front>
    <title abbrev="Hand Grenade of Antioch">The Holy Hand Grenade of Antioch</title>
    <seriesInfo value="draft-camelot-holy-grenade-02" status="Informational" stream="independent" name="RFC" asciiName="RFC"></seriesInfo>
    <seriesInfo name="" value="" status="informational"></seriesInfo>
    <author fullname="Arthur son of Uther Pendragon">
      <address>
        <postal></postal>
        <email>arthur.pendragon@ribose.com</email>
        <uri></uri>
      </address>
    </author>
    <area>General</area>
    <area>Operations and Management</area>
    <abstract anchor="_absttacr">
<t anchor="_2cf15089-1c6a-4156-a904-94376faa6cd1">Abc
Def</t>
</abstract>
  </front>
  <middle>
  <section anchor="A" numbered="true" toc="exclude">
  <name>Clause</name>
  <section numbered="true" toc="include">
  <name>Subclause</name>
  </section>
  </section>
  </middle>
  </rfc>
INPUT
      expect {IsoDoc::Ietf::RfcConvert.new({}).postprocess(rfc, "test.rfc.xml", nil)}.not_to output(%r{RFC XML: <link rel='convertedFrom'> \(:derived-from: document attribute\) must start with https://datatracker.ietf.org/doc/draft-}).to_stderr
      expect {IsoDoc::Ietf::RfcConvert.new({}).postprocess(rfc, "test.rfc.xml", nil)}.not_to output(%r{Mismatch between <rfc number='draft-camelot-holy-grenade-01'> \(:docnumber: NUMBER\) and <seriesInfo name='RFC' value='draft-camelot-holy-grenade-02'> \(:intended-series: TYPE NUMBER\)}).to_stderr
      expect {IsoDoc::Ietf::RfcConvert.new({}).postprocess(rfc, "test.rfc.xml", nil)}.not_to output(%r{RFC XML: RFC identifier <rfc number='draft-camelot-holy-grenade-01'> \(:docnumber: NUMBER\) must be a number}).to_stderr
      expect {IsoDoc::Ietf::RfcConvert.new({}).postprocess(rfc, "test.rfc.xml", nil)}.not_to output(%r{Missing ipr attribute on <rfc> element \(:ipr:\)}).to_stderr
      expect {IsoDoc::Ietf::RfcConvert.new({}).postprocess(rfc, "test.rfc.xml", nil)}.not_to output(%r{RFC XML: Unknown ipr attribute on <rfc> element \(:ipr:\): trust200902}).to_stderr
  end

 it "does not reports non-error on metadata, 2" do
      rfc = <<~INPUT
    <rfc xmlns:xi="http://www.w3.org/2001/XInclude" number="11" ipr="trust200902" category="info" sortRefs="true" tocInclude="true" submissionType="independent" xml:lang="en" version="3" >
  <front>
    <title abbrev="Hand Grenade of Antioch">The Holy Hand Grenade of Antioch</title>
    <seriesInfo value="11" status="Informational" stream="independent" name="RFC" asciiName="RFC"></seriesInfo>
    <seriesInfo name="" value="" status="informational"></seriesInfo>
    <author fullname="Arthur son of Uther Pendragon">
      <address>
        <postal></postal>
        <email>arthur.pendragon@ribose.com</email>
        <uri></uri>
      </address>
    </author>
    <area>General</area>
    <area>Operations and Management</area>
    <abstract anchor="_absttacr">
<t anchor="_2cf15089-1c6a-4156-a904-94376faa6cd1">Abc
Def</t>
</abstract>
  </front>
  <link rel="convertedFrom">https://datatracker.ietf.org/doc/draft-1</link>
  <middle>
  <section anchor="A" numbered="true" toc="exclude">
  <name>Clause</name>
  <section numbered="true" toc="include">
  <name>Subclause</name>
  </section>
  </section>
  </middle>
  </rfc>
INPUT
      expect {IsoDoc::Ietf::RfcConvert.new({}).postprocess(rfc, "test.rfc.xml", nil)}.not_to output(%r{RFC XML: <link rel='convertedFrom'> \(:derived-from: document attribute\) must start with https://datatracker.ietf.org/doc/draft-}).to_stderr
      expect {IsoDoc::Ietf::RfcConvert.new({}).postprocess(rfc, "test.rfc.xml", nil)}.not_to output(%r{Mismatch between <rfc number='11'> \(:docnumber: NUMBER\) and <seriesInfo name='RFC' value='11'> \(:intended-series: TYPE NUMBER\)}).to_stderr
      expect {IsoDoc::Ietf::RfcConvert.new({}).postprocess(rfc, "test.rfc.xml", nil)}.not_to output(%r{RFC XML: RFC identifier <rfc number='11'> \(:docnumber: NUMBER\) must be a number}).to_stderr
  end

 it "does not reports non-error on metadata, 3" do
      rfc = <<~INPUT
    <rfc xmlns:xi="http://www.w3.org/2001/XInclude" docName="draft-camelot-holy-grenade-01" ipr="trust200902" category="info" sortRefs="true" tocInclude="true" submissionType="independent" xml:lang="en" version="3" >
  <front>
    <title abbrev="Hand Grenade of Antioch">The Holy Hand Grenade of Antioch</title>
    <seriesInfo value="draft-camelot-holy-grenade-01" status="Informational" stream="independent" name="Internet-Draft" asciiName="Internet-Draft"></seriesInfo>
    <seriesInfo name="" value="" status="informational"></seriesInfo>
    <author fullname="Arthur son of Uther Pendragon">
      <address>
        <postal></postal>
        <email>arthur.pendragon@ribose.com</email>
        <uri></uri>
      </address>
    </author>
    <area>General</area>
    <area>Operations and Management</area>
    <abstract anchor="_absttacr">
<t anchor="_2cf15089-1c6a-4156-a904-94376faa6cd1">Abc
Def</t>
</abstract>
  </front>
  <link rel="convertedFrom">https://datatracker.ietf.org/doc/draft-1</link>
  <middle>
  <section anchor="A" numbered="true" toc="exclude">
  <name>Clause</name>
  <section numbered="true" toc="include">
  <name>Subclause</name>
  </section>
  </section>
  </middle>
  </rfc>
INPUT
      expect {IsoDoc::Ietf::RfcConvert.new({}).postprocess(rfc, "test.rfc.xml", nil)}.not_to output(%r{Mismatch between <rfc number='draft-camelot-holy-grenade-01'> \(:docnumber: NUMBER\) and <seriesInfo name='Internet-Draft' value='draft-camelot-holy-grenade-02'> \(:intended-series: TYPE NUMBER\)}).to_stderr
      expect {IsoDoc::Ietf::RfcConvert.new({}).postprocess(rfc, "test.rfc.xml", nil)}.not_to output(%r{RFC XML: RFC identifier <rfc number='draft-camelot-holy-grenade-01'> \(:docnumber: NUMBER\) must be a number}).to_stderr
  end

  it "reports missing IPR" do
      rfc = <<~INPUT
    <rfc xmlns:xi="http://www.w3.org/2001/XInclude" docName="draft-camelot-holy-grenade-01" category="info" sortRefs="true" tocInclude="true" submissionType="independent" xml:lang="en" version="3" >
  <front>
    <title abbrev="Hand Grenade of Antioch">The Holy Hand Grenade of Antioch</title>
    <seriesInfo value="draft-camelot-holy-grenade-01" status="Informational" stream="independent" name="Internet-Draft" asciiName="Internet-Draft"></seriesInfo>
    <seriesInfo name="" value="" status="informational"></seriesInfo>
    <author fullname="Arthur son of Uther Pendragon">
      <address>
        <postal></postal>
        <email>arthur.pendragon@ribose.com</email>
        <uri></uri>
      </address>
    </author>
    <area>General</area>
    <area>Operations and Management</area>
    <abstract anchor="_absttacr">
<t anchor="_2cf15089-1c6a-4156-a904-94376faa6cd1">Abc
Def</t>
</abstract>
  </front>
  <link rel="convertedFrom">https://datatracker.ietf.org/doc/draft-1</link>
  <middle>
  <section anchor="A" numbered="true" toc="exclude">
  <name>Clause</name>
  <section numbered="true" toc="include">
  <name>Subclause</name>
  </section>
  </section>
  </middle>
  </rfc>
INPUT
      expect {IsoDoc::Ietf::RfcConvert.new({}).postprocess(rfc, "test.rfc.xml", nil)}.to output(%r{RFC XML: Missing ipr attribute on <rfc> element \(:ipr:\)}).to_stderr
  end

   it "reports unrecognised IPR" do
      rfc = <<~INPUT
    <rfc xmlns:xi="http://www.w3.org/2001/XInclude" docName="draft-camelot-holy-grenade-01" ipr="trust2009021" category="info" sortRefs="true" tocInclude="true" submissionType="independent" xml:lang="en" version="3" >
  <front>
    <title abbrev="Hand Grenade of Antioch">The Holy Hand Grenade of Antioch</title>
    <seriesInfo value="draft-camelot-holy-grenade-01" status="Informational" stream="independent" name="Internet-Draft" asciiName="Internet-Draft"></seriesInfo>
    <seriesInfo name="" value="" status="informational"></seriesInfo>
    <author fullname="Arthur son of Uther Pendragon">
      <address>
        <postal></postal>
        <email>arthur.pendragon@ribose.com</email>
        <uri></uri>
      </address>
    </author>
    <area>General</area>
    <area>Operations and Management</area>
    <abstract anchor="_absttacr">
<t anchor="_2cf15089-1c6a-4156-a904-94376faa6cd1">Abc
Def</t>
</abstract>
  </front>
  <link rel="convertedFrom">https://datatracker.ietf.org/doc/draft-1</link>
  <middle>
  <section anchor="A" numbered="true" toc="exclude">
  <name>Clause</name>
  <section numbered="true" toc="include">
  <name>Subclause</name>
  </section>
  </section>
  </middle>
  </rfc>
INPUT
      expect {IsoDoc::Ietf::RfcConvert.new({}).postprocess(rfc, "test.rfc.xml", nil)}.to output(%r{RFC XML: Unknown ipr attribute on <rfc> element \(:ipr:\): trust2009021}).to_stderr
  end


end
