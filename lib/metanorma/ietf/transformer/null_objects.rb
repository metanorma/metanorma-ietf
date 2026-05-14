# frozen_string_literal: true

module Metanorma
  module Ietf
    module Transformer
      # Explicit null object for missing bibdata.
      # Defines exactly the interface the transformer expects,
      # so typos raise NoMethodError instead of silently returning nil.
      class NullBibdata
        def doctype; nil end
        def docnumber; nil end
        def title; nil end
        def language; nil end
        def docidentifier; nil end
        def ext; NullExt.new end
        def contributor; nil end
        def date; nil end
        def abstract; nil end
        def keyword; nil end
        def relation; nil end
        def series; nil end
        def source; nil end
        def version; nil end
        def status; nil end
      end

      # Explicit null object for missing bibdata ext.
      class NullExt
        def doctype; nil end
        def submission_type; nil end
        def ipr; nil end
        def consensus; nil end
        def area; nil end
        def editorial_group; nil end
        def pi; nil end
        def flavor; nil end
      end
    end
  end
end
