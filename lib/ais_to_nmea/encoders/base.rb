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
      include Mixins::Mapping

      MAPPING_CONFIG_PATH = File.expand_path('../config/mapping.yml', __dir__).freeze

      attr_reader :message

      def initialize(data: {}, options: {})
        @message = +''
        @data = build_ir(parse_input(data), parts_mapping)
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

      def extract_parts!(data = @data, mapping = parts_mapping)
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
        return if self.class::MESSAGE_TYPES.include?(@data.message_id)

        raise UnsupportedMessageTypeError,
              <<~MESSAGE.chomp
                MessageID must be one of #{self.class::MESSAGE_TYPES.join(', ')} for #{self.class.name}, got: #{@data.message_id}
              MESSAGE
      end

      def context_name
        self.class.name.split('::').last
      end
    end
  end
end
