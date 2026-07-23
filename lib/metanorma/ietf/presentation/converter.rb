# frozen_string_literal: true

require "isodoc"
require "nokogiri"
require "metanorma-utils"
require_relative "../../../relaton/render/general"

module Metanorma
  module Ietf
    module Presentation
      # Enriches Metanorma Semantic XML with exactly the presentation
      # concerns the released lib/isodoc/ietf path exercised implicitly
      # through its IsoDoc::Convert inheritance. See presentation.rb for
      # the scope contract; the released RfcConvert#document_preprocess
      # (metanorma-ietf main) is the normative source of this sequence.
      class Converter
        # The one IETF-specific Xref override the released path carried:
        # termnote numbering (ported verbatim from lib/isodoc/ietf/xref.rb).
        class Xref < ::IsoDoc::Xref
          def termnote_anchor_names(docxml)
            docxml.xpath(ns("//term[descendant::termnote]")).each do |t|
              c = ::IsoDoc::XrefGen::Counter.new
              notes = t.xpath(ns("./termnote"))
              notes.noblank.each do |n|
                idx = notes.size == 1 ? "" : " #{c.increment(n).print}"
                @anchors[n["id"]] =
                  anchor_struct(idx, n, @labels["note_xref"], "note",
                                { container: true })
              end
            end
          end
        end

        def initialize(language: "en", script: "Latn", locale: nil)
          @lang = language
          @script = script
          @locale = locale
        end

        # Semantic XML in, enriched Metanorma XML out. The output must
        # remain parseable by Metanorma::IetfDocument::Root.from_xml.
        def enrich(xml_string)
          docxml = Nokogiri::XML(xml_string, &:huge)
          populate_id(docxml)
          render_orphan_references(docxml)
          stamp_autonums(docxml)
          docxml.to_xml
        end

        # The xml2rfc-unrecoverable numbering: notes/termnotes, formulas
        # and examples have no native RFC XML counterpart, so xml2rfc
        # cannot number them. The shared IsoDoc::Xref machinery computes
        # the numbers once (same semantics as every flavour: a solo note
        # is unnumbered, siblings count up); we stamp its results as
        # autonum attributes, which the metanorma-document models already
        # parse as a standard block attribute. The transformer does no
        # counting of its own. Section/figure/table autonumbering and
        # internal xref text remain xml2rfc's job and are NOT stamped.
        def stamp_autonums(docxml)
          anchors = xref_anchors(docxml)
          ns = { "m" => docxml.root.namespace&.href }.compact
          xpath = if ns.empty?
                    "//note | //termnote | //formula | //example"
                  else
                    "//m:note | //m:termnote | //m:formula | //m:example"
                  end
          docxml.xpath(xpath, ns).each do |elem|
            info = anchors[elem["id"]] or next
            label = info[:label].to_s.strip
            label.empty? and next
            elem["autonum"] = label
          end
        end

        # Ported from RfcConvert#populate_id: user-authored anchors become
        # the effective NCName id (the anchor half of campaign finding N2;
        # supersedes the transformer-side transitional anchor_for shim).
        def populate_id(docxml)
          docxml.xpath("//*[@id]").each do |x|
            x["semx-id"] = x["id"]
            x["anchor"] and x["id"] = to_ncname(x["anchor"])
          end
        end

        # Synthesise a formattedref for any bibitem with neither title nor
        # formattedref (e.g. a transiently failed relaton fetch,
        # metanorma/metanorma-standoc#1216), so downstream reference
        # rendering never emits an empty RFC <front>. Strict parity with
        # the released path's fallback (metanorma-ietf#272, ported at
        # metanorma-ietf@81f7bc1 with a REFACTOR marker pointing here):
        # the docidentifier is the display text. The fuller relaton-render
        # reference rendering is the layer's separate job (bibrenderer),
        # not this orphan shim's.
        def render_orphan_references(docxml)
          ns = { "m" => docxml.root.namespace&.href }.compact
          xpath = ns.empty? ? "//references/bibitem" : "//m:references/m:bibitem"
          docxml.xpath(xpath, ns).each do |bib|
            next if bib_has_title_or_formattedref?(bib, ns)

            synthesize_formattedref(bib, ns)
          end
        end

        # The relaton-render hook the released path used for reference
        # rendering (lib/isodoc/ietf/references.rb) — the layer's broader
        # reference job (campaign findings N3/N9/N10 family) builds on it.
        def bibrenderer
          @bibrenderer ||=
            ::Relaton::Render::Ietf::General
              .new(language: @lang, i18nhash: i18n.get,
                   config: nil)
        end

        private

        # Xref#parse operates on the namespaced document (isodoc's own
        # xpaths bind the xmlns: prefix); parse a fresh copy so the
        # bookkeeping never mutates our tree. Keyed by the post-
        # populate_id effective ids, since enrich runs populate_id first.
        def xref_anchors(docxml)
          xrefs = Xref.new(@lang, @script, presentation_klass, i18n,
                           locale: @locale)
          xrefs.parse(Nokogiri::XML(docxml.to_xml, &:huge))
          xrefs.get
        end

        # A real PresentationXMLConvert instance is the narrowest object
        # satisfying Xref's klass interface (bibrender=, i18n=, doctype=,
        # …) without reimplementing it — the fragility watch-point from
        # the qa-plan lives here, deliberately in one place.
        def presentation_klass
          @presentation_klass ||=
            ::IsoDoc::PresentationXMLConvert
              .new(language: @lang, script: @script)
              .tap { |k| k.i18n = i18n }
        end

        def bib_has_title_or_formattedref?(bib, ns)
          if ns.empty?
            bib.at("./title | ./formattedref")
          else
            bib.at("./m:title | ./m:formattedref", ns)
          end
        end

        def synthesize_formattedref(bib, ns)
          text = docidentifier_text(bib, ns) or return
          node = bib.document.create_element("formattedref")
          node.content = text
          bib.add_child(node)
        end

        def docidentifier_text(bib, ns)
          did = if ns.empty?
                  bib.at("./docidentifier")
                else
                  bib.at("./m:docidentifier", ns)
                end
          did&.text
        end

        def i18n
          @i18n ||= ::IsoDoc::I18n.new(@lang, @script, locale: @locale)
        end

        def to_ncname(ident)
          ret = ident.split("#", 2)
          ret.map { |x| ::Metanorma::Utils.to_ncname(x) }.join("#")
        end
      end
    end
  end
end
