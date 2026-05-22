# frozen_string_literal: true

require "lutaml/model"

module Metanorma
  module Ietf
    module Transformer
      # Public API for element order tracking on lutaml-model objects.
      #
      # Constructs Lutaml::Xml::Element entries directly and appends them
      # to the model's public `element_order` accessor. This avoids calling
      # lutaml-model's private `track_order` / `build_order_entry` methods.
      module OrderTracker
        # Record that an element attribute was set, so it appears in
        # the correct position during XML serialization.
        #
        # @param target [Lutaml::Model::Serializable] the model instance
        # @param attr_name [Symbol] the attribute name (e.g. :t, :section)
        def self.track_element(target, attr_name)
          target.element_order ||= []
          element_name = resolve_element_name(target, attr_name)
          target.element_order <<
            Lutaml::Xml::Element.new("Element", element_name, node_type: :element)
        end

        # Record a text content entry for mixed-content models.
        #
        # @param target [Lutaml::Model::Serializable] the model instance
        # @param text [String] the text content
        def self.track_text(target, text)
          target.element_order ||= []
          target.element_order <<
            Lutaml::Xml::Element.new(
              "Text", "text",
              node_type: :text,
              text_content: text.to_s,
            )
        end

        # Append a value to a collection attribute and track its order.
        #
        # @param target [Lutaml::Model::Serializable] the model instance
        # @param attr_name [Symbol] the collection attribute name
        # @param item [Object] the item to append
        def self.append_ordered(target, attr_name, item)
          collection = target.public_send(attr_name)
          unless collection.is_a?(Array)
            target.public_send(:"#{attr_name}=", [])
            collection = target.public_send(attr_name)
          end
          collection << item
          track_element(target, attr_name)
        end

        # Set a singular attribute and track its order.
        #
        # @param target [Lutaml::Model::Serializable] the model instance
        # @param attr_name [Symbol] the attribute name
        # @param value [Object] the value to set
        def self.set_ordered(target, attr_name, value)
          target.public_send(:"#{attr_name}=", value)
          track_element(target, attr_name)
        end

        # Set text content and track its order (for mixed-content models).
        #
        # @param target [Lutaml::Model::Serializable] the model instance
        # @param text [String] the text content
        def self.set_text_ordered(target, text)
          return if text.nil?

          target.content = text
          track_text(target, text)
        end

        class << self
          private

          # Resolve the XML element name for an attribute by consulting
          # the model's XML mapping.
          def resolve_element_name(target, attr_name)
            register = target.lutaml_register
            mapping = target.class.mappings_for(:xml, register)
            element_mapping = mapping&.find_element(attr_name)
            element_mapping&.name || attr_name.to_s
          end
        end
      end
    end
  end
end
