# frozen_string_literal: true

module Metanorma
  module Ietf
    module Transformer
      module AnnotationTransformer

        def render_annotations?
          ac = doc.annotation_container
          return false unless ac

          pi = ietf_ext.pi
          return true if pi&.notedraftinprogress

          render_flag = ietf_ext.render_document_annotations
          render_flag && render_flag.to_s == "true"
        end

        def build_annotations
          []
        end
      end
    end
  end
end
