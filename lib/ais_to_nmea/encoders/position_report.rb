# frozen_string_literal: true

module AisToNmea
  module Encoders
    # Encoder dedicated to AIS Position Report messages (types 1, 2, 3)
    class PositionReport < Base
      MESSAGE_TYPES = [1, 2, 3].freeze

      def encode_message
        parts = extract_parts!
        validate_position_ranges!(parts)
        add_packed_parts(parts)

        payload, fill_bits = AisToNmea::Encodings::SixBit.encode(message)
        AisToNmea::Encodings::Nmea.build_sentences(payload, fill_bits)
      end

      private

      def validate_position_ranges!(parts)
        AisToNmea::Validation.validate_ranges!(
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
