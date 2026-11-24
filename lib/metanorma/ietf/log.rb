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
        # RFC XML emission validation (idnits3 submission-check
        # findings on the Rfcxml model); severity 0 aborts the
        # compile, 2 is an author-content warning
        "IETF_5": { category: "RFC XML stream",
                    error: "Unknown submissionType (stream) on <rfc> " \
                      "element (:submission-type: %s): must be one of %s",
                    severity: 0 },
        "IETF_6": { category: "RFC XML stream",
                    error: "The category of <rfc> (:intended-series: " \
                      "TYPE NUMBER) is invalid for the %s stream: must " \
                      "be one of %s, but is %s",
                    severity: 0 },
        "IETF_7": { category: "RFC XML stream",
                    error: "The stream setting of <front> <seriesInfo> " \
                      "(%s) is inconsistent with the submissionType of " \
                      "<rfc> (%s)",
                    severity: 0 },
        "IETF_8": { category: "RFC XML stream",
                    error: "Expected no consensus setting for the %s " \
                      "stream (:consensus: %s); remove the :consensus: " \
                      "document attribute",
                    severity: 0 },
        "IETF_9": { category: "RFC XML stream",
                    error: "Expected no consensus setting for the IRTF " \
                      "stream with no workgroup (:consensus: %s); " \
                      "declare :workgroup: or remove :consensus:",
                    severity: 0 },
        "IETF_10": { category: "RFC XML stream",
                     error: "The ipr attribute '%s' withholds the right " \
                       "to produce derivative works (RFC 5378, section " \
                       "3.3), so it can't be used in the IETF stream; " \
                       "use ipr='trust200902' (or 'pre5378Trust200902')",
                     severity: 0 },
        "IETF_11": { category: "RFC XML stream",
                     error: "The document name %s implies the %s " \
                       "stream, but the rfc tag declares " \
                       "submissionType='%s' (:submission-type:); align " \
                       "the two",
                     severity: 0 },
        "IETF_12": { category: "RFC XML submission",
                     error: "The abstract section is missing (an " \
                       ":abstract: block or [abstract] section): the " \
                       "IETF submission check requires it",
                     severity: 0 },
        "IETF_13": { category: "RFC XML submission",
                     error: "The abstract section is present but " \
                       "contains no content (idnits3: at least 1 <t>, " \
                       "<ol>, <ul> or <dl> element)",
                     severity: 2 },
        "IETF_14": { category: "RFC XML text output",
                     error: "The <%s> has lines wider than the 72 " \
                       "columns of xml2rfc's text output (widest is " \
                       "%s); xml2rfc will wrap or truncate them",
                     severity: 2 },
        "IETF_15": { category: "RFC XML references",
                     error: "The reference %s is listed in the " \
                       "References section but is not mentioned in the " \
                       "document text",
                     severity: 2 },
        "IETF_16": { category: "RFC XML vocabulary",
                     error: "The %s attribute of <%s> is deprecated " \
                       "(%s=\"%s\"): it must not be emitted",
                     severity: 1 },
        "IETF_17": { category: "RFC XML vocabulary",
                     error: "The <%s> element is deprecated and must " \
                       "not be emitted",
                     severity: 1 },
        "IETF_18": { category: "RFC XML front matter",
                     error: "The <author> is missing its fullname " \
                       "attribute",
                     severity: 2 },
        "IETF_19": { category: "RFC XML front matter",
                     error: "There are more than 5 authors / editors; " \
                       "discuss the need with the relevant stream " \
                       "leadership",
                     severity: 3 },
        "IETF_20": { category: "RFC XML text output",
                     error: "The <%s> contains tab characters, which " \
                       "xml2rfc's text output does not align; use " \
                       "spaces",
                     severity: 2 },
        "IETF_22": { category: "Document Attributes",
                     error: "unknown document attribute :%s: (did you " \
                       "mean :%s:?)",
                     severity: 2 },
        "IETF_23": { category: "RFC XML text output",
                     error: "xml2rfc preptool warning: %s",
                     severity: 2 },
        "IETF_21": { category: "RFC XML submission",
                     error: "The IETF submission check expects the " \
                       "submitted file to be named %s.xml; rename the " \
                       "output file before submitting it",
                     severity: 3 },
      }.freeze
      # rubocop:enable Naming/VariableNumber

      def log_messages
        super.merge(IETF_LOG_MESSAGES)
      end
    end
  end
end
