module Metanorma
  module Ietf
    class Converter
      IETF_LOG_MESSAGES = {
        # rubocop:disable Naming/VariableNumber
        "IETF_1": { category: "Crossrefences",
                    error: "No matching annotation for cref:[%s]",
                    severity: 1 },
        "IETF_2": { category: "Document Attributes",
                    error: "Editorial stream must have Informational status",
                    severity: 2 },
        "IETF_3": { category: "Images",
                    error: "image %s is not SVG!",
                    severity: 1 },
        "IETF_4": { category: "Document Attributes",
                    error: "IETF: unrecognised working group %s",
                    severity: 1 },
      }.freeze
      # rubocop:enable Naming/VariableNumber

      def log_messages
        super.merge(IETF_LOG_MESSAGES)
      end
    end
  end
end
