# frozen_string_literal: true

module AisToNmea
  module Encoders
    # Encoder dedicated to AIS Ship Static Data (type 5)
    class ShipStaticData < Base
      PRE_DIMENSION_KEYS = %i[repeat_indicator mmsi ais_version imo_number call_sign name ship_type].freeze
      POST_DIMENSION_KEYS = %i[
        fix_type eta_month eta_day eta_hour eta_minute
        maximum_static_draught destination dte spare
      ].freeze
      SHIP_STATIC_PART_CLASS_PATHS = {
        mmsi: 'AisToNmea::MessageParts::Common::Mmsi',
        ais_version: 'AisToNmea::MessageParts::ShipStaticData::AisVersion',
        imo_number: 'AisToNmea::MessageParts::ShipStaticData::ImoNumber',
        call_sign: 'AisToNmea::MessageParts::ShipStaticData::CallSign',
        name: 'AisToNmea::MessageParts::ShipStaticData::Name',
        ship_type: 'AisToNmea::MessageParts::ShipStaticData::ShipType',
        dimensions: 'AisToNmea::MessageParts::ShipStaticData::Dimensions',
        fix_type: 'AisToNmea::MessageParts::ShipStaticData::FixType',
        eta_month: 'AisToNmea::MessageParts::ShipStaticData::Etas::Month',
        eta_day: 'AisToNmea::MessageParts::ShipStaticData::Etas::Day',
        eta_hour: 'AisToNmea::MessageParts::ShipStaticData::Etas::Hour',
        eta_minute: 'AisToNmea::MessageParts::ShipStaticData::Etas::Minute',
        maximum_static_draught: 'AisToNmea::MessageParts::ShipStaticData::MaximumStaticDraught',
        destination: 'AisToNmea::MessageParts::ShipStaticData::Destination',
        dte: 'AisToNmea::MessageParts::ShipStaticData::Dte',
        spare: 'AisToNmea::MessageParts::ShipStaticData::Spare'
      }.freeze

      def encode(input, _options = {})
        data = MessageType.parse_input(input)
        message_type, message_data = validated_payload(data)
        encode_ship_static_data(message_type, message_data)
      rescue InvalidJsonError, MissingFieldError, InvalidFieldError, UnsupportedMessageTypeError
        raise
      rescue StandardError => e
        raise EncodingFailureError, e.message
      end

      private

      def encode_ship_static_data(message_type, data)
        parts = extract_ship_static_parts(data)
        message_id_part = extract_validated_part(AisToNmea::MessageParts::Common::MessageId, message_type)
        add_ship_static_parts(message_id_part, parts)

        payload, fill_bits = AisToNmea::AisEncoder::Utils::SixBit.encode(message)
        AisToNmea::AisEncoder::Utils::Nmea.build_sentences(payload, fill_bits)
      end

      def extract_ship_static_parts(data)
        extract_parts_from(data, ship_static_part_classes).merge(
          repeat_indicator: AisToNmea::MessageParts::ShipStaticData::RepeatIndicator.new.extract.validate!
        )
      end

      def add_ship_static_parts(message_id_part, parts)
        packed_parts = [message_id_part.pack]
        packed_parts.concat(pack_keys(parts, PRE_DIMENSION_KEYS))
        packed_parts.concat(pack_dimensions(parts[:dimensions]))
        packed_parts.concat(pack_keys(parts, POST_DIMENSION_KEYS))
        packed_parts.each { |part| add_part(part) }
      end

      def extract_validated_part(part_class, data)
        part_class.new(data).extract.validate!
      end

      def pack_keys(parts, keys)
        keys.map { |key| parts.fetch(key).pack }
      end

      def pack_dimensions(dimensions_part)
        dimensions = dimensions_part.pack
        [dimensions[:a], dimensions[:b], dimensions[:c], dimensions[:d]]
      end

      def extract_parts_from(data, part_classes)
        part_classes.transform_values { |part_class| extract_validated_part(part_class, data) }
      end

      def ship_static_part_classes
        SHIP_STATIC_PART_CLASS_PATHS.transform_values { |path| Object.const_get(path) }
      end

      def validated_payload(data)
        message_type = MessageType.detect(data)
        message_data = data.key?('Message') ? data['Message'] : data
        return [message_type, message_data] if message_type == 5

        raise UnsupportedMessageTypeError, "MessageID must be 5 for ShipStaticData, got: #{message_type}"
      end
    end
  end
end
