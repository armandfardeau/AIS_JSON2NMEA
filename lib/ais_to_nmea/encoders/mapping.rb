# frozen_string_literal: true

module AisToNmea
  module Encoders
    # Loads and normalizes YAML-defined field mappings for encoders.
    class Mapping
      def self.parts_mapping(context_name:, mapping_config_path:)
        new(context_name: context_name, mapping_config_path: mapping_config_path).parts_mapping
      end

      def initialize(context_name:, mapping_config_path:)
        @context_name = context_name
        @mapping_config_path = mapping_config_path
      end

      def parts_mapping
        raw_mapping = all_parts_mappings.fetch(mapping_key) do
          raise InvalidFieldError,
                "No mapping found for encoder #{@context_name} (expected key: #{mapping_key})"
        end

        unless raw_mapping.is_a?(Hash)
          raise InvalidFieldError,
                "Invalid mapping for encoder #{@context_name}: expected Hash, got #{raw_mapping.class}"
        end

        normalize_mapping(raw_mapping, path: mapping_key)
      end

      private

      def all_parts_mappings
        @all_parts_mappings ||= YAML.safe_load_file(@mapping_config_path, aliases: true)
      rescue Psych::SyntaxError => e
        raise InvalidFieldError, "Invalid parts mapping YAML: #{e.message}"
      end

      def mapping_key
        @context_name.gsub(/([a-z\d])([A-Z])/, '\\1_\\2').downcase
      end

      def normalize_mapping(mapping, path:)
        unless mapping.is_a?(Hash)
          raise InvalidFieldError, "Invalid mapping structure at #{path}: expected Hash, got #{mapping.class}"
        end

        mapping.each_with_object({}) do |(key, value), normalized|
          normalized[key.to_sym] = normalize_mapping_entry(value, path: "#{path}.#{key}")
        end
      end

      # rubocop:disable Metrics/MethodLength
      def normalize_mapping_entry(value, path:)
        ensure_hash!(value, path: path)
        normalized = {}
        ensure_field_validity!(value, path: path)
        normalized[:field] = value['field'] if value.key?('field')

        if value.key?('class')
          ensure_class_validity!(value, path: path)
          normalized[:class] = constantize(value['class'])
        end

        if value.key?('nested')
          normalized[:nested] = normalize_mapping(value['nested'], path: "#{path}.nested")

          unless normalized[:field]
            raise InvalidFieldError,
                  "Invalid nested mapping at #{path}: nested entries require a parent field"
          end
        elsif !normalized[:class]
          raise InvalidFieldError, "Invalid mapping at #{path}: define either class or nested"
        end

        normalized
      end
      # rubocop:enable Metrics/MethodLength

      def ensure_hash!(value = nil, path:)
        return if value.is_a?(Hash)

        raise InvalidFieldError,
              "Invalid mapping entry at #{path}: expected Hash, got #{value.class}"
      end

      def ensure_field_validity!(value, path:)
        return unless value.key?('field') && !value['field'].is_a?(String)

        raise InvalidFieldError, "Invalid field at #{path}.field: expected String, got #{value['field'].class}"
      end

      def ensure_class_validity!(value, path:)
        return if value['class'].is_a?(String)

        raise InvalidFieldError, "Invalid class at #{path}.class: expected String, got #{value['class'].class}"
      end

      def constantize(class_name)
        class_name.split('::').inject(Object, &:const_get)
      rescue NameError
        raise InvalidFieldError, "Unknown class in parts mapping: #{class_name}"
      end
    end
  end
end
