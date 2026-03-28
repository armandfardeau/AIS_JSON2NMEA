# frozen_string_literal: true

module AisToNmea
  module Encoders
    # Encoder dedicated to AIS Ship Static Data (type 5)
    class ShipStaticData < Base
      MESSAGE_TYPES = [5].freeze
      PARTS_MAPPING = {
        message_id: {
          class: AisToNmea::MessageParts::Common::MessageId,
          field: 'MessageID'
        },
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
        fix_type: {
          class: AisToNmea::MessageParts::ShipStaticData::FixType,
          field: 'FixType'
        },
        eta: {
          field: 'Eta',
          nested: {
            month: {
              field: 'Month',
              class: AisToNmea::MessageParts::ShipStaticData::Etas::Month
            },
            day: {
              field: 'Day',
              class: AisToNmea::MessageParts::ShipStaticData::Etas::Day
            },
            hour: {
              field: 'Hour',
              class: AisToNmea::MessageParts::ShipStaticData::Etas::Hour
            },
            minute: {
              field: 'Minute',
              class: AisToNmea::MessageParts::ShipStaticData::Etas::Minute
            }
          }
        },
        dimension: {
          field: 'Dimension',
          nested: {
            a: {
              field: 'A',
              class: AisToNmea::MessageParts::ShipStaticData::Dimensions::A
            },
            b: {
              field: 'B',
              class: AisToNmea::MessageParts::ShipStaticData::Dimensions::B
            },
            c: {
              field: 'C',
              class: AisToNmea::MessageParts::ShipStaticData::Dimensions::C
            },
            d: {
              field: 'D',
              class: AisToNmea::MessageParts::ShipStaticData::Dimensions::D
            }
          }
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
        },
        valid: {
          class: AisToNmea::MessageParts::Common::Valid,
          field: 'Valid'
        }
      }.freeze

      def encode_message
        add_packed_parts

        payload, fill_bits = AisToNmea::AisEncoder::Utils::SixBit.encode(message)
        AisToNmea::AisEncoder::Utils::Nmea.build_sentences(payload, fill_bits)
      end
    end
  end
end
