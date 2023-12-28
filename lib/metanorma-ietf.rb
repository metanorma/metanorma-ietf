require "asciidoctor" unless defined? Asciidoctor::Converter
require "metanorma"
require "vectory"

require_relative "metanorma/ietf"
require_relative "metanorma/ietf/converter"
require_relative "isodoc/ietf/rfc_convert"

Metanorma::Registry.instance.register(Metanorma::Ietf::Processor)
