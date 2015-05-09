require 'active_support/inflector'

module JSONAPI
  module Serializer
    def self.included(target)
      target.send(:include, InstanceMethods)
      target.extend ClassMethods
      target.class_eval do
        include JSONAPI::Attributes
      end
    end

    module InstanceMethods
      attr_accessor :object

      def initialize(object)
        @object = object
      end

      # Override this method to customize how the ID is set.
      # Always return a string from this method to conform with the JSON:API spec.
      def id
        object.id.to_s
      end

      # Override this method to customize the type name.
      def type
        self.class.name.demodulize.sub('Serializer', '').downcase.pluralize
      end

      # By JSON:API spec convention, attribute names are dasherized. Override this to customize.
      def format_attribute_name(name)
        name.to_s.dasherize
      end

      def self_link
        "#{route_namespace}/#{type}/#{id}"
      end

      def relationship_self_link(name)
        "#{self_link}/links/#{name}"
      end

      def relationship_related_link(name)
        "#{self_link}/#{name}"
      end

      def meta
      end

      # Override this to provide a namespace like "/api/v1" for all generated links.
      def route_namespace
      end

      def find_serializer_class(object)
        "#{object.class.name}Serializer".constantize
      end

      def find_serializer(object)
        find_serializer_class(object).new(object)
      end

      def attributes
        attributes = {}
        self.class.attributes_map.each do |attr_name, attr_name_or_block|
          if attr_name_or_block.is_a?(Proc)
            # A block was given, call it to get the value.
            value = instance_eval(&attr_name_or_block)
          else
            # Default behavior, call a method by the name of the attribute.
            value = object.send(attr_name_or_block)
          end
          attributes[format_attribute_name(attr_name)] = value
        end
        attributes
      end

      def links
        data = {}
        data.merge!({'self' => self_link}) if !self_link.nil?
        return data if self.class.to_one_associations.nil?

        self.class.to_one_associations.each do |attr_name, attr_name_or_block|
          if attr_name_or_block.is_a?(Proc)
            # A block was given, call it to get the related_object.
            related_object = instance_eval(&attr_name_or_block)
          else
            # Default behavior, call a method by the name of the attribute.
            related_object = object.send(attr_name_or_block)
          end

          formatted_attribute_name = format_attribute_name(attr_name)
          data[formatted_attribute_name] = {
            'self' => relationship_self_link(attr_name),
            'related' => relationship_related_link(attr_name),
          }
          if related_object.nil?
            # Spec: Resource linkage MUST be represented as one of the following:
            # - null for empty to-one relationships.
            # http://jsonapi.org/format/#document-structure-resource-relationships
            data[formatted_attribute_name].merge!({'linkage' => nil})
          else
            related_object_serializer = find_serializer(related_object)
            data[formatted_attribute_name].merge!({
              'linkage' => {
                'type' => related_object_serializer.type,
                'id' => related_object_serializer.id.to_s,
              },
            })
          end
        end
        data
      end
    end

    module ClassMethods
      def serialize_primary_data(object)
        serializer = self.new(object)
        data = {
          'id' => serializer.id.to_s,
          'type' => serializer.type,
          'attributes' => serializer.attributes,
        }

        # Merge in optional top-level members if they are non-nil.
        # http://jsonapi.org/format/#document-structure-resource-objects
        data.merge!({'attributes' => serializer.attributes}) if !serializer.attributes.nil?
        data.merge!({'links' => serializer.links}) if !serializer.links.nil?
        data.merge!({'meta' => serializer.meta}) if !serializer.meta.nil?
        data
      end
    end
  end
end