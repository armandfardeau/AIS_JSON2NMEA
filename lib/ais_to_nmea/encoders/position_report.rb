module AisToNmea
  module Encoders
    # Encoder dedicated to AIS Position Report messages (types 1, 2, 3)
    class PositionReport < Base
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
      def encode(input, options = {})
        data = MessageType.parse_input(input)
        message_type = MessageType.detect(data)
        message_data = data.key?('Message') ? data['Message'] : data

        unless [1, 2, 3].include?(message_type)
          raise UnsupportedMessageTypeError,
                "MessageID must be 1, 2, or 3 for PositionReport, got: #{message_type}"
        end

        encode_position_report(message_type, message_data)
      rescue InvalidJsonError, MissingFieldError, InvalidFieldError, UnsupportedMessageTypeError
        raise
      rescue StandardError => e
        raise EncodingFailureError, e.message
      end

      private

      def encode_position_report(message_type, data)
        validate_valid_flag!(data)

        lat_part = AisToNmea::MessageParts::PositionReport::Latitude.new(data).extract.validate!
        lon_part = AisToNmea::MessageParts::PositionReport::Longitude.new(data).extract.validate!
        sog_part = AisToNmea::MessageParts::PositionReport::Sog.new(data).extract.validate!
        cog_part = AisToNmea::MessageParts::PositionReport::Cog.new(data).extract.validate!
        heading_part = AisToNmea::MessageParts::PositionReport::Heading.new(data).extract.validate!
        nav_status_part = AisToNmea::MessageParts::PositionReport::NavigationStatus.new(data).extract.validate!
        repeat_indicator_part = AisToNmea::MessageParts::PositionReport::RepeatIndicator.new(data).extract.validate!
        rot_part = AisToNmea::MessageParts::PositionReport::Rot.new(data).extract.validate!
        position_accuracy_part = AisToNmea::MessageParts::PositionReport::PositionAccuracy.new(data).extract.validate!
        timestamp_part = AisToNmea::MessageParts::PositionReport::Timestamp.new(data).extract.validate!
        maneuver_part = AisToNmea::MessageParts::PositionReport::Maneuver.new(data).extract.validate!
        spare_part = AisToNmea::MessageParts::PositionReport::Spare.new(data).extract.validate!
        raim_part = AisToNmea::MessageParts::PositionReport::Raim.new(data).extract.validate!
        radio_status_part = AisToNmea::MessageParts::PositionReport::RadioStatus.new(data).extract.validate!
        mmsi_part = AisToNmea::MessageParts::Common::Mmsi.new(data).extract.validate!

        AisToNmea::AisEncoder::Utils::Validation.validate_ranges!(lat_part.value, lon_part.value, sog_part.value, cog_part.value, heading_part.value, nav_status_part.value)

        message_id_part = AisToNmea::MessageParts::Common::MessageId.new(message_type).extract.validate!

        add_part(message_id_part.pack)
        add_part(repeat_indicator_part.pack)
        add_part(mmsi_part.pack)
        add_part(nav_status_part.pack)
        add_part(rot_part.pack)
        add_part(sog_part.pack)
        add_part(position_accuracy_part.pack)
        add_part(lon_part.pack)
        add_part(lat_part.pack)
        add_part(cog_part.pack)
        add_part(heading_part.pack)
        add_part(timestamp_part.pack)
        add_part(maneuver_part.pack)
        add_part(spare_part.pack)
        add_part(raim_part.pack)
        add_part(radio_status_part.pack)

        payload, fill_bits = AisToNmea::AisEncoder::Utils::SixBit.encode(message)
        AisToNmea::AisEncoder::Utils::Nmea.build_sentences(payload, fill_bits)
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