module Relaton
  module Render
    module Ietf
      class Parse < ::Relaton::Render::Parse
        def simple_or_host_xml2hash(doc, host)
          ret = super
          ret.merge(home_standard: home_standard(doc, ret[:publisher_raw]),
                    uris: uris(doc), keywords: keywords(doc), abstract: abstract(doc))
        end

        def home_standard(_doc, pubs)
          pubs&.any? do |r|
            ["Internet Engineering Task Force", "IETF"]
              .include?(r[:nonpersonal])
          end
        end

        # allow publisher for standards
        def creatornames_roles_allowed
          %w(author performer adapter translator editor publisher distributor
             authorizer)
        end

        def uris(doc)
          doc.link.map { |u| { content: u.content.to_s.strip, type: u.type } }
        end

        def keywords(doc)
          doc.keyword.map { |u| u.content }
        end

        def abstract(doc)
          doc.abstract.join
        end
      end
    end
  end
end
