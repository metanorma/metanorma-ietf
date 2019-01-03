require_relative "ietf/processor"
require_relative "ietf/version"

module Metanorma
  module Ietf

    # New / Old Backend library
    #
    # This is temporary, since we are working on a new version and
    # at the sametime we have the old one working, so this method will
    # check for a a specific ENV variable and if exisits then based on
    # that will require the correct library.
    #
    def self.load_backend
      if ENV["DEV_MODE"] == "true"
        require "asciidoctor/ietf"
      else
        require "asciidoctor/rfc"
      end
    end
  end
end
