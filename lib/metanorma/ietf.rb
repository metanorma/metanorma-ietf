require_relative "ietf/processor"
require_relative "ietf/version"

module Metanorma
  module Ietf
  	RFC2629DTD_URL = "https://raw.githubusercontent.com/metanorma/metanorma-ietf/master/rfc2629.dtd"
  end
end

# Registry styling: the flavor owns its index theme, registered
# programmatically with the metanorma-document theme system.
begin
  require "metanorma/html"
  Metanorma::Html::Theme.register_themes_dir(
    File.expand_path("ietf/themes", __dir__),
  )
rescue LoadError
  # metanorma-document unavailable; registry styling inert
end
