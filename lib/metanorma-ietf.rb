require "asciidoctor" unless defined? Asciidoctor::Converter
require "metanorma-core"
require "metanorma-standoc"
require "vectory"

require_relative "metanorma/ietf"
require_relative "metanorma/ietf/converter"
require_relative "metanorma/ietf/cleanup"
require_relative "metanorma/ietf/validate"
require_relative "isodoc/ietf/rfc_convert"

Metanorma::Registry.instance.register(Metanorma::Ietf::Processor)
