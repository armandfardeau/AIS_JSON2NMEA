module AisToNmea
  module Encoders
    # Encoder dedicated to AIS Ship Static Data (type 5)
    class ShipStaticData < Base
      def encode(input, options = {})
        data = MessageType.parse_input(input)
        message_type = MessageType.detect(data)
        message_data = data.key?('Message') ? data['Message'] : data

        unless message_type == 5
          raise UnsupportedMessageTypeError, "MessageID must be 5 for ShipStaticData, got: #{message_type}"
        end

        encode_ship_static_data(message_type, message_data)
      rescue InvalidJsonError, MissingFieldError, InvalidFieldError, UnsupportedMessageTypeError
        raise
      rescue StandardError => e
        raise EncodingFailureError, e.message
      end

      private

      def encode_ship_static_data(message_type, data)
        ais_version = Integer(data.fetch('AisVersion', 0))
        imo_number = Integer(data.fetch('ImoNumber', 0))
        call_sign_bits = AisToNmea::MessageParts::ShipStaticData::CallSign.extract(data)
        name_bits = AisToNmea::MessageParts::ShipStaticData::Name.extract(data)
        ship_type = Integer(data.fetch('Type', 0))

        dimension = data['Dimension'] || {}
        to_bow = Integer(dimension.fetch('A', 0))
        to_stern = Integer(dimension.fetch('B', 0))
        to_port = Integer(dimension.fetch('C', 0))
        to_starboard = Integer(dimension.fetch('D', 0))

        fix_type = Integer(data.fetch('FixType', 0))
        eta_month = AisToNmea::MessageParts::ShipStaticData::Etas::Month.extract(data)
        eta_day = AisToNmea::MessageParts::ShipStaticData::Etas::Day.extract(data)
        eta_hour = AisToNmea::MessageParts::ShipStaticData::Etas::Hour.extract(data)
        eta_minute = AisToNmea::MessageParts::ShipStaticData::Etas::Minute.extract(data)

        draught_dm = (Float(data.fetch('MaximumStaticDraught', 0.0)) * 10).round
        destination_bits = AisToNmea::MessageParts::ShipStaticData::Destination.extract(data)

        add_part(AisToNmea::MessageParts::Common::MessageId.extract(message_type))
        add_part(AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(0, 2))
        add_part(AisToNmea::MessageParts::Common::Mmsi.extract(data))
        add_part(AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(ais_version, 2))
        add_part(AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(imo_number, 30))
        add_part(call_sign_bits)
        add_part(name_bits)
        add_part(AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(ship_type, 8))
        add_part(AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(to_bow, 9))
        add_part(AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(to_stern, 9))
        add_part(AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(to_port, 6))
        add_part(AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(to_starboard, 6))
        add_part(AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(fix_type, 4))
        add_part(AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(eta_month, 4))
        add_part(AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(eta_day, 5))
        add_part(AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(eta_hour, 5))
        add_part(AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(eta_minute, 6))
        add_part(AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(draught_dm, 8))
        add_part(destination_bits)
        add_part(AisToNmea::MessageParts::ShipStaticData::Dte.extract(data))
        add_part(AisToNmea::MessageParts::ShipStaticData::Spare.extract(data))

        payload, fill_bits = AisToNmea::AisEncoder::Utils::SixBit.encode(message)
        AisToNmea::AisEncoder::Utils::Nmea.build_sentences(payload, fill_bits)
      rescue ArgumentError, TypeError
        raise InvalidFieldError, 'Invalid numeric value in ShipStaticData payload'
      end
    end
  end
end