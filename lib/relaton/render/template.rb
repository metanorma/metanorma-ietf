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
          def customise_liquid
            super
            ::Liquid::Template
              .register_filter(::Relaton::Render::Template::Ascii)
          end
        end
      end
    end
  end
end
