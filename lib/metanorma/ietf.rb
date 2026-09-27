require_relative "ietf/processor"
require "metanorma/ietf/document"
require_relative "ietf/version"

module Metanorma
  module Ietf
  	RFC2629DTD_URL = "https://raw.githubusercontent.com/metanorma/metanorma-ietf/master/rfc2629.dtd"
  end
end

begin
  require "metanorma/html"

  # Flavor-owned theme dir: tokens + RFC cover template live with the
  # flavor (the render stack resolves templates flavor-first).
  Metanorma::Html::Theme.register_themes_dir(
    File.expand_path("ietf/themes", __dir__),
  )
rescue LoadError
  # The document-render layer is optional for compile-only contexts.
end
