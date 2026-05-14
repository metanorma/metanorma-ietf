# frozen_string_literal: true

module Metanorma
  module Ietf
    module Transformer
      module RfcV3ToIetf
        # Transforms RFC XML v3 term-related sections into Metanorma
        # IsoTermsSection / IsoTerm model objects.
        #
        # RFC XML v3 has no dedicated term vocabulary. Terms appear as
        # regular <section> elements. This transformer heuristically
        # detects term patterns (sections with <dl> children whose
        # <dt> entries serve as term names) and builds Metanorma term
        # objects accordingly.
        module TermTransformer
          private

          def transform_terms_section(section_node)
            return nil unless section_node

            terms_section = Metanorma::IsoDocument::Sections::IsoTermsSection.new(
              id: resolve_id(section_node),
              obligation: "normative",
            )

            title_text = extract_section_title(section_node)
            terms_section.title = build_title_element(title_text) if title_text

            # Paragraphs before terms
            to_array(section_node.t).each do |t_node|
              p = transform_t(t_node)
              terms_section.p = to_array(terms_section.p)
              terms_section.p << p if p
            end

            # Definition lists → terms
            to_array(section_node.dl).each do |dl_node|
              build_terms_from_dl(dl_node, terms_section)
            end

            # Nested sections → more terms or sub-clauses
            to_array(section_node.section).each do |sub|
              clause = transform_section(sub)
              terms_section.clause = to_array(terms_section.clause)
              terms_section.clause << clause if clause
            end

            terms_section
          end

          def build_terms_from_dl(dl_node, terms_section)
            dt_nodes = to_array(dl_node.dt)
            dd_nodes = to_array(dl_node.dd)

            dt_nodes.each_with_index do |dt_node, idx|
              term = build_term_from_dt_dd(dt_node, dd_nodes[idx])
              terms_section.term = to_array(terms_section.term)
              terms_section.term << term if term
            end
          end

          def build_term_from_dt_dd(dt_node, dd_node)
            term_text = extract_rfc_mixed_text(dt_node)
            return nil if term_text.empty?

            term_id = dt_node.anchor ? dt_node.anchor.to_s : generate_id

            term = Metanorma::IsoDocument::Terms::IsoTerm.new(id: term_id)

            # Preferred designation
            designation = build_term_designation(term_text)
            term.preferred = [designation]

            # Domain from dt if present (e.g. "foo (bar)" → domain=bar)
            domain_match = term_text.match(/\(([^)]+)\)\s*$/)
            if domain_match
              domain_text = domain_match[1].strip
              term.domain = Metanorma::IsoDocument::Terms::TermDomainElement.new(
                text: domain_text,
              )
            end

            # Definition from dd
            if dd_node
              build_term_definition_from_dd(dd_node, term)
            end

            term
          end

          def build_term_designation(text)
            clean_text = text.gsub(/\s*\([^)]+\)\s*$/, "").strip

            name = Metanorma::IsoDocument::Terms::TermNameElement.new(
              text: [clean_text],
            )
            expression = Metanorma::IsoDocument::Terms::TermExpression.new(
              name: [name],
            )
            Metanorma::IsoDocument::Terms::TermDesignation.new(
              expression: expression,
            )
          end

          def build_term_definition_from_dd(dd_node, term)
            definition = Metanorma::IsoDocument::Terms::TermDefinition.new

            # Paragraphs in dd → definition paragraphs
            to_array(dd_node.t).each do |t_node|
              p = transform_t(t_node)
              definition.p = to_array(definition.p)
              definition.p << p if p
            end

            # Lists in dd → definition lists
            to_array(dd_node.ol).each do |ol|
              list = transform_ol(ol)
              definition.ol = to_array(definition.ol)
              definition.ol << list if list
            end

            to_array(dd_node.ul).each do |ul|
              list = transform_ul(ul)
              definition.ul = to_array(definition.ul)
              definition.ul << list if list
            end

            term.definition = [definition] unless empty_definition?(definition)
          end

          def empty_definition?(definition)
            empty_collection?(definition.p) &&
              empty_collection?(definition.ol) &&
              empty_collection?(definition.ul)
          end

          def empty_collection?(coll)
            coll.nil? || (coll.is_a?(Array) && coll.empty?)
          end

          def extract_section_title(section_node)
            if section_node.name
              extract_rfc_text(section_node.name)
            else
              nil
            end
          end
        end
      end
    end
  end
end
