require "asciidoctor" unless defined? Asciidoctor::Converter
require "metanorma"
require_relative "metanorma/ietf"

Metanorma::Ietf.load_backend
Metanorma::Registry.instance.register(Metanorma::Ietf::Processor)
