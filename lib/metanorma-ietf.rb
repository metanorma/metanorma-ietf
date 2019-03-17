require "asciidoctor" unless defined? Asciidoctor::Converter
require "metanorma"
require_relative "metanorma/ietf"
require_relative "isodoc/rfc_xml_converter"

Metanorma::Ietf.load_backend
Metanorma::Registry.instance.register(Metanorma::Ietf::Processor)
