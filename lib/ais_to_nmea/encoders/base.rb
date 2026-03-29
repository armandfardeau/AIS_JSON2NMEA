# frozen_string_literal: true

require 'json'
require 'yaml'

module AisToNmea
  module Encoders
    # Base class shared by all AIS encoder implementations.
    class Base
      include Mixins::InputParser
      include Mixins::IntermediateRepresentation
      include Mixins::StrictValidation
      include Mixins::Context

      MAPPING_CONFIG_PATH = File.expand_path('../config/mapping.yml', __dir__).freeze

      class << self
        def parts_mapping
          @parts_mapping ||= begin
            raw_mapping = all_parts_mappings.fetch(mapping_key) do
              raise InvalidFieldError, "No mapping found for encoder #{name}"
            end

            unless raw_mapping.is_a?(Hash)
              raise InvalidFieldError, "Invalid mapping for encoder #{name}: expected Hash, got #{raw_mapping.class}"
            end

            normalize_mapping(raw_mapping, path: mapping_key)
          end
        end

        private

        def all_parts_mappings
          @all_parts_mappings ||= YAML.safe_load_file(MAPPING_CONFIG_PATH, aliases: true)
        rescue Psych::SyntaxError => e
          raise InvalidFieldError, "Invalid parts mapping YAML: #{e.message}"
        end

        def mapping_key
          name.split('::').last
              .gsub(/([a-z\d])([A-Z])/, '\\1_\\2')
              .downcase
        end

        def normalize_mapping(mapping, path:)
          unless mapping.is_a?(Hash)
            raise InvalidFieldError, "Invalid mapping structure at #{path}: expected Hash, got #{mapping.class}"
          end

          mapping.each_with_object({}) do |(key, value), normalized|
            normalized[key.to_sym] = normalize_mapping_entry(value, path: "#{path}.#{key}")
          end
        end

        def normalize_mapping_entry(value, path:)
          unless value.is_a?(Hash)
            raise InvalidFieldError,
                  "Invalid mapping entry at #{path}: expected Hash, got #{value.class}"
          end

          normalized = {}

          if value.key?('field') && !value['field'].is_a?(String)
            raise InvalidFieldError, "Invalid field at #{path}.field: expected String, got #{value['field'].class}"
          end

          normalized[:field] = value['field'] if value.key?('field')

          if value.key?('class')
            unless value['class'].is_a?(String)
              raise InvalidFieldError, "Invalid class at #{path}.class: expected String, got #{value['class'].class}"
            end

            normalized[:class] = constantize(value['class'])
          end

          normalized[:nested] = normalize_mapping(value['nested'], path: "#{path}.nested") if value.key?('nested')

          if normalized[:nested] && !normalized[:field]
            raise InvalidFieldError, "Invalid nested mapping at #{path}: nested entries require a parent field"
          end

          if !normalized[:nested] && !normalized[:class]
            raise InvalidFieldError, "Invalid mapping at #{path}: define either class or nested"
          end

          normalized
        end

        def constantize(class_name)
          class_name.split('::').inject(Object, &:const_get)
        rescue NameError
          raise InvalidFieldError, "Unknown class in parts mapping: #{class_name}"
        end
      end

      attr_reader :message

      def initialize(data: {}, options: {})
        @message = +''
        @data = build_ir(parse_input(data), context_mapping)
        @options = options
      end

      def encode
        validate_message_type!
        raise_missing_fields!
        encoded_output = encode_message

        OutputValidator.validate!(@data, encoded_output)

        encoded_output
      end

      def encode_message
        add_packed_parts

        payload, fill_bits = AisToNmea::Encodings::SixBit.encode(message)
        AisToNmea::Encodings::Nmea.build_sentences(payload, fill_bits)
      end

      private

      def extract_parts!(data = @data, mapping = context_mapping)
        mapping.each_with_object({}) do |(key, part_map), parts|
          parts[key] = if part_map[:nested]
                         nested_data = data.send(key)
                         extract_parts!(nested_data, part_map[:nested])
                       else
                         value = data.send(key)
                         part_map[:class].new(value).validate!
                       end
        end
      end

      def add_part(part)
        @message << part
      end

      def add_parts(parts)
        parts.each { |part| add_part(part) }
      end

      def add_packed_parts(parts = extract_parts!)
        add_parts(flatten_packed_parts(parts))
      end

      def flatten_packed_parts(parts)
        parts.flat_map do |_key, part|
          if part.is_a?(Hash)
            flatten_packed_parts(part)
          else
            Array(part.pack)
          end
        end
      end

      def validate_message_type!
        return if context_mapping_message_types.include?(@data.message_id)

        raise UnsupportedMessageTypeError,
              <<~MESSAGE.chomp
                MessageID must be one of #{context_mapping_message_types.join(', ')} for #{context_name}, got: #{@data.message_id}
              MESSAGE
      end
    end
  end
end
