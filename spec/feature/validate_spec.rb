require "spec_helper"

# WS3 port of spec/isodoc/validate_spec.rb. The old examples drove
# the released RfcConvert#postprocess on hand-authored RFC XML and
# asserted validation warnings on stderr; the pipeline's equivalent
# is ValidationTransformer (a transplant of the released content
# rules and messages), whose validate_rfc_xml/content_validate return
# the error strings that convert_forward/the processor emit as
# "RFC XML: ..." warnings. Mappings: the "aborts if content error"
# pair maps to content errors present/absent (moving the output to
# .err and halting is the caller's concern); schema validation uses
# libxml RELAX NG in place of the released Jing, whose messages do
# not name the missing element.
VALIDATE_FRONT = <<~FRONT.freeze
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
FRONT

RSpec.describe "IETF RFC XML validation (WS3)" do
  let(:validator) { Metanorma::Ietf::Transformer::IetfToRfcV3.allocate }

  def content_errors(rfc)
    validator.content_validate(rfc).join("\n")
  end

  it "validates document against the RFC XML schema" do
    # the released path ran Jing, whose message named the missing
    # element ('element "rfc" incomplete; missing required element
    # "middle"'); libxml reports the incompleteness without naming it
    input = <<~INPUT
      <rfc xmlns:xi="http://www.w3.org/2001/XInclude" docName="draft-camelot-holy-grenade-01" category="info" sortRefs="true" tocInclude="true" submissionType="independent" xml:lang="en" version="3">
      #{VALIDATE_FRONT}
      </rfc>
    INPUT
    errors = validator.schema_validate(input)
    expect(errors).not_to be_empty
    expect(errors.join("\n")).to match(/\ALine \d+/)
    expect(errors.join("\n")).to match(/Expecting an element/)
  end

  it "reports content errors (the released path aborted on them)" do
    input = <<~INPUT
      <rfc xmlns:xi="http://www.w3.org/2001/XInclude" docName="draft-camelot-holy-grenade-01" ipr="trust200902" category="info" sortRefs="true" tocInclude="true" submissionType="independent" xml:lang="en" version="3">
      #{VALIDATE_FRONT}
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
    errors = validator.content_validate(input)
    expect(errors).not_to be_empty
    expect(errors.join("\n"))
      .to match(/Numbered section Subclause under unnumbered section Clause/)
  end

  it "reports no content errors on a clean document" do
    input = <<~INPUT
      <rfc xmlns:xi="http://www.w3.org/2001/XInclude" docName="draft-camelot-holy-grenade-01" ipr="trust200902" category="info" sortRefs="true" tocInclude="true" submissionType="independent" xml:lang="en" version="3">
      #{VALIDATE_FRONT}
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
    expect(validator.content_validate(input)).to be_empty
  end

  it "reports error on section numbering" do
    rfc = <<~INPUT
      <rfc xmlns:xi="http://www.w3.org/2001/XInclude" docName="draft-camelot-holy-grenade-01" ipr="trust200902" category="info" sortRefs="true" tocInclude="true" submissionType="independent" xml:lang="en" version="3">
      #{VALIDATE_FRONT}
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
    errors = content_errors(rfc)
    expect(errors)
      .to match(/Numbered section Subclause under unnumbered section Clause/)
    expect(errors)
      .to match(/Numbered section B under unnumbered section Clause/)
    expect(errors)
      .to match(/Numbered section New Clause following unnumbered section Clause/)
    expect(errors)
      .to match(/Numbered section C following unnumbered section Clause/)
  end

  it "reports error on table of content tagging" do
    rfc = <<~INPUT
      <rfc xmlns:xi="http://www.w3.org/2001/XInclude" docName="draft-camelot-holy-grenade-01" ipr="trust200902" category="info" sortRefs="true" tocInclude="true" submissionType="independent" xml:lang="en" version="3">
      #{VALIDATE_FRONT}
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
    expect(content_errors(rfc))
      .to match(/Section Subclause with toc=include is included in section Clause with toc=exclude/)
  end

  it "reports error on references" do
    rfc = <<~INPUT
      <rfc xmlns:xi="http://www.w3.org/2001/XInclude" docName="draft-camelot-holy-grenade-01" ipr="trust200902" category="info" sortRefs="true" tocInclude="true" submissionType="independent" xml:lang="en" version="3">
      #{VALIDATE_FRONT}
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
      <author fullname="S. Bradner"></author>
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
      <author fullname="P. Hoffman"></author>
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
    errors = content_errors(rfc)
    expect(errors)
      .to match(/Cannot generate table of contents entry for B, as it has no title/)
    expect(errors)
      .to match(/Cannot generate table of contents entry for _normative_references, as it has no title/)
    expect(errors)
      .to match(/for reference RFC2119, the seriesInfo with name=RFC has been given no value/)
    expect(errors)
      .not_to match(/for reference RFC7991, the seriesInfo with name=RFC has been given no value/)
  end

  it "reports error on xref and relref" do
    rfc = <<~INPUT
      <rfc xmlns:xi="http://www.w3.org/2001/XInclude" docName="draft-camelot-holy-grenade-01" ipr="trust200902" category="info" sortRefs="true" tocInclude="true" submissionType="independent" xml:lang="en" version="3">
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
      <author fullname="S. Bradner"></author>
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
      <author fullname="P. Hoffman"></author>
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
      <organization abbrev="NIST">National Institute of Standards and Technology</organization>
      </author>
      <date year="2019"></date>
      </front>
      </reference>
      <reference anchor="ACVP1" target="http://www.example.com">
      <front>
      <title>Automatic Cryptographic Validation Protocol</title>
      <author>
      <organization abbrev="NIST">National Institute of Standards and Technology</organization>
      </author>
      <date year="2019"></date>
      </front>
      </reference>
      </references>
      </back>
      </rfc>
    INPUT
    errors = content_errors(rfc)
    expect(errors)
      .to match(/xref target _normative_references1 does not exist in the document/)
    expect(errors)
      .not_to match(/xref target _normative_references does not exist in the document/)
    expect(errors)
      .to match(/relref target RFC21191 does not exist in the document/)
    expect(errors)
      .not_to match(/relref target RFC2119 does not exist in the document/)
    expect(errors)
      .to match(/reference RFC2119 has been referenced by relref with format=title, but the reference has no title/)
    expect(errors)
      .not_to match(/reference RFC7991 has been referenced by relref with format=title, but the reference has no title/)
    expect(errors)
      .to match(%r{<xref format="counter" target="C1"/> with format=counter is only allowed for clauses, tables, figures, list entries, definition terms, paragraphs, bibliographies, and bibliographic entries})
    expect(errors)
      .not_to match(%r{<xref format="counter" target="C"/> with format=counter is only allowed for clauses, tables, figures, list entries, definition terms, paragraphs, bibliographies, and bibliographic entries})
    expect(errors)
      .to match(%r{reference RFC2119 has been referenced by xref <relref format="counter" target="RFC2119"/> with format=counter, which requires a section attribute})
    expect(errors)
      .not_to match(%r{reference RFC7991 has been referenced by xref <relref format="counter" target="RFC7991"/> with format=counter, which requires a section attribute})
    expect(errors)
      .to match(%r{<xref format="counter" target="C4"/> with format=counter refers to an unnumbered list entry})
    expect(errors)
      .not_to match(%r{<xref format="counter" target="C2"/> with format=counter refers to an unnumbered list entry})
    expect(errors)
      .to match(%r{<xref format="title" target="AUTH"/> with format=title cannot reference a <author> element})
    expect(errors)
      .not_to match(%r{<relref format="title" target="RFC2119"/> with format=title cannot reference a <reference> element})
    expect(errors)
      .to match(%r{<relref format="counter" target="RFC2119" relative="A"/> with relative attribute requires a section attribute})
    expect(errors)
      .not_to match(%r{<relref format="counter" target="RFC7991" relative="A" section="3"/> with relative attribute requires a section attribute})
    expect(errors)
      .to match(%r{<xref format="counter" target="C" relative="A"/> has a relative attribute, but C points to a section})
    expect(errors)
      .to match(%r{<xref format="counter" target="C" section="A"/> has a section attribute, but C points to a section})
    expect(errors)
      .not_to match(%r{<relref format="counter" target="RFC7991" relative="A" section="3"/> has a relative attribute, but C points to a reference})
    expect(errors)
      .not_to match(%r{<relref format="counter" target="RFC7991" relative="A" section="3"/> has a section attribute, but C points to a reference})
    expect(errors)
      .to match(%r{<relref format="counter" target="ACVP" section="3"/> must use a relative attribute, since it does not point to a RFC or Internet-Draft reference})
    expect(errors)
      .not_to match(%r{<relref format="counter" target="ACVP" section="3" relative="B"/> must use a relative attribute, since it does not point to a RFC or Internet-Draft reference})
    expect(errors)
      .not_to match(%r{<relref format="counter" target="RFC7991" section="3"/> must use a relative attribute, since it does not point to a RFC or Internet-Draft reference})
    expect(errors)
      .to match(%r{need an explicit target= URL attribute in the reference pointed to by <relref format="counter" target="ACVP" relative="B"/>})
    expect(errors)
      .not_to match(%r{need an explicit target= URL attribute in the reference pointed to by <relref format="counter" target="ACVP1" relative="B"/>})
    expect(errors)
      .not_to match(%r{need an explicit target= URL attribute in the reference pointed to by <relref format="counter" target="RFC2119" relative="A"/>})
  end

  it "reports error on metadata" do
    rfc = <<~INPUT
      <rfc xmlns:xi="http://www.w3.org/2001/XInclude" number="draft-camelot-holy-grenade-01" ipr="trust200902" category="info" sortRefs="true" tocInclude="true" submissionType="independent" xml:lang="en" version="3">
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
    errors = content_errors(rfc)
    expect(errors)
      .to match(%r{<link rel='convertedFrom'> \(:derived-from: document attribute\) must start with https://datatracker.ietf.org/doc/draft-})
    expect(errors)
      .to match(%r{Mismatch between <rfc number='draft-camelot-holy-grenade-01'> \(:docnumber: NUMBER\) and <seriesInfo name='RFC' value='draft-camelot-holy-grenade-02'> \(:intended-series: TYPE NUMBER\)})
    expect(errors)
      .to match(%r{RFC identifier <rfc number='draft-camelot-holy-grenade-01'> \(:docnumber: NUMBER\) must be a number})
  end

  it "does not report non-error on metadata, 1" do
    rfc = <<~INPUT
      <rfc xmlns:xi="http://www.w3.org/2001/XInclude" number="draft-camelot-holy-grenade-01" ipr="none" category="info" sortRefs="true" tocInclude="true" submissionType="independent" xml:lang="en" version="3">
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
    errors = content_errors(rfc)
    expect(errors)
      .not_to match(%r{<link rel='convertedFrom'> \(:derived-from: document attribute\) must start with https://datatracker.ietf.org/doc/draft-})
    expect(errors)
      .not_to match(%r{Mismatch between <rfc number='draft-camelot-holy-grenade-01'> \(:docnumber: NUMBER\)})
    expect(errors)
      .not_to match(%r{RFC identifier <rfc number='draft-camelot-holy-grenade-01'> \(:docnumber: NUMBER\) must be a number})
    expect(errors)
      .not_to match(%r{Missing ipr attribute on <rfc> element \(:ipr:\)})
    expect(errors)
      .not_to match(%r{Unknown ipr attribute on <rfc> element \(:ipr:\): trust200902})
  end

  it "does not report non-error on metadata, 2" do
    rfc = <<~INPUT
      <rfc xmlns:xi="http://www.w3.org/2001/XInclude" number="11" ipr="trust200902" category="info" sortRefs="true" tocInclude="true" submissionType="independent" xml:lang="en" version="3">
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
    errors = content_errors(rfc)
    expect(errors)
      .not_to match(%r{<link rel='convertedFrom'> \(:derived-from: document attribute\) must start with https://datatracker.ietf.org/doc/draft-})
    expect(errors)
      .not_to match(%r{Mismatch between <rfc number='11'> \(:docnumber: NUMBER\) and <seriesInfo name='RFC' value='11'> \(:intended-series: TYPE NUMBER\)})
    expect(errors)
      .not_to match(%r{RFC identifier <rfc number='11'> \(:docnumber: NUMBER\) must be a number})
  end

  it "does not report non-error on metadata, 3" do
    rfc = <<~INPUT
      <rfc xmlns:xi="http://www.w3.org/2001/XInclude" docName="draft-camelot-holy-grenade-01" ipr="trust200902" category="info" sortRefs="true" tocInclude="true" submissionType="independent" xml:lang="en" version="3">
      #{VALIDATE_FRONT}
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
    errors = content_errors(rfc)
    expect(errors)
      .not_to match(%r{Mismatch between <rfc number='draft-camelot-holy-grenade-01'> \(:docnumber: NUMBER\)})
    expect(errors)
      .not_to match(%r{RFC identifier <rfc number='draft-camelot-holy-grenade-01'> \(:docnumber: NUMBER\) must be a number})
  end

  it "reports missing IPR" do
    rfc = <<~INPUT
      <rfc xmlns:xi="http://www.w3.org/2001/XInclude" docName="draft-camelot-holy-grenade-01" category="info" sortRefs="true" tocInclude="true" submissionType="independent" xml:lang="en" version="3">
      #{VALIDATE_FRONT}
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
    expect(content_errors(rfc))
      .to match(%r{Missing ipr attribute on <rfc> element \(:ipr:\)})
  end

  it "reports unrecognised IPR" do
    rfc = <<~INPUT
      <rfc xmlns:xi="http://www.w3.org/2001/XInclude" docName="draft-camelot-holy-grenade-01" ipr="trust2009021" category="info" sortRefs="true" tocInclude="true" submissionType="independent" xml:lang="en" version="3">
      #{VALIDATE_FRONT}
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
    expect(content_errors(rfc))
      .to match(%r{Unknown ipr attribute on <rfc> element \(:ipr:\): trust2009021})
  end
end
