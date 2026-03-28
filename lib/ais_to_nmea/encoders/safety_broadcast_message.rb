# frozen_string_literal: true

module AisToNmea
  module Encoders
    # Encoder dedicated to AIS Safety Broadcast Message (type 14)
    class SafetyBroadcastMessage < Base
      PART_CLASSES_IN_ORDER = {
        repeat_indicator: AisToNmea::MessageParts::SafetyBroadcastMessage::RepeatIndicator,
        mmsi: AisToNmea::MessageParts::Common::Mmsi,
        spare: AisToNmea::MessageParts::SafetyBroadcastMessage::Spare,
        text: AisToNmea::MessageParts::SafetyBroadcastMessage::Text
      }.freeze

      def encode(input, _options = {})
        data = MessageType.parse_input(input)
        message_type, message_data = validated_payload(data)
        encode_safety_broadcast_message(message_type, message_data)
      rescue InvalidJsonError, MissingFieldError, InvalidFieldError, UnsupportedMessageTypeError
        raise
      rescue StandardError => e
        raise EncodingFailureError, e.message
      end

      private

      def encode_safety_broadcast_message(message_type, data)
        parts = extract_safety_broadcast_parts(data)
        message_id_part = extract_validated_part(AisToNmea::MessageParts::Common::MessageId, message_type)
        add_safety_broadcast_parts(message_id_part, parts)

        payload, fill_bits = AisToNmea::AisEncoder::Utils::SixBit.encode(message)
        AisToNmea::AisEncoder::Utils::Nmea.build_sentences(payload, fill_bits)
      end

      def extract_safety_broadcast_parts(data)
        extract_parts_from(data, PART_CLASSES_IN_ORDER)
      end

      def add_safety_broadcast_parts(message_id_part, parts)
        ordered_parts = [message_id_part]
        ordered_parts.concat(PART_CLASSES_IN_ORDER.keys.map { |key| parts.fetch(key) })
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
        message_data = data.key?('Message') ? data['Message'] : data
        return [message_type, message_data] if message_type == 14

        raise UnsupportedMessageTypeError, "MessageID must be 14 for SafetyBroadcastMessage, got: #{message_type}"
      end
    end
  end
end
