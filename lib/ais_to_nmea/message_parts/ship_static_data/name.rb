module AisToNmea
  module MessageParts
    module ShipStaticData
      class Name
        def self.extract(data)
          AisToNmea::AisEncoder::Utils::Text.encode_ais_text_fixed(
            data['Name'],
            length: 20,
            field_name: 'Name'
          )
        end
      end
    end
  end
end
