require "relaton-render"
require_relative "parse"
require_relative "template"
require_relative "fields"

module Relaton
  module Render
    module Ietf
      class General < ::Relaton::Render::IsoDoc::General
        def config_loc
          YAML.load_file(File.join(File.dirname(__FILE__), "config.yml"))
        end

        def klass_initialize(_options)
          super
          @parseklass = Relaton::Render::Ietf::Parse
          @nametemplateklass = Relaton::Render::Ietf::Template::Name
          @fieldsklass = Relaton::Render::Ietf::Fields
        end
      end
    end
  end
end
