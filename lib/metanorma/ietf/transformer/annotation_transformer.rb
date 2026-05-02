# frozen_string_literal: true

module Metanorma
  module Ietf
    module Transformer
      module AnnotationTransformer
        private

        def render_annotations?
          ac = doc.annotation_container
          return false unless ac

          pi = ietf_ext.pi
          return true if pi && pi.notedraftinprogress

          # Check document-level annotation rendering flag
          render_flag = ietf_ext.render_document_annotations
          return true if render_flag && render_flag.to_s == "true"

          false
        rescue NoMethodError
          false
        end

        def build_annotations
          return [] unless render_annotations?

          ac = doc.annotation_container
          return [] unless ac

          content = ac.content
          return [] unless content && !content.to_s.strip.empty?

          begin
            doc_fragment = Rfcxml::V3::Rfc.from_xml("<rfc>#{content}</rfc>")
            return []
          rescue StandardError
            return []
          end
        end

        def transform_annotation(annotation)
          cref = Rfcxml::V3::Cref.new

          cref.anchor = to_ncname(annotation.id) if annotation.id

          cref.display = "false"

          ps = annotation.p
          if ps
            ps = [ps] unless ps.is_a?(Array)
            ps.each do |p|
              t = transform_paragraph(p)
              next unless t
              t.anchor = nil
              existing = cref.content
              if existing && !existing.to_s.empty?
                cref.content = "#{existing} #{extract_text_from_t(t)}"
              else
                cref.content = extract_text_from_t(t)
              end
            end
          end

          cref
        end

        def extract_text_from_t(t)
          return "" unless t
          content = t.content
          return content.is_a?(Array) ? content.join : content.to_s if content
          ""
        end
      end
    end
  end
end
