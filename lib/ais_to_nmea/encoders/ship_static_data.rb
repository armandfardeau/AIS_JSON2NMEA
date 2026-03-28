# frozen_string_literal: true

module AisToNmea
  module Encoders
    # Encoder dedicated to AIS Ship Static Data (type 5)
    class ShipStaticData < Base
      REQUIRED_DIMENSION_KEYS = %w[A B C D].freeze
      REQUIRED_ETA_KEYS = %w[Month Day Hour Minute].freeze

      PARTS_MAPPING = {
        repeat_indicator: {
          class: AisToNmea::MessageParts::ShipStaticData::RepeatIndicator,
          field: 'RepeatIndicator'
        },
        mmsi: {
          class: AisToNmea::MessageParts::Common::Mmsi,
          field: 'UserID'
        },
        ais_version: {
          class: AisToNmea::MessageParts::ShipStaticData::AisVersion,
          field: 'AISVersion'
        },
        imo_number: {
          class: AisToNmea::MessageParts::ShipStaticData::ImoNumber,
          field: 'IMONumber'
        },
        call_sign: {
          class: AisToNmea::MessageParts::ShipStaticData::CallSign,
          field: 'CallSign'
        },
        name: {
          class: AisToNmea::MessageParts::ShipStaticData::Name,
          field: 'Name'
        },
        ship_type: {
          class: AisToNmea::MessageParts::ShipStaticData::ShipType,
          field: 'ShipType'
        },
        dimensions: {
          class: AisToNmea::MessageParts::ShipStaticData::Dimensions,
          field: 'Dimensions'
        },
        fix_type: {
          class: AisToNmea::MessageParts::ShipStaticData::FixType,
          field: 'FixType'
        },
        eta_month: {
          class: AisToNmea::MessageParts::ShipStaticData::Etas::Month,
          field: 'ETAMonth'
        },
        eta_day: {
          class: AisToNmea::MessageParts::ShipStaticData::Etas::Day,
          field: 'ETADay'
        },
        eta_hour: {
          class: AisToNmea::MessageParts::ShipStaticData::Etas::Hour,
          field: 'ETAHour'
        },
        eta_minute: {
          class: AisToNmea::MessageParts::ShipStaticData::Etas::Minute,
          field: 'ETAMinute'
        },
        maximum_static_draught: {
          class: AisToNmea::MessageParts::ShipStaticData::MaximumStaticDraught,
          field: 'MaximumStaticDraught'
        },
        destination: {
          class: AisToNmea::MessageParts::ShipStaticData::Destination,
          field: 'Destination'
        },
        dte: {
          class: AisToNmea::MessageParts::ShipStaticData::Dte,
          field: 'DTE'
        },
        spare: {
          class: AisToNmea::MessageParts::ShipStaticData::Spare,
          field: 'Spare'
        }
      }.freeze

      def encode
        message_type, message_data = validated_payload(@data)
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
        parts = extract_parts_from(data, PARTS_MAPPING)
        message_id_part = extract_validated_part(AisToNmea::MessageParts::Common::MessageId, message_type)
        add_ship_static_parts(message_id_part, parts)

        payload, fill_bits = AisToNmea::AisEncoder::Utils::SixBit.encode(message)
        AisToNmea::AisEncoder::Utils::Nmea.build_sentences(payload, fill_bits)
      end

      def add_ship_static_parts(message_id_part, parts)
        packed_parts = [message_id_part.pack]
        PARTS_MAPPING.each_key do |key|
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

      def validated_payload(data)
        message_type = MessageType.detect(data)
        message_data = data.key?('Message') ? data['Message'] : data
        return [message_type, message_data] if message_type == 5

        raise UnsupportedMessageTypeError, "MessageID must be 5 for ShipStaticData, got: #{message_type}"
      end

      def validate_required_fields!(data)
        # All fields from PARTS_MAPPING are required
        required_field_names = PARTS_MAPPING.values.map { |part_map| part_map[:field] }
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
