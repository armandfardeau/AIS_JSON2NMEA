# frozen_string_literal: true

module AisToNmea
  module Encoders
    # Encoder dedicated to AIS Position Report messages (types 1, 2, 3)
    class PositionReport < Base
      PART_KEYS_IN_ORDER = %i[
        repeat_indicator
        mmsi
        nav_status
        rot
        sog
        position_accuracy
        lon
        lat
        cog
        heading
        timestamp
        maneuver
        spare
        raim
        radio_status
      ].freeze

      POSITION_PART_CLASS_NAMES = {
        lat: 'Latitude',
        lon: 'Longitude',
        sog: 'Sog',
        cog: 'Cog',
        heading: 'Heading',
        nav_status: 'NavigationStatus',
        repeat_indicator: 'RepeatIndicator',
        rot: 'Rot',
        position_accuracy: 'PositionAccuracy',
        timestamp: 'Timestamp',
        maneuver: 'Maneuver',
        spare: 'Spare',
        raim: 'Raim',
        radio_status: 'RadioStatus'
      }.freeze

      # Convert AIS JSON message to NMEA 0183 sentence(s)
      #
      # @param input [String, Hash] JSON string or Ruby Hash containing AIS message data
      # @param options [Hash] Additional options (reserved for future use)
      #
      # @return [String] NMEA sentence(s), joined with newlines for multi-part
      #
      # @raise [InvalidJsonError] if JSON is malformed
      # @raise [MissingFieldError] if required fields are missing
      # @raise [InvalidFieldError] if field values are out of valid ranges
      # @raise [UnsupportedMessageTypeError] if message type is not 1, 2, or 3
      # @raise [EncodingError] if AIS encoding fails
      # @raise [MemoryError] if memory allocation fails
      def encode(input, _options = {})
        data = MessageType.parse_input(input)
        message_type, message_data = validated_payload(data)
        encode_position_report(message_type, message_data)
      rescue InvalidJsonError, MissingFieldError, InvalidFieldError, UnsupportedMessageTypeError
        raise
      rescue StandardError => e
        raise EncodingFailureError, e.message
      end

      private

      def encode_position_report(message_type, data)
        validate_valid_flag!(data)
        parts = extract_position_parts(data)
        validate_position_ranges!(parts)
        message_id_part = extract_validated_part(AisToNmea::MessageParts::Common::MessageId, message_type)
        add_position_report_parts(message_id_part, parts)

        payload, fill_bits = AisToNmea::AisEncoder::Utils::SixBit.encode(message)
        AisToNmea::AisEncoder::Utils::Nmea.build_sentences(payload, fill_bits)
      end

      def extract_position_parts(data)
        extract_parts_from(data, position_part_classes).merge(
          mmsi: extract_validated_part(AisToNmea::MessageParts::Common::Mmsi, data)
        )
      end

      def validate_position_ranges!(parts)
        AisToNmea::AisEncoder::Utils::Validation.validate_ranges!(
          lat: parts[:lat].value,
          lon: parts[:lon].value,
          sog: parts[:sog].value,
          cog: parts[:cog].value,
          heading: parts[:heading].value,
          nav_status: parts[:nav_status].value
        )
      end

      def add_position_report_parts(message_id_part, parts)
        ordered_parts = [message_id_part]
        ordered_parts.concat(PART_KEYS_IN_ORDER.map { |key| parts.fetch(key) })
        ordered_parts.each { |part| add_part(part.pack) }
      end

      def extract_validated_part(part_class, data)
        part_class.new(data).extract.validate!
      end

      def extract_parts_from(data, part_classes)
        part_classes.transform_values { |part_class| extract_validated_part(part_class, data) }
      end

      def position_part_classes
        position_parts = AisToNmea::MessageParts::PositionReport
        POSITION_PART_CLASS_NAMES.transform_values { |name| position_parts.const_get(name) }
      end

      def validated_payload(data)
        message_type = MessageType.detect(data)
        message_data = data.key?('Message') ? data['Message'] : data
        return [message_type, message_data] if [1, 2, 3].include?(message_type)

        raise UnsupportedMessageTypeError,
              "MessageID must be 1, 2, or 3 for PositionReport, got: #{message_type}"
      end

      def validate_valid_flag!(data)
        valid = AisToNmea::AisEncoder::Utils::Input.optional_bool_from(
          data,
          ['Valid'],
          field_name: 'Valid',
          default: true
        )

        return if valid

        raise InvalidFieldError, 'Valid must be true for PositionReport encoding'
      end
    end
  end
end
