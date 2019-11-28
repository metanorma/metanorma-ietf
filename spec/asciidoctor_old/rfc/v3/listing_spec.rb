require "spec_helper"
RSpec.describe Asciidoctor::Rfc::V3::Converter do
  it "renders a listing block with source attribute, ignoring listing content" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      [[literal-id]]
      .filename.rb
      [source,ruby,src=http://example.com/ruby.rb]
      ----
      def listing(node)
        result = []
        result << "<figure>" if node.parent.context != :example
      end
      ----
    INPUT
      <figure>
      <sourcecode anchor="literal-id" name="filename.rb" type="ruby" src="http://example.com/ruby.rb"><![CDATA[]]></sourcecode>
      </figure>
    OUTPUT
  end

  it "renders a listing block within an example" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      [#id]
      ====
      [[literal-id]]
      .filename.rb
      [source,ruby]
      ----
      def listing(node)
        result = []
        result << "<figure>" if node.parent.context != :example
      end
      ----
      ====
    INPUT
      <figure anchor="id">
      <sourcecode anchor="literal-id" name="filename.rb" type="ruby"><![CDATA[
      def listing(node)
        result = []
        result << "<figure>" if node.parent.context != :example
      end
      ]]></sourcecode>
      </figure>
    OUTPUT
  end

  it "renders a listing block without source attribute" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
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
      <figure>
      <sourcecode anchor="literal-id" name="filename.rb" type="ruby"><![CDATA[
      def listing(node)
        result = []
        result << "<figure>" if node.parent.context != :example
      end
      ]]></sourcecode>
      </figure>
    OUTPUT
  end

  it "renders a listing paragraph" do
    expect(Asciidoctor.convert(<<~'INPUT', backend: :rfc3)).to be_equivalent_to <<~'OUTPUT'
      [listing]
      This is an example of a paragraph styled with `listing`.
      Notice that the monospace markup is preserved in the output.
    INPUT
      <figure>
      <sourcecode><![CDATA[
      This is an example of a paragraph styled with `listing`.
      Notice that the monospace markup is preserved in the output.
      ]]></sourcecode>
      </figure>
    OUTPUT
  end
end
