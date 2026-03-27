module AisToNmea
  module Encoders
    # Encoder dedicated to AIS Safety Broadcast Message (type 14)
    class SafetyBroadcastMessage < Base
      def encode(input, options = {})
        data = MessageType.parse_input(input)
        message_type = MessageType.detect(data)
        message_data = data.key?('Message') ? data['Message'] : data

        unless message_type == 14
          raise UnsupportedMessageTypeError, "MessageID must be 14 for SafetyBroadcastMessage, got: #{message_type}"
        end

        encode_safety_broadcast_message(message_type, message_data)
      rescue InvalidJsonError, MissingFieldError, InvalidFieldError, UnsupportedMessageTypeError
        raise
      rescue StandardError => e
        raise EncodingFailureError, e.message
      end

      private

      def encode_safety_broadcast_message(message_type, data)
        text_bits = AisToNmea::AisEncoder::Utils::Text.encode_ais_text(data['Text'], max_length: 156)

        add_part(AisToNmea::MessageParts::Common::MessageId.extract(message_type))
        add_part(AisToNmea::MessageParts::SafetyBroadcastMessage::RepeatIndicator.extract(data))
        add_part(AisToNmea::MessageParts::Common::Mmsi.extract(data))
        add_part(AisToNmea::MessageParts::SafetyBroadcastMessage::Spare.extract(data))
        add_part(text_bits)

        payload, fill_bits = AisToNmea::AisEncoder::Utils::SixBit.encode(message)
        AisToNmea::AisEncoder::Utils::Nmea.build_sentences(payload, fill_bits)
      end
    end
  end
end