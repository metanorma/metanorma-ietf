require "spec_helper"

RSpec.describe Metanorma::Ietf do
  it "processes inline_quoted formatting" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      _Physical noise
      sources_
      *strong*
      `monospace`
      super^script^
      sub~script~
      sub~__scr__ipt~
      stem:[<mml:math xmlns:mml="http://www.w3.org/1998/Math/MathML"><mml:msub xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"> <mml:mrow> <mml:mrow> <mml:mi mathvariant="bold-italic">F</mml:mi> </mml:mrow> </mml:mrow> <mml:mrow> <mml:mrow> <mml:mi mathvariant="bold-italic">&#x391;</mml:mi> </mml:mrow> </mml:mrow> </mml:msub> </mml:math>]
      [alt]#alt#
      [deprecated]#deprecated#
      [domain]#domain#
      [strike]#strike#
      [smallcap]#smallcap#
      [keyword]#keyword#
      [bcp14]#keyword#
    INPUT
    output = <<~OUTPUT
           #{BLANK_HDR}
      <sections>
      <p id='_'>
      <em>Physical noise sources</em>
      <strong>strong</strong>
      <tt>monospace</tt>
      super<sup>script</sup>
      sub<sub>script</sub>
      sub<sub><em>scr</em>ipt</sub>
      <stem type="MathML" block="false"><math xmlns="http://www.w3.org/1998/Math/MathML"><msub> <mrow> <mrow> <mi mathvariant="bold-italic">F</mi> </mrow> </mrow> <mrow> <mrow> <mi mathvariant="bold-italic">Α</mi> </mrow> </mrow> </msub> </math></stem>
      alt deprecated domain strike smallcap keyword
      <bcp14>KEYWORD</bcp14>
      </p>
      </sections>
      </ietf-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes breaks" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      Line break +
      line break

      '''

      <<<
    INPUT
    output = <<~OUTPUT
           #{BLANK_HDR}
      <sections><p id="_">Line break<br/>
      line break</p>
      <hr/>
      <pagebreak/></sections>
      </ietf-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes links" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      mailto:fred@example.com
      http://example.com[]
      http://example.com[Link]
      http://example.com[Link,title="tip"]
    INPUT
    output = <<~OUTPUT
           #{BLANK_HDR}
      <sections>
        <p id="_">mailto:fred@example.com
      <link target="http://example.com"/>
      <link target="http://example.com">Link</link>
      <link target="http://example.com" alt="tip">Link</link></p>
      </sections>
      </ietf-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes bookmarks" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      Text [[bookmark]] Text
    INPUT
    output = <<~OUTPUT
           #{BLANK_HDR}
      <sections>
        <p id="_">Text <bookmark id="bookmark"/> Text</p>
      </sections>
      </ietf-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes crossreferences" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      [[reference]]
      == Section

      Inline Reference to <<reference>>
      Footnoted Reference to <<reference,fn>>
      Inline Reference with Text to <<reference,text>>
      Inline Reference with Format to <<reference,format=counter:xyz>>
      Footnoted Reference with Text to <<reference,fn: text>>
      Anchored Crossreference to other document <<doc.adoc#b>>
      Inline Reference with Anchor to <<doc#fragment,text>>
      Inline Reference with Anchor and format and text to <<doc#fragment,of,text>>
      Inline Reference with Anchor and format and no text to <<doc#fragment,parens,>>
      Inline Reference with Anchor and no format and no text to <<doc#fragment,parens>>

      [[reference]]
      [bibliography]
      == Normative References
      * [[[doc,x]]] Reference
    INPUT
    output = <<~OUTPUT
      #{BLANK_HDR}
               <sections>
          <clause id='reference' inline-header='false' obligation='normative'>
            <title>Section</title>
            <p id='_'>
              Inline Reference to
              <xref target='reference'/>
              Footnoted Reference to
              <xref target='reference'>fn</xref>
              Inline Reference with Text to
              <xref target='reference'>text</xref>
              Inline Reference with Format to
              <xref target='reference' format='counter'>xyz</xref>
              Footnoted Reference with Text to
              <xref target='reference'>text</xref>
              Anchored Crossreference to other document
              <eref type='inline' relative='b' bibitemid='doc' citeas='x'/>
              Inline Reference with Anchor to
              <eref type='inline' relative='fragment' bibitemid='doc' citeas='x'>text</eref>
              Inline Reference with Anchor and format and text to
              <eref type='inline' displayFormat='of' relative='fragment' bibitemid='doc' citeas='x'>text</eref>
              Inline Reference with Anchor and format and no text to
              <eref type='inline' displayFormat='parens' relative='fragment' bibitemid='doc' citeas='x'/>
              Inline Reference with Anchor and no format and no text to
              <eref type='inline' relative='fragment' bibitemid='doc' citeas='x'>parens</eref>
            </p>
          </clause>
        </sections>
        <bibliography>
          <references id='reference' obligation='informative' normative="true">
            <title>Normative References</title>
            <bibitem id='doc'>
              <formattedref format='application/x-isodoc+xml'>Reference</formattedref>
              <docidentifier>x</docidentifier>
            </bibitem>
          </references>
        </bibliography>
      </ietf-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes bibliographic anchors" do
    input = <<~INPUT
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib:

      [bibliography]
      == Normative References

      * [[[ISO712,x]]] Reference
      * [[[ISO713]]] Reference

    INPUT
    output = <<~OUTPUT
           #{BLANK_HDR}
      <sections>

      </sections><bibliography><references id="_" obligation="informative" normative="true">
        <title>Normative References</title>
        <bibitem id="ISO712">
        <formattedref format="application/x-isodoc+xml">Reference</formattedref>
        <docidentifier>x</docidentifier>
      </bibitem>
        <bibitem id="ISO713">
        <formattedref format="application/x-isodoc+xml">Reference</formattedref>
        <docidentifier>ISO713</docidentifier>
        <docnumber>713</docnumber>
      </bibitem>
      </references>
      </bibliography>
      </ietf-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes footnotes" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      Hello!footnote:[Footnote text]

      == Title footnote:[Footnote text 2]
    INPUT
    output = <<~OUTPUT
           #{BLANK_HDR}
             <preface><foreword id="_" obligation="informative">
        <title>Foreword</title>
        <p id="_">Hello!<fn reference="1">
        <p id="_">Footnote text</p>
      </fn></p>
      </foreword></preface><sections>
      <clause id="_" inline-header="false" obligation="normative">
        <title>Title<fn reference="2">
        <p id="_">Footnote text 2</p>
      </fn></title>
      </clause></sections>
      </ietf-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes index terms" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      ((primary:See)) Index ((_term_)) and(((primary:A~B~, stem:[alpha], &#x2c80;))).
    INPUT
    output = <<~OUTPUT
         #{BLANK_HDR}
        <sections>
            <p id="_">See<index primary="true"><primary>See</primary></index> 
            Index <em>term</em><index><primary><em>term</em></primary></index> 
            and<index primary="true"><primary>A<sub>B</sub></primary>
            <secondary><stem type="MathML" block="false"><math xmlns="http://www.w3.org/1998/Math/MathML"><mstyle displaystyle="false"><mi>α</mi></mstyle></math><asciimath>alpha</asciimath></stem></secondary>
            <tertiary>Ⲁ</tertiary></index>.</p>
        </sections>
      </ietf-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Xml::C14n.format(output)
  end
end
