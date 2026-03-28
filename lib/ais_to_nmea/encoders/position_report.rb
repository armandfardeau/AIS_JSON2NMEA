# frozen_string_literal: true

module AisToNmea
  module Encoders
    # Encoder dedicated to AIS Position Report messages (types 1, 2, 3)
    class PositionReport < Base
      MESSAGE_TYPES = [1, 2, 3].freeze
      PARTS_MAPPING = {
        message_id: {
          class: AisToNmea::MessageParts::Common::MessageId,
          field: 'MessageID'
        },
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

      def encode_message
        parts = extract_parts!
        validate_position_ranges!(parts)
        add_packed_parts(parts)

        payload, fill_bits = AisToNmea::AisEncoder::Utils::SixBit.encode(message)
        output = AisToNmea::AisEncoder::Utils::Nmea.build_sentences(payload, fill_bits)
        validate!(message, output)

        output
      end

      private

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
    end
  end
end
