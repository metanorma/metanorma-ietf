module Relaton
  module Render
    module Ietf
      class Parse < ::Relaton::Render::Parse
        def simple_or_host_xml2hash(doc, host)
          ret = super
          ret.merge(home_standard: home_standard(doc, ret[:publisher_raw]),
                    uris: uris(doc), keywords: keywords(doc),
                    abstract: abstract(doc))
        end

        def home_standard(_doc, pubs)
          pubs&.any? do |r|
            ["Internet Engineering Task Force", "IETF", "RFC Publisher"]
              .include?(r[:nonpersonal])
          end
        end

        # allow publisher for standards
        def creatornames_roles_allowed
          %w(author performer adapter translator editor publisher distributor
             authorizer)
        end

        def series_xml2hash1(series, doc)
          ret = super
          %w(BCP RFC I-D. Internet-Draft).include?(ret[:series_title]) and return {}
          ret
        end

        def uris(doc)
          doc.link.map { |u| { content: u.content.to_s.strip, type: u.type } }
        end

        def keywords(doc)
          doc.keyword.map { |u| content(u) }
        end

        def abstract(doc)
          doc.abstract.join
        end

        def extractname(contributor)
          org = contributor.entity if contributor.entity
            .is_a?(RelatonBib::Organization)
          person = contributor.entity if contributor.entity
            .is_a?(RelatonBib::Person)
          if org
            return { nonpersonal: extract_orgname(org),
                     nonpersonalabbrev: extract_orgabbrev(org) }
          end
          return extract_personname(person) if person

          nil
        end

        def extract_orgabbrev(org)
          content(org.abbreviation)
        end

        def extract_personname(person)
          surname = person.name.surname
          completename = person.name.completename
          given, middle, initials = given_and_middle_name(person)
          { surname: content(surname),
            completename: content(completename),
            given: given,
            middle: middle,
            initials: initials }.compact
        end

        # not just year-only
        def date(doc, host)
          ret = date1(doc.date)
          host and ret ||= date1(host.date)
          datepick(ret)
        end

        # return authors and editors together
        def creatornames1(doc)
          return [] if doc.nil?

          add1 = pick_contributor(doc, "author") || []
          add2 = pick_contributor(doc, "editor") || []
          cr = add1 + add2
          cr.empty? or return cr
          super
        end

        # add BCP number
        def authoritative_identifier(doc)
          ret = super
          if bcp = doc.series.detect { |s| s.title.title.content == "BCP" }
            ret.unshift("BCP #{bcp.number}")
          end
          ret.reject { |x| /^(rfc-anchor|Internet-Draft)/.match? (x) }
        end
      end
    end
  end
end
