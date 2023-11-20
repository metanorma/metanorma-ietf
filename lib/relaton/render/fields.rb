module Relaton
  module Render
    module Ietf
      class Fields < ::Relaton::Render::Fields
        def nameformat(names)
          names.nil? and return names
          parts = %i(surname initials given middle nonpersonal
                     nonpersonalabbrev completename)
          names_out = names.each_with_object({}) do |n, m|
            parts.each do |i|
              m[i] ||= []
              m[i] << n[i]
            end
          end
          @r.nametemplate.render(names_out)
        end

        # do not format months
        def dateformat(date, _hash)
          date.nil? and return nil
          date_range(date)
        end
      end
    end
  end
end