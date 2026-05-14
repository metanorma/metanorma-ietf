# frozen_string_literal: true

module Metanorma
  module Ietf
    module Transformer
      module RfcV3ToIetf
        # Transforms RFC XML v3 root attributes into Metanorma bibdata.
        module MetadataTransformer
          def build_bibdata
            bibdata = Metanorma::IetfDocument::Metadata::IetfBibliographicItem.new
            set_docnumber(bibdata)
            set_docidentifier(bibdata)
            set_title(bibdata)
            set_language(bibdata)
            set_dates(bibdata)
            set_relations(bibdata)
            set_ext(bibdata)
            bibdata
          end

          private

          def set_docnumber(bibdata)
            number = rfc.number || rfc.doc_name
            bibdata.docnumber = number if number && !number.to_s.empty?
          end

          def set_docidentifier(bibdata)
            ids = []

            if rfc.doc_name && !rfc.doc_name.to_s.empty?
              ids << Metanorma::Document::Relaton::DocumentIdentifier.new(
                id: rfc.doc_name,
                type: "IETF",
              )
            end

            if rfc.number && !rfc.number.to_s.empty?
              ids << Metanorma::Document::Relaton::DocumentIdentifier.new(
                id: "RFC #{rfc.number}",
                type: "IETF",
              )
            end

            bibdata.docidentifier = ids unless ids.empty?
          end

          def set_title(bibdata)
            front = rfc.front
            return unless front && front.title

            title_text = extract_rfc_text(front.title)
            return if title_text.empty?

            titles = []
            titles << Metanorma::Document::Relaton::TypedTitleString.new(
              type: "main",
              content: [title_text],
            )

            if front.title.abbrev && !front.title.abbrev.to_s.empty?
              titles << Metanorma::Document::Relaton::TypedTitleString.new(
                type: "abbrev",
                content: [front.title.abbrev],
              )
            end

            bibdata.title = titles
          end

          def set_language(bibdata)
            lang = rfc.lang
            lang = "en" if lang.nil? || lang.to_s.empty?
            bibdata.language = [Metanorma::Document::Components::DataTypes::Iso639Code.new(value: [lang])]
          end

          def set_dates(bibdata)
            front = rfc.front
            return unless front && front.date

            date = front.date
            on = build_date_on(date)
            return unless on

            bibdata.date = [
              Metanorma::Document::Relaton::BibliographicDate.new(
                type: "published",
                on: on,
              ),
            ]
          end

          def build_date_on(date)
            year = date.year
            return nil unless year && !year.to_s.empty?

            month = date_month_to_num(date.month)
            day = date.day || "01"
            day = day.rjust(2, "0") if day.length == 1
            month = month.rjust(2, "0") if month.length == 1

            Metanorma::Document::Relaton::DateTime.new(content: "#{year}-#{month}-#{day}")
          end

          def date_month_to_num(month)
            return "01" unless month
            months = {
              "January" => "01", "February" => "02", "March" => "03",
              "April" => "04", "May" => "05", "June" => "06",
              "July" => "07", "August" => "08", "September" => "09",
              "October" => "10", "November" => "11", "December" => "12",
            }
            months[month] || month.rjust(2, "0")
          end

          def set_relations(bibdata)
            relations = []

            if rfc.obsoletes && !rfc.obsoletes.to_s.empty?
              rfc.obsoletes.split(", ").each do |ref|
                relations << build_relation("obsoletes", ref.strip)
              end
            end

            if rfc.updates && !rfc.updates.to_s.empty?
              rfc.updates.split(", ").each do |ref|
                relations << build_relation("updates", ref.strip)
              end
            end

            bibdata.relation = relations unless relations.empty?
          end

          def build_relation(type, ref)
            bibitem = Metanorma::Document::Components::BibData::BibliographicItem.new(
              docidentifier: [
                Metanorma::Document::Relaton::DocumentIdentifier.new(
                  id: ref,
                  type: "IETF",
                ),
              ],
            )
            Metanorma::Document::Relaton::DocumentRelation.new(
              type: type,
              bibitem: bibitem,
            )
          end

          def set_ext(bibdata)
            ext = Metanorma::IetfDocument::Metadata::IetfBibDataExtensionType.new

            ext.doctype = determine_doctype
            ext.ipr = rfc.ipr if rfc.ipr && !rfc.ipr.to_s.empty?
            ext.consensus = rfc.consensus if rfc.consensus && !rfc.consensus.to_s.empty?

            submission_type = rfc.submission_type
            ext.submission_type = submission_type if submission_type && !submission_type.to_s.empty?

            front = rfc.front
            if front
              areas = to_array(front.area).map { |a| extract_rfc_text(a) }.compact
              ext.area = areas unless areas.empty?

              workgroups = to_array(front.workgroup).map { |w| extract_rfc_text(w) }.compact
              unless workgroups.empty?
                eg = Metanorma::IetfDocument::Metadata::IetfEditorialGroup.new(workgroup: workgroups)
                ext.editorial_group = eg
              end
            end

            if rfc.category && !rfc.category.to_s.empty?
              series = Metanorma::Document::Relaton::SeriesType.new(
                type: "intended",
                title: Metanorma::Document::Relaton::TypedTitleString.new(
                  type: "intended",
                  content: [rfc.category.to_s],
                ),
              )
              bibdata.series = [series]
            end

            pi = build_pi_settings
            ext.pi = pi if pi

            bibdata.ext = ext
          end

          def determine_doctype
            doc_name = rfc.doc_name
            if doc_name && doc_name.to_s.start_with?("draft-")
              "internet-draft"
            elsif rfc.number && !rfc.number.to_s.empty?
              "rfc"
            else
              "internet-draft"
            end
          end

          def build_pi_settings
            pairs = {}
            pairs["toc"] = rfc.toc_include if rfc.toc_include && !rfc.toc_include.to_s.empty?
            pairs["tocdepth"] = rfc.toc_depth if rfc.toc_depth && !rfc.toc_depth.to_s.empty?
            pairs["symrefs"] = rfc.sym_refs if rfc.sym_refs && !rfc.sym_refs.to_s.empty?
            pairs["sortrefs"] = rfc.sort_refs if rfc.sort_refs && !rfc.sort_refs.to_s.empty?

            return nil if pairs.empty?

            Metanorma::IetfDocument::Metadata::PiSettings.new(
              toc: pairs["toc"],
              tocdepth: pairs["tocdepth"],
              symrefs: pairs["symrefs"],
              sortrefs: pairs["sortrefs"],
            )
          end
        end
      end
    end
  end
end
