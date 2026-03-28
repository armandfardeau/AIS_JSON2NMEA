# frozen_string_literal: true

module AisToNmea
  module Encoders
    # Encoder dedicated to AIS Ship Static Data (type 5)
    class ShipStaticData < Base
      REQUIRED_DIMENSION_KEYS = %w[A B C D].freeze
      REQUIRED_ETA_KEYS = %w[Month Day Hour Minute].freeze

      PART_CLASSES_IN_ORDER = {
        repeat_indicator: AisToNmea::MessageParts::ShipStaticData::RepeatIndicator,
        mmsi: AisToNmea::MessageParts::Common::Mmsi,
        ais_version: AisToNmea::MessageParts::ShipStaticData::AisVersion,
        imo_number: AisToNmea::MessageParts::ShipStaticData::ImoNumber,
        call_sign: AisToNmea::MessageParts::ShipStaticData::CallSign,
        name: AisToNmea::MessageParts::ShipStaticData::Name,
        ship_type: AisToNmea::MessageParts::ShipStaticData::ShipType,
        dimensions: AisToNmea::MessageParts::ShipStaticData::Dimensions,
        fix_type: AisToNmea::MessageParts::ShipStaticData::FixType,
        eta_month: AisToNmea::MessageParts::ShipStaticData::Etas::Month,
        eta_day: AisToNmea::MessageParts::ShipStaticData::Etas::Day,
        eta_hour: AisToNmea::MessageParts::ShipStaticData::Etas::Hour,
        eta_minute: AisToNmea::MessageParts::ShipStaticData::Etas::Minute,
        maximum_static_draught: AisToNmea::MessageParts::ShipStaticData::MaximumStaticDraught,
        destination: AisToNmea::MessageParts::ShipStaticData::Destination,
        dte: AisToNmea::MessageParts::ShipStaticData::Dte,
        spare: AisToNmea::MessageParts::ShipStaticData::Spare
      }.freeze

      def encode
        data = MessageType.parse_input(@data)
        message_type, message_data = validated_payload(data)
        encode_ship_static_data(message_type, message_data)
      rescue InvalidJsonError, MissingFieldError, InvalidFieldError, UnsupportedMessageTypeError
        raise
      rescue StandardError => e
        raise EncodingFailureError, e.message
      end

      private

      def encode_ship_static_data(message_type, data)
        validate_required_fields!(data)
        validate_valid_flag!(data)
        parts = extract_ship_static_parts(data)
        message_id_part = extract_validated_part(AisToNmea::MessageParts::Common::MessageId, message_type)
        add_ship_static_parts(message_id_part, parts)

        payload, fill_bits = AisToNmea::AisEncoder::Utils::SixBit.encode(message)
        AisToNmea::AisEncoder::Utils::Nmea.build_sentences(payload, fill_bits)
      end

      def extract_ship_static_parts(data)
        extract_parts_from(data, PART_CLASSES_IN_ORDER)
      end

      def add_ship_static_parts(message_id_part, parts)
        packed_parts = [message_id_part.pack]
        PART_CLASSES_IN_ORDER.each_key do |key|
          part = parts.fetch(key)
          if key == :dimensions
            packed_parts.concat(pack_dimensions(part))
          else
            packed_parts << part.pack
          end
        end
        add_parts(packed_parts)
      end

      def extract_validated_part(part_class, data)
        part_class.new(data).extract.validate!
      end

      def pack_dimensions(dimensions_part)
        dimensions = dimensions_part.pack
        [dimensions[:a], dimensions[:b], dimensions[:c], dimensions[:d]]
      end

      def extract_parts_from(data, part_classes)
        part_classes.transform_values { |part_class| extract_validated_part(part_class, data) }
      end

      def validated_payload(data)
        message_type = MessageType.detect(data)
        message_data = data.key?('Message') ? data['Message'] : data
        return [message_type, message_data] if message_type == 5

        raise UnsupportedMessageTypeError, "MessageID must be 5 for ShipStaticData, got: #{message_type}"
      end

      def validate_required_fields!(data)
        # All fields from PART_CLASSES_IN_ORDER are required
        required_field_names = %w[
          RepeatIndicator UserID Valid AisVersion ImoNumber CallSign Name Type Dimension FixType Eta
          MaximumStaticDraught Destination Dte Spare
        ]
        missing_fields = AisToNmea::AisEncoder::Utils::StrictValidation.missing_required_simple_fields(
          data, required_field_names
        )
        missing_fields.concat(collect_nested_field_errors(data))

        AisToNmea::AisEncoder::Utils::StrictValidation.raise_missing_fields!('ShipStaticData', missing_fields.uniq)
      end

      def collect_nested_field_errors(data)
        utils = AisToNmea::AisEncoder::Utils::StrictValidation
        utils.missing_required_nested_fields(data, 'Dimension', REQUIRED_DIMENSION_KEYS) +
          utils.missing_required_nested_fields(data, 'Eta', REQUIRED_ETA_KEYS)
      end

      def validate_valid_flag!(data)
        AisToNmea::AisEncoder::Utils::StrictValidation.validate_required_true_flag!(data, 'ShipStaticData')
      end
    end
  end
end
