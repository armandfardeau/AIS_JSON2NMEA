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
        message_id_part = AisToNmea::MessageParts::Common::MessageId.new(message_type).extract.validate!
        repeat_indicator_part = AisToNmea::MessageParts::SafetyBroadcastMessage::RepeatIndicator.new(data).extract.validate!
        spare_part = AisToNmea::MessageParts::SafetyBroadcastMessage::Spare.new(data).extract.validate!
        text_part = AisToNmea::MessageParts::SafetyBroadcastMessage::Text.new(data).extract.validate!
        mmsi_part = AisToNmea::MessageParts::Common::Mmsi.new(data).extract.validate!

        add_part(message_id_part.pack)
        add_part(repeat_indicator_part.pack)
        add_part(mmsi_part.pack)
        add_part(spare_part.pack)
        add_part(text_part.pack)

        payload, fill_bits = AisToNmea::AisEncoder::Utils::SixBit.encode(message)
        AisToNmea::AisEncoder::Utils::Nmea.build_sentences(payload, fill_bits)
      end
    end
  end
end