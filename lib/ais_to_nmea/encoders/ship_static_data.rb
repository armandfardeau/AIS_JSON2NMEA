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
        message_id_part = AisToNmea::MessageParts::Common::MessageId.new(message_type).extract.validate!
        repeat_indicator_part = AisToNmea::MessageParts::ShipStaticData::RepeatIndicator.new.extract.validate!
        mmsi_part = AisToNmea::MessageParts::Common::Mmsi.new(data).extract.validate!
        ais_version_part = AisToNmea::MessageParts::ShipStaticData::AisVersion.new(data).extract.validate!
        imo_number_part = AisToNmea::MessageParts::ShipStaticData::ImoNumber.new(data).extract.validate!
        call_sign_part = AisToNmea::MessageParts::ShipStaticData::CallSign.new(data).extract.validate!
        name_part = AisToNmea::MessageParts::ShipStaticData::Name.new(data).extract.validate!
        ship_type_part = AisToNmea::MessageParts::ShipStaticData::ShipType.new(data).extract.validate!
        dimensions_part = AisToNmea::MessageParts::ShipStaticData::Dimensions.new(data).extract.validate!
        fix_type_part = AisToNmea::MessageParts::ShipStaticData::FixType.new(data).extract.validate!
        eta_month_part = AisToNmea::MessageParts::ShipStaticData::Etas::Month.new(data).extract.validate!
        eta_day_part = AisToNmea::MessageParts::ShipStaticData::Etas::Day.new(data).extract.validate!
        eta_hour_part = AisToNmea::MessageParts::ShipStaticData::Etas::Hour.new(data).extract.validate!
        eta_minute_part = AisToNmea::MessageParts::ShipStaticData::Etas::Minute.new(data).extract.validate!
        maximum_static_draught_part = AisToNmea::MessageParts::ShipStaticData::MaximumStaticDraught.new(data).extract.validate!
        destination_part = AisToNmea::MessageParts::ShipStaticData::Destination.new(data).extract.validate!
        dte_part = AisToNmea::MessageParts::ShipStaticData::Dte.new(data).extract.validate!
        spare_part = AisToNmea::MessageParts::ShipStaticData::Spare.new(data).extract.validate!
        packed_dimensions = dimensions_part.pack

        add_part(message_id_part.pack)
        add_part(repeat_indicator_part.pack)
        add_part(mmsi_part.pack)
        add_part(ais_version_part.pack)
        add_part(imo_number_part.pack)
        add_part(call_sign_part.pack)
        add_part(name_part.pack)
        add_part(ship_type_part.pack)
        add_part(packed_dimensions[:a])
        add_part(packed_dimensions[:b])
        add_part(packed_dimensions[:c])
        add_part(packed_dimensions[:d])
        add_part(fix_type_part.pack)
        add_part(eta_month_part.pack)
        add_part(eta_day_part.pack)
        add_part(eta_hour_part.pack)
        add_part(eta_minute_part.pack)
        add_part(maximum_static_draught_part.pack)
        add_part(destination_part.pack)
        add_part(dte_part.pack)
        add_part(spare_part.pack)

        payload, fill_bits = AisToNmea::AisEncoder::Utils::SixBit.encode(message)
        AisToNmea::AisEncoder::Utils::Nmea.build_sentences(payload, fill_bits)
      end
    end
  end
end