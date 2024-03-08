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
        def dateformat(date, _hash, _type)
          date.nil? and return nil
          date_range(date)
        end

        def compound_fields_format(hash)
          ret = super
          ret[:included]&.each do |h|
            compound_fields_format(h)
          end
          ret
        end
      end
    end
  end
end
