require "asciidoctor"

require_relative "../common/base"
require_relative "../common/front"
require_relative "base"
require_relative "blocks"
require_relative "front"
require_relative "inline_anchor"
require_relative "lists"
require_relative "table"
require_relative "validate"

module Asciidoctor
  module Rfc::V2
    # A {Converter} implementation that generates RFC XML 2 output, a format used to
    # format RFC proposals (https://tools.ietf.org/html/rfc7749)
    #
    # Features drawn from https://github.com/miekg/mmark/wiki/Syntax and
    # https://github.com/riboseinc/rfc2md
    class Converter
      include ::Asciidoctor::Converter
      include ::Asciidoctor::Writer

      include ::Asciidoctor::Rfc::Common::Base
      include ::Asciidoctor::Rfc::Common::Front
      include ::Asciidoctor::Rfc::V2::Base
      include ::Asciidoctor::Rfc::V2::Blocks
      include ::Asciidoctor::Rfc::V2::Front
      include ::Asciidoctor::Rfc::V2::InlineAnchor
      include ::Asciidoctor::Rfc::V2::Lists
      include ::Asciidoctor::Rfc::V2::Table
      include ::Asciidoctor::Rfc::V2::Validate

      register_for "rfc2"

      $seen_back_matter = false
      $xreftext = {}

      def initialize(backend, opts)
        super
        Asciidoctor::Compliance.natural_xrefs = false
        basebackend "html"
        outfilesuffix ".xml"
      end

      # alias_method :pass, :content
      alias_method :embedded, :content
      alias_method :sidebar, :content
      alias_method :audio, :skip
      alias_method :colist, :skip
      alias_method :page_break, :skip
      alias_method :thematic_break, :skip
      alias_method :video, :skip
      alias_method :inline_button, :skip
      alias_method :inline_kbd, :skip
      alias_method :inline_menu, :skip
      alias_method :inline_image, :skip
    end
  end
end
