require "asciidoctor" unless defined? Asciidoctor::Converter
require "metanorma"

require_relative "metanorma/ietf"
require_relative "asciidoctor/ietf/converter"

Metanorma::Registry.instance.register(Metanorma::Ietf::Processor)
