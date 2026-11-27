require "tmpdir"
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

  it "accepts every RFC 7991 ipr value (released-parity fix, metanorma-ietf#280)" do
    # the transplanted /trust200902$/ test rejected every capital-T
    # variant and the 200811 family
    %w(pre5378Trust200902 noModificationTrust200902
       noDerivativesTrust200902 trust200811 noModificationTrust200811
       noDerivativesTrust200811 none).each do |ipr|
      rfc = %(<rfc ipr="#{ipr}" category="info" submissionType="IETF"
        docName="draft-x-00" version="3"><front>
        <title>X</title></front><middle/></rfc>)
      expect(content_errors(rfc))
        .not_to match(%r{Unknown ipr attribute})
    end
  end

  # RFC XML emission validation: idnits3 submission-check findings on
  # the Rfcxml model, recorded through the flavor log catalog. The
  # Idnits3 SUBMISSION_TYPE_UNEXPECTED report on metanorma-ietf#348 is
  # the downstream symptom of an unvalidated stream.
  def model_rfc(attrs = {}, front: nil, middle: nil)
    rfc = Rfcxml::V3::Rfc.new
    rfc.submission_type = attrs[:submission_type]
    rfc.category = attrs[:category]
    rfc.ipr = attrs[:ipr]
    rfc.doc_name = attrs[:doc_name]
    rfc.consensus = attrs[:consensus]
    rfc.front = front
    rfc.middle = middle
    rfc
  end

  def model_front(stream: nil, workgroup: false)
    front = Rfcxml::V3::Front.new
    si = Rfcxml::V3::SeriesInfo.new
    si.name = "Internet-Draft"
    si.value = "draft-intesigroup-dlts-14"
    si.stream = stream
    author = Rfcxml::V3::Author.new
    author.fullname = "Author Name"
    abstract = Rfcxml::V3::Abstract.new
    t = Rfcxml::V3::Text.new
    t.content = ["Abstract."]
    abstract.t = [t]
    front.series_info = [si]
    front.author = [author]
    front.abstract = abstract
    front.workgroup = [Rfcxml::V3::Workgroup.new] if workgroup
    front
  end

  def model_section(name: "Introduction")
    section = Rfcxml::V3::Section.new
    n = Rfcxml::V3::Name.new
    n.content = [name]
    section.name = n
    section
  end

  describe "stream validation (model)" do
    let(:validator) { Metanorma::Ietf::RfcValidate.new }

    it "accepts every RFC 7841 stream with a legal category" do
      streams = { "IETF" => "std", "IAB" => "info", "IRTF" => "info",
                  "independent" => "info", "editorial" => "info" }
      streams.each do |stream, category|
        rfc = model_rfc({ submission_type: stream, category: category,
                          ipr: "trust200902" },
                        front: model_front(stream: stream))
        validator.content_validate(rfc)
        validator.content_warnings(rfc)
        expect(validator).not_to be_fatal
        expect(validator).not_to be_entries
      end
    end

    it "aborts a stream outside the RFC 7841 enum with the legal values" do
      rfc = model_rfc({ submission_type: "individual", category: "info",
                        ipr: "trust200902" },
                      front: model_front)
      fatal = validator.content_validate(rfc)
      expect(fatal.join("\n"))
        .to match(/Unknown submissionType \(stream\) on <rfc> element/)
      expect(fatal.join("\n"))
        .to include("IAB, IETF, IRTF, editorial, independent")
    end

    it "aborts a category that the stream does not carry" do
      rfc = model_rfc({ submission_type: "editorial", category: "exp",
                        ipr: "trust200902" },
                      front: model_front(stream: "editorial"))
      expect(validator.content_validate(rfc).join("\n"))
        .to match(/is invalid for the editorial stream: must be one of info, but is exp/)
      rfc = model_rfc({ submission_type: "IAB", category: "std",
                        ipr: "trust200902" },
                      front: model_front(stream: "IAB"))
      expect(validator.content_validate(rfc).join("\n"))
        .to match(/is invalid for the IAB stream: must be one of info, historic, but is std/)
    end

    it "aborts a front seriesInfo stream inconsistent with the rfc stream (preptool 5.4.2.1)" do
      rfc = model_rfc({ submission_type: "independent", category: "info",
                        ipr: "trust200902" },
                      front: model_front(stream: "IETF"))
      expect(validator.content_validate(rfc).join("\n"))
        .to match(/The stream setting of <front> <seriesInfo> \(IETF\) is inconsistent with the submissionType of <rfc> \(independent\)/)
    end

    it "aborts a consensus setting on the independent and editorial streams" do
      %w(independent editorial).each do |stream|
        rfc = model_rfc({ submission_type: stream, category: "info",
                          ipr: "trust200902", consensus: "true" },
                        front: model_front(stream: stream))
        expect(validator.content_validate(rfc).join("\n"))
          .to match(/Expected no consensus setting for the #{stream} stream/)
      end
    end

    it "aborts a consensus setting on the IRTF stream with no workgroup" do
      rfc = model_rfc({ submission_type: "IRTF", category: "info",
                        ipr: "trust200902", consensus: "true" },
                      front: model_front(stream: "IRTF"))
      expect(validator.content_validate(rfc).join("\n"))
        .to match(/Expected no consensus setting for the IRTF stream with no workgroup/)
    end

    it "accepts a consensus setting on the IETF stream" do
      rfc = model_rfc({ submission_type: "IETF", category: "std",
                        ipr: "trust200902", consensus: "true" },
                      front: model_front(stream: "IETF", workgroup: true))
      expect(validator.content_validate(rfc)).to be_empty
    end

    it "aborts a restricted ipr on the IETF stream (RFC 5378 s3.3)" do
      %w(noModificationTrust200902 noDerivativesTrust200902).each do |ipr|
        rfc = model_rfc({ submission_type: "IETF", category: "std",
                          ipr: ipr },
                        front: model_front(stream: "IETF"))
        expect(validator.content_validate(rfc).join("\n"))
          .to match(/withholds the right to produce derivative works/)
      end
      independent = model_rfc({ submission_type: "independent",
                                category: "info", ipr: "trust200811" },
                              front: model_front(stream: "independent"))
      expect(Metanorma::Ietf::RfcValidate.new
        .content_validate(independent)).to be_empty
    end

    it "aborts a draft-iab/draft-irtf name implying a different stream" do
      rfc = model_rfc({ submission_type: "IETF", category: "std",
                        ipr: "trust200902",
                        doc_name: "draft-iab-probe-00" },
                      front: model_front(stream: "IETF"))
      expect(validator.content_validate(rfc).join("\n"))
        .to match(/The document name draft-iab-probe-00 implies the IAB stream/)
    end

    it "aborts a missing abstract and warns on an empty one" do
      no_abstract = model_rfc({ submission_type: "independent",
                                category: "info", ipr: "trust200902" },
                              front: Rfcxml::V3::Front.new)
      expect(validator.content_validate(no_abstract).join("\n"))
        .to match(/The abstract section is missing/)

      empty_front = Rfcxml::V3::Front.new
      empty_front.abstract = Rfcxml::V3::Abstract.new
      rfc = model_rfc({ submission_type: "independent", category: "info",
                        ipr: "trust200902" },
                      front: empty_front)
      fresh = Metanorma::Ietf::RfcValidate.new
      fresh.content_validate(rfc)
      fresh.content_warnings(rfc)
      expect(fresh).not_to be_fatal
      expect(fresh).to be_entries
    end

    it "warns on wide artwork, tabs, uncited references and deprecated emission" do
      wide = Rfcxml::V3::Artwork.new
      wide.content = "x" * 101
      tabbed = Rfcxml::V3::Sourcecode.new
      tabbed.content = ["a\tb"]
      section = model_section
      section.artwork = [wide]
      section.sourcecode = [tabbed]
      middle = Rfcxml::V3::Middle.new
      middle.section = [section]
      back = Rfcxml::V3::Back.new
      refs = Rfcxml::V3::References.new
      ref = Rfcxml::V3::Reference.new
      ref.anchor = "UNCITED"
      refs.reference = [ref]
      back.references = [refs]
      rfc = model_rfc({ submission_type: "independent", category: "info",
                        ipr: "trust200902" },
                      front: model_front(stream: "independent"),
                      middle: middle)
      rfc.back = back
      validator.content_validate(rfc)
      validator.content_warnings(rfc)
      expect(validator).not_to be_fatal
      # Dir.tmpdir, not a literal /tmp: the report write runs on
      # Windows runners too, where /tmp does not exist
      report = validator.write(File.join(Dir.tmpdir, "should-not-write-here"))
      expect(File.read(report))
        .to include("has lines wider than the 72 columns")
        .and include("contains tab characters")
        .and include("is listed in the References section")
      FileUtils.rm_f(report)
    end

    it "logs the submitted-filename hint as info" do
      rfc = model_rfc({ submission_type: "independent", category: "info",
                        ipr: "trust200902",
                        doc_name: "draft-intesigroup-dlts-14" },
                      front: model_front(stream: "independent"))
      validator.content_validate(rfc)
      validator.record_filename_hint(rfc.doc_name)
      expect(validator.entries?).to be true
      report = validator.write(File.join(Dir.tmpdir, "should-not-write-here"))
      expect(File.read(report))
        .to include("expects the submitted file to be named " \
                    "draft-intesigroup-dlts-14.xml")
      FileUtils.rm_f(report)
    end
  end
end
