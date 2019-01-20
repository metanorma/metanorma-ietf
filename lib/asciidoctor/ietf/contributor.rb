module Asciidoctor
  module Ietf
    module Contributor
      def metadata_author(node, xml)
        author ||= find_author(node)

        xml.contributor do |contributor|
          contributor.role **{ type: "author" }
          contributor.person do |person|
            person.name { |name| set_name_data(name, author) }

            person.address { |address| set_address_data(address, author) }
          end
        end
      end

      private

      def author_fields
        @author_fields ||= [
          "lastname", "fullname", "forename_initials",
          "city", "street", "region", "code", "country"
        ]
      end

      def set_name_data(name, values)
        name.initial(values[:forename_initials])
        name.surname(values[:lastname])
        name.completename(values[:fullname])
      end

      def set_address_data(address, values)
        address.street(values[:street])
        address.city(values[:city])
        address.state(values[:region])
        address.country(values[:country])
        address.postcode(values[:code])
      end

      def find_author(node)
        Hash.new.tap do |hash|
          author_fields.each do |field|
            field_value = node.attr(field)
            hash[field.to_sym] = field_value if field_value
          end
        end
      end

      def metadata_copyright(node, xml)
        publishers = node.attr("publisher") || "IETF"
        publishers.split(/,[ ]?/).each do |p|
          xml.copyright do |c|
            c.from (node.attr("copyright-year") || Date.today.year)
            c.owner do |owner|
              owner.organization { |o| organization(o, p) }
            end
          end
        end
      end

    end
  end
end
