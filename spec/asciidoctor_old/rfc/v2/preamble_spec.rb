require "spec_helper"
RSpec.describe Asciidoctor::Rfc::V2::Converter do
  it "renders no abstract if preamble has no content" do
    expect(Asciidoctor.convert(<<~"INPUT", backend: :rfc2, header_footer: true)).to be_equivalent_to <<~"OUTPUT"
      = Document title
      Author
      :docName:

      == Lorem
      Ipsum.
    INPUT
      #{XML_HDR}

      <rfc
               submissionType="IETF">
      <front>
      <title>Document title</title>
      <author fullname="Author"/>
      <date day="1" month="January" year="2000"/>
      </front><middle>
      <section anchor="_lorem" title="Lorem">
      <t>Ipsum.</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end

  it "renders preamble contents as abstract" do
    expect(Asciidoctor.convert(<<~"INPUT", backend: :rfc2, header_footer: true)).to be_equivalent_to <<~"OUTPUT"
      = Document title
      Author
      :docName:

      Preamble content.

      More Preamble content.

      == Lorem
      Ipsum.
    INPUT
      #{XML_HDR}

      <rfc
               submissionType="IETF">
      <front>
      <title>Document title</title>
      <author fullname="Author"/>
      <date day="1" month="January" year="2000"/>
      <abstract>
      <t>Preamble content.</t>
      <t>More Preamble content.</t>
      </abstract>
      </front><middle>
      <section anchor="_lorem" title="Lorem">
      <t>Ipsum.</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end

  it "renders verse in preamble as abstract" do
    expect(Asciidoctor.convert(<<~"INPUT", backend: :rfc2, header_footer: true)).to be_equivalent_to <<~"OUTPUT"
      = Document title
      Author
      :docName:

      [verse]
      More Preamble content.

      == Lorem
      Ipsum.
    INPUT
      #{XML_HDR}

      <rfc
               submissionType="IETF">
      <front>
      <title>Document title</title>
      <author fullname="Author"/>
      <date day="1" month="January" year="2000"/>
      <abstract>
      <t>More Preamble content.</t>
      </abstract>
      </front><middle>
      <section anchor="_lorem" title="Lorem">
      <t>Ipsum.</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end

  it "renders admonitions in preamble as notes" do
    expect(Asciidoctor.convert(<<~"INPUT", backend: :rfc2, header_footer: true)).to be_equivalent_to <<~"OUTPUT"
      = Document title
      Author
      :docName:

      [NOTE]
      .Title of Note
      ====
      This is another note.
      ====

      == Lorem
      Ipsum.
    INPUT
      #{XML_HDR}

      <rfc
               submissionType="IETF">
      <front>
      <title>Document title</title>
      <author fullname="Author"/>
      <date day="1" month="January" year="2000"/>
      <note title="Title of Note">
      <t>This is another note.</t>
      </note>
      </front><middle>
      <section anchor="_lorem" title="Lorem">
      <t>Ipsum.</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end

  it "renders admonitions in preamble as notes, following an abstract" do
    expect(Asciidoctor.convert(<<~"INPUT", backend: :rfc2, header_footer: true)).to be_equivalent_to <<~"OUTPUT"
      = Document title
      Author
      :docName:

      Abstract

      [NOTE]
      .Title of Note
      ====
      This is another note.
      ====

      == Lorem
      Ipsum.
    INPUT
      #{XML_HDR}

      <rfc
               submissionType="IETF">
      <front>
      <title>Document title</title>
      <author fullname="Author"/>
      <date day="1" month="January" year="2000"/>
      <abstract><t>Abstract</t></abstract>
      <note title="Title of Note">
      <t>This is another note.</t>
      </note>
      </front><middle>
      <section anchor="_lorem" title="Lorem">
      <t>Ipsum.</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end

  it "supplies default titles for notes" do
    expect(Asciidoctor.convert(<<~"INPUT", backend: :rfc2, header_footer: true)).to be_equivalent_to <<~"OUTPUT"
      = Document title
      Author
      :docName:

      NOTE: This is a note.

      [NOTE]
      ====
      This is another note.
      ====

      == Lorem
      Ipsum.
    INPUT
      #{XML_HDR}

      <rfc
               submissionType="IETF">
      <front>
      <title>Document title</title>
      <author fullname="Author"/>
      <date day="1" month="January" year="2000"/>
      <note title="NOTE">
      <t>This is a note.</t>
      </note>
      <note title="NOTE">
      <t>This is another note.</t>
      </note>
      </front><middle>
      <section anchor="_lorem" title="Lorem">
      <t>Ipsum.</t>
      </section>
      </middle>
      </rfc>
    OUTPUT
  end
end
