require "isodoc"
require_relative "i18n"

module IsoDoc
  module Ietf
    module Init
      def i18n_init(lang, script, i18nyaml = nil)
        @i18n = I18n.new(lang, script, i18nyaml || @i18nyaml)
      end

      def fileloc(loc)
        File.join(File.dirname(__FILE__), loc)
      end
    end
  end
end
