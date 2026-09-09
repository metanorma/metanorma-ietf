# frozen_string_literal: true

require "metanorma/iso/html"

module Metanorma
  module Ietf
    # HTML format slice for the flavor: the renderer, registered with
    # the harness from ietf/document.rb. Renders iso-style; the IETF
    # root uses the IETF sections plus shared standoc classes.
    module Html
      autoload :Renderer, "#{__dir__}/html/renderer"
    end
  end
end
