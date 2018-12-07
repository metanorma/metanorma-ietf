require "asciidoctor" unless defined? Asciidoctor::Converter
require "metanorma"

require_relative "metanorma/ietf"
require_relative "asciidoctor/rfc"

Metanorma::Registry.instance.register(Metanorma::Ietf::Processor)
