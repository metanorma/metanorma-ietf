# frozen_string_literal: true

module Metanorma
  module Ietf
    # The flavor's document-attribute interface. Asciidoctor downcases
    # attribute names, so the RFC-XML-world spellings and the
    # hyphenated spellings both land in the document attribute set;
    # the alias groups below are the accepted spellings per canonical
    # attribute, and `scan` flags declared attributes that look like a
    # misspelling of one of them. This replaces the raw pipe of
    # hard-coded spellings that silently dropped declarations (#348).
    # The value enums live in GrammarEnums, generated from the bundled
    # grammar; this table is hand-maintained.
    module AttributesTable
      # canonical attribute => every accepted spelling (downcased;
      # the canonical name comes first and is the citation form)
      ALIASES = {
        "submission-type" => %w(submission-type submissiontype),
      }.freeze

      # the flavor-owned attributes the near-miss scan guards; the
      # author-line family (author, firstname, middlename, lastname,
      # authorinitials, email, authorcount, plus their _N siblings)
      # and the RFC 7749 carryovers read as PI settings are known
      # spellings too, and are matched structurally in `scan`
      CANONICAL = (%w[
        abbrev area asciititle author authorcount authorinitials
        background consensus derived-from doctitle docnumber
        firstname intended-series ipr ipr-extract lastname middlename
        show-on-front-page submission-type workgroup
      ] + ALIASES.values.flatten).uniq.sort.freeze

      # every guarded spelling => its canonical citation form
      CANONICAL_BY_SPELLING = CANONICAL.to_h do |s|
        [s, (ALIASES.find { |_, spellings| spellings.include?(s) } || [s]).first]
      end.freeze

      AUTHOR_LINE_RE = /\A(author(?:initials)?|email|firstname|lastname|middlename)(_\d+)?\z/.freeze
      # asciidoctor's own plural forms of the author-line attributes
      ASCIIDOCTOR_INTRINSICS = %w(authors).freeze
      PI_SETTINGS = %w[
        artworkdelimiter artworklines autobreaks background colonspace
        comments compact editing emoticonic footer header inline
        linkmailto notedraftinprogress private refparent rfcedstyle
        slides sort-refs sym-refs text-list-symbols tocappendix
        tocindent tocnarrow tocompact tocdepth toc-include useobject
      ].freeze

      module_function

      # the declared value of a canonical attribute, trying every
      # accepted spelling
      def resolve(node, canonical)
        spelling = (ALIASES[canonical] || [canonical])
          .find { |s| node.attr(s) }
        spelling && node.attr(spelling)
      end

      # declared attribute spellings that look like a misspelling of a
      # guarded canonical, as [declared, canonical] pairs
      def scan(node)
        node.attributes.keys.filter_map do |declared|
          key = declared.downcase
          next if known_spelling?(key)
          spelling = CANONICAL_BY_SPELLING.keys.find do |s|
            distance(key, s) <= NEAR_MISS_RADIUS
          end
          spelling && [declared, CANONICAL_BY_SPELLING[spelling]]
        end.sort
      end

      # the near-miss radius: one edit. A radius of two collides with
      # asciidoctor's intrinsic attributes (doctime vs doctitle) that
      # every document carries
      NEAR_MISS_RADIUS = 1

      def known_spelling?(key)
        CANONICAL.include?(key) || AUTHOR_LINE_RE.match?(key) ||
          PI_SETTINGS.include?(key) || ASCIIDOCTOR_INTRINSICS.include?(key)
      end

      # classic Levenshtein distance, small enough for attribute names
      def distance(a, b)
        row = (0..b.length).to_a
        a.each_char.with_index(1) do |ca, i|
          prev = row[0]
          row[0] = i
          b.each_char.with_index(1) do |cb, j|
            cur = row[j]
            row[j] = [row[j] + 1, row[j - 1] + 1,
                      prev + (ca == cb ? 0 : 1)].min
            prev = cur
          end
        end
        row[-1]
      end
    end
  end
end
