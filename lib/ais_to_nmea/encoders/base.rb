# frozen_string_literal: true

require 'json'
require 'yaml'

module AisToNmea
  module Encoders
    # Base class shared by all AIS encoder implementations.
    class Base
      include AisToNmea::AisEncoder::Utils::OutputValidator

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
          @all_parts_mappings ||= YAML.safe_load(
            File.read(MAPPING_CONFIG_PATH),
            aliases: true
          )
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
            raise InvalidFieldError, "Invalid mapping entry at #{path}: expected Hash, got #{value.class}"
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

          if value.key?('nested')
            normalized[:nested] = normalize_mapping(value['nested'], path: "#{path}.nested")
          end

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
        @raw_data = data
        @data = build_data_ir(parse_input(data))
        @output_ir = nil
        @options = options
      end

      def encode
        validate_message_type!
        # validate_required_fields!
        encode_message
      rescue InvalidJsonError, MissingFieldError, InvalidFieldError, UnsupportedMessageTypeError => e
        raise e
      end

      private

      def extract_parts!(data = @data, mapping = self.class.parts_mapping)
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

      # Build an intermediate representation of the data based on the provided mapping.
      # This allows for easier access to nested fields and a more structured way to handle the data.
      # @param data [Hash] The input data hash
      # @param mapping [Hash] The mapping that defines how to extract fields from the data
      # @return [Struct] A structured representation of the data based on the mapping
      def build_data_ir(data, mapping = self.class.parts_mapping)
        data = mapping.values.map do |mapping|
          if mapping[:nested]
            build_data_ir(data[mapping[:field]], mapping[:nested])
          else
            data[mapping[:field]]
          end
        end

        Struct.new(*mapping.keys).new(*data)
      end

      # Parse JSON string or Hash input
      #
      # @param input [String, Hash] JSON string or Ruby Hash
      # @return [Hash] Parsed data
      # @raise [InvalidJsonError] if input is invalid JSON
      def parse_input(input)
        return input if input.is_a?(Hash)
        return parse_json_input(input) if input.is_a?(String)

        raise InvalidJsonError, 'Input must be a JSON string or Hash'
      end

      def parse_json_input(input)
        JSON.parse(input)
      rescue JSON::ParserError => e
        raise InvalidJsonError, "Invalid JSON: #{e.message}"
      end

      def validate_message_type!
        return if self.class::MESSAGE_TYPES.include?(@data.message_id)

        raise UnsupportedMessageTypeError,
              "MessageID must be one of #{self.class::MESSAGE_TYPES.join(', ')} for #{self.class.name.split('::').last}, got: #{@data.message_id}"
      end

      def validate_required_fields!
        AisToNmea::AisEncoder::Utils::StrictValidation.raise_missing_fields!(self.class.name.split('::').last, @data,
                                                                             self.class.parts_mapping)
      end
    end
  end
end
