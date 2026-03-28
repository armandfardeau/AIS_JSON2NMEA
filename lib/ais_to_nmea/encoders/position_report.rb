# frozen_string_literal: true

module AisToNmea
  module Encoders
    # Encoder dedicated to AIS Position Report messages (types 1, 2, 3)
    class PositionReport < Base
      PARTS_MAPPING = {
        repeat_indicator: {
          class: AisToNmea::MessageParts::PositionReport::RepeatIndicator,
          field: 'RepeatIndicator'
        },
        mmsi: {
          class: AisToNmea::MessageParts::Common::Mmsi,
          field: 'UserID'
        },
        nav_status: {
          class: AisToNmea::MessageParts::PositionReport::NavigationStatus,
          field: 'NavigationalStatus'
        },
        rot: {
          class: AisToNmea::MessageParts::PositionReport::Rot,
          field: 'RateOfTurn'
        },
        sog: {
          class: AisToNmea::MessageParts::PositionReport::Sog,
          field: 'SpeedOverGround'
        },
        position_accuracy: {
          class: AisToNmea::MessageParts::PositionReport::PositionAccuracy,
          field: 'PositionAccuracy'
        },
        lon: {
          class: AisToNmea::MessageParts::PositionReport::Longitude,
          field: 'Longitude'
        },
        lat: {
          class: AisToNmea::MessageParts::PositionReport::Latitude,
          field: 'Latitude'
        },
        cog: {
          class: AisToNmea::MessageParts::PositionReport::Cog,
          field: 'CourseOverGround'
        },
        heading: {
          class: AisToNmea::MessageParts::PositionReport::Heading,
          field: 'TrueHeading'
        },
        timestamp: {
          class: AisToNmea::MessageParts::PositionReport::Timestamp,
          field: 'Timestamp'
        },
        maneuver: {
          class: AisToNmea::MessageParts::PositionReport::Maneuver,
          field: 'SpecialManoeuvreIndicator'
        },
        spare: {
          class: AisToNmea::MessageParts::PositionReport::Spare,
          field: 'Spare'
        },
        raim: {
          class: AisToNmea::MessageParts::PositionReport::Raim,
          field: 'Raim'
        },
        radio_status: {
          class: AisToNmea::MessageParts::PositionReport::RadioStatus,
          field: 'RadioStatus'
        }
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
        parts = extract_parts_from(data, PARTS_MAPPING)
        validate_position_ranges!(parts)
        message_id_part = extract_validated_part(AisToNmea::MessageParts::Common::MessageId, message_type)
        add_position_report_parts(message_id_part, parts)

        payload, fill_bits = AisToNmea::AisEncoder::Utils::SixBit.encode(message)
        AisToNmea::AisEncoder::Utils::Nmea.build_sentences(payload, fill_bits)
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
