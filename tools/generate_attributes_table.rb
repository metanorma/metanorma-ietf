# frozen_string_literal: true

# Regenerates lib/metanorma/ietf/grammar_enums.rb from the bundled
# grammar (lib/metanorma/ietf/schema/v3.rng): every element attribute
# whose grammar definition carries an explicit choice of values. The
# grammar is the SSOT for the value enums (kept in sync with xml2rfc's
# by the guards:schema_sync CI job); this table is the interface the
# rest of the flavor reads them through.
#
#   rake attributes:generate

require "nokogiri"

module Metanorma
  module Ietf
    module Tools
      module GenerateAttributesTable
        GRAMMAR = File.join(__dir__, "..", "lib", "metanorma", "ietf",
                            "schema", "v3.rng")
        OUT = File.join(__dir__, "..", "lib", "metanorma", "ietf",
                        "grammar_enums.rb")

        module_function

        def run
          doc = Nokogiri::XML(File.read(GRAMMAR))
          enums = {}
          doc.xpath("//gg:define", "gg" => "http://relaxng.org/ns/structure/1.0")
            .each do |define|
            elem = define.at_xpath("./gg:element", "gg" => "http://relaxng.org/ns/structure/1.0")
            elem_name = elem&.[]("name") or next
            elem.xpath(".//gg:attribute", "gg" => "http://relaxng.org/ns/structure/1.0")
              .each do |attr|
              attr_name = attr["name"] or next
              values = attr.xpath(".//gg:choice/gg:value",
                                  "gg" => "http://relaxng.org/ns/structure/1.0")
                .map(&:text)
              next if values.empty?
              (enums[elem_name] ||= {})[attr_name] = values.sort
            end
          end
          File.write(OUT, render(enums))
          puts "grammar_enums.rb: #{enums.sum { |_, v| v.size }} enums " \
               "from #{GRAMMAR}"
        end

        def render(enums)
          body = enums.sort.map do |elem, attrs|
            lines = attrs.sort.map do |attr, values|
              vals = values.map { |v| v.inspect }.join(", ")
              "      #{attr.inspect} => [#{vals}],"
            end
            "    #{elem.inspect} => {\n#{lines.join("\n")}\n    },"
          end.join("\n")
          <<~RUBY
            # frozen_string_literal: true

            # GENERATED FILE: rendered from the bundled RFC XML grammar
            # (lib/metanorma/ietf/schema/v3.rng) by
            # `rake attributes:generate`; do not edit. Every element
            # attribute whose grammar definition carries an explicit
            # choice of values. The grammar is kept in sync with
            # xml2rfc's by the guards:schema_sync CI job.
            module Metanorma
              module Ietf
                module GrammarEnums
                  ENUMS = {
            #{body}
                  }.freeze
                end
              end
            end
          RUBY
        end
      end
    end
  end
end

Metanorma::Ietf::Tools::GenerateAttributesTable.run if $PROGRAM_NAME == __FILE__
