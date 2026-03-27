module AisToNmea
  module MessageParts
    module ShipStaticData
      class Destination
        def self.extract(data)
          AisToNmea::AisEncoder::Utils::Text.encode_ais_text_fixed(
            data['Destination'],
            length: 20,
            field_name: 'Destination'
          )
        end
      end
    end
  end
end
