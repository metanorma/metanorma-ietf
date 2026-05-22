require_relative "ietf/processor"
require_relative "ietf/version"

module Metanorma
  module Ietf
    autoload :Transformer, "metanorma/ietf/transformer"

    RFC2629DTD_URL = "https://raw.githubusercontent.com/metanorma/metanorma-ietf/master/rfc2629.dtd"
  end
end
