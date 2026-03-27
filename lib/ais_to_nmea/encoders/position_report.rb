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
        lat = AisToNmea::MessageParts::PositionReport::Latitude.extract(data)
        lon = AisToNmea::MessageParts::PositionReport::Longitude.extract(data)
        sog = AisToNmea::MessageParts::PositionReport::Sog.extract(data)
        cog = AisToNmea::MessageParts::PositionReport::Cog.extract(data)
        heading = AisToNmea::MessageParts::PositionReport::Heading.extract(data)
        nav_status = AisToNmea::MessageParts::PositionReport::NavigationStatus.extract(data)

        AisToNmea::AisEncoder::Utils::Validation.validate_ranges!(lat, lon, sog, cog, heading, nav_status)

        add_part(AisToNmea::MessageParts::Common::MessageId.extract(message_type))
        add_part(AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(0, 2)) # repeat indicator
        add_part(AisToNmea::MessageParts::Common::Mmsi.extract(data))
        add_part(AisToNmea::MessageParts::PositionReport::NavigationStatus.extract(nav_status, packed: true))
        add_part(AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(128, 8)) # ROT unavailable
        add_part(AisToNmea::MessageParts::PositionReport::Sog.extract(sog, packed: true))
        add_part(AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(0, 1)) # position accuracy
        add_part(AisToNmea::MessageParts::PositionReport::Longitude.extract(lon, packed: true))
        add_part(AisToNmea::MessageParts::PositionReport::Latitude.extract(lat, packed: true))
        add_part(AisToNmea::MessageParts::PositionReport::Cog.extract(cog, packed: true))
        add_part(AisToNmea::MessageParts::PositionReport::Heading.extract(heading, packed: true))
        add_part(AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(0, 6)) # timestamp
        add_part(AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(0, 2)) # maneuver
        add_part(AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(0, 3)) # spare
        add_part(AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(0, 1)) # RAIM
        add_part(AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(0, 19)) # radio status

        payload, fill_bits = AisToNmea::AisEncoder::Utils::SixBit.encode(message)
        AisToNmea::AisEncoder::Utils::Nmea.build_sentences(payload, fill_bits)
      end
    end
  end
end