require "sterile"

module Relaton
  module Render
    module Template
      module Ascii
        def ascii(ret)
          ret.transliterate
        end
      end
    end
  end
end

module Relaton
  module Render
    module Ietf
      module Template
        class Name < ::Relaton::Render::Template::Name
          def create_liquid_environment
            env = super
            env.register_filter(::Relaton::Render::Template::Ascii)
            env
          end
        end
      end
    end
  end
end
