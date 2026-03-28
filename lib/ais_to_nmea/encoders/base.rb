# frozen_string_literal: true

require 'json'

module AisToNmea
  module Encoders
    # Base class shared by all AIS encoder implementations.
    class Base
      include AisToNmea::AisEncoder::Utils::OutputValidator

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

      def extract_parts!(data = @data, mapping = self.class::PARTS_MAPPING)
        mapping.map do |key, part_map|
          if part_map[:nested]
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
        add_parts(
          parts.values
               .map(&:pack)
               .flatten
        )
      end

      # Build an intermediate representation of the data based on the provided mapping.
      # This allows for easier access to nested fields and a more structured way to handle the data.
      # @param data [Hash] The input data hash
      # @param mapping [Hash] The mapping that defines how to extract fields from the data
      # @return [Struct] A structured representation of the data based on the mapping
      def build_data_ir(data, mapping = self.class::PARTS_MAPPING)
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
                                                                             self.class::PARTS_MAPPING)
      end
    end
  end
end
