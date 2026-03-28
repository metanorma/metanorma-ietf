module Relaton
  module Render
    module Ietf
      class Date < ::Relaton::Render::Date
        # do not format months
        def render
          @date
        end
      end
    end
  end
end
