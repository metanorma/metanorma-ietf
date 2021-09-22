require "asciidoctor/extensions"

module Asciidoctor
  module Ietf
    class InlineCrefMacro < Asciidoctor::Extensions::InlineMacroProcessor
      use_dsl
      named :cref
      parse_content_as :text
      using_format :short

      def process(parent, _target, attrs)
        out = Asciidoctor::Inline.new(parent, :quoted, attrs["text"]).convert
        %{<crefref>#{out}</crefref>}
      end
    end
  end
end
