# frozen_string_literal: true

module AisToNmea
  module Encoders
    # Encoder dedicated to AIS Safety Broadcast Message (type 14)
    class SafetyBroadcastMessage < Base
      MESSAGE_TYPES = [14].freeze

      def encode_message
        add_packed_parts

        payload, fill_bits = AisToNmea::AisEncoder::Utils::SixBit.encode(message)
        output = AisToNmea::AisEncoder::Utils::Nmea.build_sentences(payload, fill_bits)
        validate!(@data, output)

        output
      end
    end
  end
end
