require "nokogiri"
require "jing"

module Asciidoctor
  module Rfc::Common
    module Validate
      class << self
        def validate(doc, filename)
          schema = Jing.new(filename)

          File.write(".tmp.xml", doc.to_xml)

          begin
            errors = schema.validate(".tmp.xml")
          rescue Jing::Error => e
            abort "[metanorma-ietf] Validation error: #{e}"
          end

          if errors.none?
            warn "[metanorma-ietf] Validation passed."
          else
            errors.each do |error|
              warn "[metanorma-ietf] #{error[:message]} @ #{error[:line]}:#{error[:column]}"
            end
          end

        end
      end
    end
  end
end
