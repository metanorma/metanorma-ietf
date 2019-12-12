require "spec_helper"

RSpec.describe Asciidoctor::Ietf do
  it "processes inline_quoted formatting" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :ietf, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      _Physical noise
      sources_
      *strong*
      `monospace`
      super^script^
      sub~script~
      sub~__scr__ipt~
      stem:[<mml:math><mml:msub xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"> <mml:mrow> <mml:mrow> <mml:mi mathvariant="bold-italic">F</mml:mi> </mml:mrow> </mml:mrow> <mml:mrow> <mml:mrow> <mml:mi mathvariant="bold-italic">&#x391;</mml:mi> </mml:mrow> </mml:mrow> </mml:msub> </mml:math>]
      [alt]#alt#
      [deprecated]#deprecated#
      [domain]#domain#
      [strike]#strike#
      [smallcap]#smallcap#
      [keyword]#keyword#
      [bcp14]#keyword#
    INPUT
            #{BLANK_HDR}
       <sections>
       <p id='_'>
       <em>Physical noise sources</em>
       <strong>strong</strong>
       <tt>monospace</tt>
       super<sup>script</sup>
       sub<sub>script</sub>
       sub<sub><em>scr</em>ipt</sub>
       <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><msub> <mrow> <mrow> <mi mathvariant="bold-italic">F</mi> </mrow> </mrow> <mrow> <mrow> <mi mathvariant="bold-italic">Α</mi> </mrow> </mrow> </msub> </math></stem>
       alt deprecated domain strike smallcap keyword
       <bcp14>keyword</bcp14>
       </p>
       </sections>
       </ietf-standard>
    OUTPUT
  end

  it "processes breaks" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :ietf, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      Line break +
      line break

      '''

      <<<
    INPUT
            #{BLANK_HDR}
       <sections><p id="_">Line break<br/>
       line break</p>
       <hr/>
       <pagebreak/></sections>
       </ietf-standard>
    OUTPUT
  end

  it "processes links" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :ietf, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      mailto:fred@example.com
      http://example.com[]
      http://example.com[Link]
      http://example.com[Link,title="tip"]
    INPUT
            #{BLANK_HDR}
       <sections>
         <p id="_">mailto:fred@example.com
       <link target="http://example.com"/>
       <link target="http://example.com">Link</link>
       <link target="http://example.com" alt="tip">Link</link></p>
       </sections>
       </ietf-standard>
    OUTPUT
  end

    it "processes bookmarks" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :ietf, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      Text [[bookmark]] Text
    INPUT
            #{BLANK_HDR}
       <sections>
         <p id="_">Text <bookmark id="bookmark"/> Text</p>
       </sections>
       </ietf-standard>
    OUTPUT
    end

    it "processes crossreferences" do
      expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :ietf, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      [[reference]]
      == Section

      Inline Reference to <<reference>>
      Footnoted Reference to <<reference,fn>>
      Inline Reference with Text to <<reference,text>>
      Footnoted Reference with Text to <<reference,fn: text>>
      Anchored Crossreference to other document <<a.adoc#b>>
      Inline Reference with Anchor to <<reference#fragment,text>>
      Inline Reference with Anchor and format and text to <<reference#fragment,of,text>>
      Inline Reference with Anchor and format and no text to <<reference#fragment,parens,>>
      Inline Reference with Anchor and no format and no text to <<reference#fragment,parens>>
    INPUT
       #{BLANK_HDR}
        <sections>
         <clause id="reference" inline-header="false" obligation="normative">
         <title>Section</title>
         <p id="_">Inline Reference to <xref target="reference"/>
       Footnoted Reference to <xref target="reference">fn</xref>
       Inline Reference with Text to <xref target="reference">text</xref>
       Footnoted Reference with Text to <xref target="reference">text</xref>
       Anchored Crossreference to other document <xref target="a" relative="b"/>
 Inline Reference with Anchor to 
<xref target='reference' relative='fragment'>text</xref>
 Inline Reference with Anchor and format and text to 
<xref target='reference' displayFormat='of' relative='fragment'>text</xref>
 Inline Reference with Anchor and format and no text to 
<xref target='reference' displayFormat='parens' relative='fragment'/>
 Inline Reference with Anchor and no format and no text to 
<xref target='reference' relative='fragment'>parens</xref>
</p>
       </clause>
       </sections>
       </ietf-standard>
      OUTPUT
    end

    it "processes bibliographic anchors" do
      expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :ietf, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
            #{BLANK_HDR}
       <sections>

       </sections><bibliography><references id="_" obligation="informative">
         <title>Normative References</title>
         <bibitem id="ISO712">
         <formattedref format="application/x-isodoc+xml">Reference</formattedref>
         <docidentifier>x</docidentifier>
       </bibitem>
         <bibitem id="ISO713">
         <formattedref format="application/x-isodoc+xml">Reference</formattedref>
         <docidentifier>ISO713</docidentifier>
       </bibitem>
       </references>
       </bibliography>
       </ietf-standard>
    OUTPUT
  end

  it "processes footnotes" do
      expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :ietf, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      Hello!footnote:[Footnote text]

      == Title footnote:[Footnote text 2]
    INPUT
            #{BLANK_HDR}
              <preface><foreword obligation="informative">
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
  end


end
