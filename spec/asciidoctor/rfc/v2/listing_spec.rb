require "spec_helper"
RSpec.describe Asciidoctor::Rfc::V2::Converter do
  it "renders a listing block with source attribute, ignoring listing content" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
      [[literal-id]]
      .filename.rb
      [source,ruby,src=http://example.com/ruby.rb,alt=Alt Text]
      ----
      def listing(node)
        result = []
        result << "<figure>" if node.parent.context != :example
      end
      ----
    INPUT
      <figure anchor="literal-id">
        <artwork name="filename.rb" type="ruby" src="http://example.com/ruby.rb" alt="Alt Text"><![CDATA[]]></artwork>
      </figure>
    OUTPUT
  end

  it "renders a listing block within an example" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
      [#id]
      ====
      [[literal-id]]
      .filename.rb
      [source,ruby,src=http://example.com/ruby.rb,alt=Alt Text]
      ----
      def listing(node)
        result = []
        result << "<figure>" if node.parent.context != :example
      end
      ----
      ====
    INPUT
      <figure anchor="id" alt="">
        <artwork name="filename.rb" type="ruby" src="http://example.com/ruby.rb" alt="Alt Text"><![CDATA[]]></artwork>
      </figure>
    OUTPUT
  end

  it "renders a listing block without source attribute" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
      [[literal-id]]
      .filename.rb
      [source,ruby]
      ----
      def listing(node)
        result = []
        result << "<figure>" if node.parent.context != :example
      end
      ----
    INPUT
      <figure anchor="literal-id">
      <artwork name="filename.rb" type="ruby" alt=""><![CDATA[
      def listing(node)
        result = []
        result << "<figure>" if node.parent.context != :example
      end
      ]]></artwork>
      </figure>
    OUTPUT
  end

  it "renders a listing paragraph" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc2)).to be_equivalent_to <<~'OUTPUT'
      [listing]
      This is an example of a paragraph styled with `listing`.
      Notice that the monospace markup is preserved in the output.
    INPUT
      <figure>
      <artwork alt=""><![CDATA[
      This is an example of a paragraph styled with `listing`.
      Notice that the monospace markup is preserved in the output.
      ]]></artwork>
      </figure>
    OUTPUT
  end
end
