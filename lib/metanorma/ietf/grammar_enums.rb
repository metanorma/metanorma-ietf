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
    "artwork" => {
      "align" => ["center", "left", "right"],
    },
    "cref" => {
      "display" => ["false", "true"],
    },
    "dl" => {
      "newline" => ["false", "true"],
      "spacing" => ["compact", "normal"],
    },
    "eref" => {
      "brackets" => ["angle", "none"],
    },
    "figure" => {
      "align" => ["center", "left", "right"],
      "suppress-title" => ["false", "true"],
    },
    "iref" => {
      "primary" => ["false", "true"],
    },
    "note" => {
      "removeInRFC" => ["false", "true"],
    },
    "ol" => {
      "indent" => ["adaptive"],
      "spacing" => ["compact", "normal"],
    },
    "organization" => {
      "showOnFrontPage" => ["false", "true"],
    },
    "reference" => {
      "quote-title" => ["false", "true"],
      "quoteTitle" => ["false", "true"],
    },
    "relref" => {
      "displayFormat" => ["bare", "comma", "of", "parens"],
    },
    "rfc" => {
      "category" => ["bcp", "exp", "historic", "info", "std"],
      "consensus" => ["false", "no", "true", "yes"],
      "indexInclude" => ["false", "true"],
      "sortRefs" => ["false", "true"],
      "submissionType" => ["IAB", "IETF", "IRTF", "editorial", "independent"],
      "symRefs" => ["false", "true"],
      "tocInclude" => ["false", "true"],
    },
    "section" => {
      "numbered" => ["false", "true"],
      "removeInRFC" => ["false", "true"],
      "toc" => ["default", "exclude", "include"],
    },
    "seriesInfo" => {
      "stream" => ["IAB", "IETF", "IRTF", "editorial", "independent"],
    },
    "sourcecode" => {
      "markers" => ["false", "true"],
    },
    "spanx" => {
      "xml:space" => ["default", "preserve"],
    },
    "t" => {
      "keepWithNext" => ["false", "true"],
      "keepWithPrevious" => ["false", "true"],
    },
    "table" => {
      "align" => ["center", "left", "right"],
    },
    "td" => {
      "align" => ["center", "left", "right"],
    },
    "texttable" => {
      "align" => ["center", "left", "right"],
      "style" => ["all", "full", "headers", "none"],
      "suppress-title" => ["false", "true"],
    },
    "th" => {
      "align" => ["center", "left", "right"],
    },
    "ttcol" => {
      "align" => ["center", "left", "right"],
    },
    "ul" => {
      "bare" => ["false", "true"],
      "empty" => ["false", "true"],
      "spacing" => ["compact", "normal"],
    },
    "xref" => {
      "format" => ["counter", "default", "none", "title"],
      "pageno" => ["false", "true"],
      "sectionFormat" => ["bare", "comma", "of", "parens"],
    },
      }.freeze
    end
  end
end
