module IsoDoc
  module Ietf
    class RfcConvert < ::IsoDoc::Convert
      def recommendation_labels(node)
        [node.at(ns("./label")), node.at(ns("./title")),
         @xrefs.anchor(node["id"], :label, false)]
      end

      def recommendation_name(node, out, type)
        label, title, lbl = recommendation_labels(node)
        out.t **{ keepWithNext: "true" } do |b|
          b << (lbl.nil? ? l10n("#{type}:") : l10n("#{type} #{lbl}:"))
        end
        if label || title
          out.t **{ keepWithNext: "true" }  do |b|
            label and label.children.each { |n| parse(n, b) }
            b << "#{clausedelim} " if label && title
            title and title.children.each { |n| parse(n, b) }
          end
        end
      end

      def recommendation_attributes(node, out)
        ret = recommendation_attributes1(node)
        return if ret.empty?

        out.ul do |p|
          ret.each do |l|
            p.li do |i|
              i.em { |_e| i << l }
            end
          end
        end
      end

      def recommendation_parse(node, out)
        recommendation_name(node, out, @i18n.recommendation)
        recommendation_attributes(node, out)
        node.children.each do |n|
          parse(n, out) unless %w(label title).include? n.name
        end
      end

      def requirement_parse(node, out)
        recommendation_name(node, out, @i18n.requirement)
        recommendation_attributes(node, out)
        node.children.each do |n|
          parse(n, out) unless %w(label title).include? n.name
        end
      end

      def permission_parse(node, out)
        recommendation_name(node, out, @i18n.permission)
        recommendation_attributes(node, out)
        node.children.each do |n|
          parse(n, out) unless %w(label title).include? n.name
        end
      end

      def inline?(node)
        return true if node.first_element_child.nil?

        %w(em link eref xref strong tt sup sub strike keyword smallcap
           br hr bookmark pagebreak stem origin term preferred admitted
           deprecates domain termsource modification)
          .include? node.first_element_child.name
      end

      def requirement_component_parse(node, out)
        return if node["exclude"] == "true"

        if inline?(node)
          out.t do |p|
            p << "INHERIT: " if node.name == "inherit"
            node.children.each { |n| parse(n, p) }
          end
        else
          node.children.each { |n| parse(n, out) }
        end
      end
    end
  end
end
