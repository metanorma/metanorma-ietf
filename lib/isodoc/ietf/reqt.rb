module IsoDoc::Ietf
  class RfcConvert < ::IsoDoc::Convert
    def recommendation_name(node, out, type)
      label, title, lbl = recommendation_labels(node)
      out.t **{ keepWithNext: "true" }  do |b|
        b << (lbl.nil? ? l10n("#{type}:") : l10n("#{type} #{lbl}:"))
      end
      if label || title
        out.t **{ keepWithNext: "true" }  do |b|
          label and label.children.each { |n| parse(n,b) }
          b << "#{clausedelim} " if label && title
          title and title.children.each { |n| parse(n,b) }
        end
      end
    end

    def recommendation_attributes(node, out)
      ret = recommendation_attributes1(node)
      return if ret.empty?
      out.ul do |p|
        ret.each do |l|
          p.li do |i|
            i.em { |e| i << l }
          end
        end
      end
    end

    def recommendation_parse(node, out)
      recommendation_name(node, out, @recommendation_lbl)
      recommendation_attributes(node, out)
      node.children.each do |n|
        parse(n, out) unless %w(label title).include? n.name
      end
    end

    def requirement_parse(node, out)
      recommendation_name(node, out, @requirement_lbl)
      recommendation_attributes(node, out)
      node.children.each do |n|
        parse(n, out) unless %w(label title).include? n.name
      end
    end

    def permission_parse(node, out)
      recommendation_name(node, out, @permission_lbl)
      recommendation_attributes(node, out)
      node.children.each do |n|
        parse(n, out) unless %w(label title).include? n.name
      end
    end

    def requirement_component_parse(node, out)
      return if node["exclude"] == "true"
        node.children.each do |n|
          parse(n, out)
        end
    end
  end
end

