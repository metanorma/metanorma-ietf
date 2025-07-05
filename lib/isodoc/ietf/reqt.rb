module IsoDoc
  module Ietf
    class RfcConvert < ::IsoDoc::Convert
      def recommendation_name(node, out)
        out.t **{ keepWithNext: "true" } do |p|
          node.children&.each { |n| parse(n, p) }
        end
      end

      def recommendation_parse(node, out)
        recommendation_parse1(node, out)
      end

      def recommendation_parse1(node, out)
        recommendation_name(node.at(ns("./fmt-name")), out)
        node.children.each do |n|
          parse(n, out) if %w(name fmt-provision).include?(n.name)
        end
      end

      def requirement_parse(node, out)
        recommendation_parse1(node, out)
      end

      def permission_parse(node, out)
        recommendation_parse1(node, out)
      end

      def div_parse(node, out)
        node.children.each do |n|
          parse(n, out)
        end
      end
    end
  end
end
