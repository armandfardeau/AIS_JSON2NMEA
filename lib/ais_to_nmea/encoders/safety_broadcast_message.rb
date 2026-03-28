# frozen_string_literal: true

module AisToNmea
  module Encoders
    # Encoder dedicated to AIS Safety Broadcast Message (type 14)
    class SafetyBroadcastMessage < Base
      MESSAGE_TYPES = [14].freeze
      PARTS_MAPPING = {
        message_id: {
          class: AisToNmea::MessageParts::Common::MessageId,
          field: 'MessageID'
        },
        repeat_indicator: {
          class: AisToNmea::MessageParts::SafetyBroadcastMessage::RepeatIndicator,
          field: 'RepeatIndicator'
        },
        mmsi: {
          class: AisToNmea::MessageParts::Common::Mmsi,
          field: 'UserID'
        },
        spare: {
          class: AisToNmea::MessageParts::SafetyBroadcastMessage::Spare,
          field: 'Spare'
        },
        text: {
          class: AisToNmea::MessageParts::SafetyBroadcastMessage::Text,
          field: 'Text'
        },
        valid: {
          class: AisToNmea::MessageParts::Common::Valid,
          field: 'Valid'
        }
      }.freeze

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
