# frozen_string_literal: true

module AisToNmea
  module Encoders
    # Encoder dedicated to AIS Position Report messages (types 1, 2, 3)
    class PositionReport < Base
      PARTS_MAPPING = {
        repeat_indicator: AisToNmea::MessageParts::PositionReport::RepeatIndicator,
        mmsi: AisToNmea::MessageParts::Common::Mmsi,
        nav_status: AisToNmea::MessageParts::PositionReport::NavigationStatus,
        rot: AisToNmea::MessageParts::PositionReport::Rot,
        sog: AisToNmea::MessageParts::PositionReport::Sog,
        position_accuracy: AisToNmea::MessageParts::PositionReport::PositionAccuracy,
        lon: AisToNmea::MessageParts::PositionReport::Longitude,
        lat: AisToNmea::MessageParts::PositionReport::Latitude,
        cog: AisToNmea::MessageParts::PositionReport::Cog,
        heading: AisToNmea::MessageParts::PositionReport::Heading,
        timestamp: AisToNmea::MessageParts::PositionReport::Timestamp,
        maneuver: AisToNmea::MessageParts::PositionReport::Maneuver,
        spare: AisToNmea::MessageParts::PositionReport::Spare,
        raim: AisToNmea::MessageParts::PositionReport::Raim,
        radio_status: AisToNmea::MessageParts::PositionReport::RadioStatus
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
      def encode
        message_type, message_data = validated_payload(@data)
        encode_position_report(message_type, message_data)
      rescue InvalidJsonError, MissingFieldError, InvalidFieldError, UnsupportedMessageTypeError
        raise
      rescue StandardError => e
        raise EncodingFailureError, e.message
      end

      private

      def encode_position_report(message_type, data)
        validate_required_fields!(data)
        validate_valid_flag!(data)
        parts = extract_position_parts(data)
        validate_position_ranges!(parts)
        message_id_part = extract_validated_part(AisToNmea::MessageParts::Common::MessageId, message_type)
        add_position_report_parts(message_id_part, parts)

        payload, fill_bits = AisToNmea::AisEncoder::Utils::SixBit.encode(message)
        AisToNmea::AisEncoder::Utils::Nmea.build_sentences(payload, fill_bits)
      end

      def extract_position_parts(data)
        extract_parts_from(data, PARTS_MAPPING)
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
        ordered_parts.concat(PARTS_MAPPING.keys.map { |key| parts.fetch(key) })
        add_parts(ordered_parts.map(&:pack))
      end

      def extract_validated_part(part_class, data)
        part_class.new(data).extract.validate!
      end

      def extract_parts_from(data, part_classes)
        part_classes.transform_values { |part_class| extract_validated_part(part_class, data) }
      end

      def validated_payload(data)
        message_type = MessageType.detect(data)
        return [message_type, data] if [1, 2, 3].include?(message_type)

        raise UnsupportedMessageTypeError,
              "MessageID must be 1, 2, or 3 for PositionReport, got: #{message_type}"
      end

      def validate_valid_flag!(data)
        AisToNmea::AisEncoder::Utils::StrictValidation.validate_required_true_flag!(data, 'PositionReport')
      end

      def validate_required_fields!(data)
        # All fields from PARTS_MAPPING are required
        required_field_names = %w[
          RepeatIndicator UserID Valid NavigationalStatus RateOfTurn Sog PositionAccuracy
          Longitude Latitude Cog TrueHeading Timestamp SpecialManoeuvreIndicator Spare Raim
          CommunicationState
        ]
        missing_fields = AisToNmea::AisEncoder::Utils::StrictValidation.missing_required_simple_fields(
          data, required_field_names
        )
        AisToNmea::AisEncoder::Utils::StrictValidation.raise_missing_fields!('PositionReport', missing_fields)
      end
    end
  end
end
