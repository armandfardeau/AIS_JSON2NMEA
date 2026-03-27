module AisToNmea
  module MessageParts
    module ShipStaticData
      class CallSign
        def self.extract(data)
          AisToNmea::AisEncoder::Utils::Text.encode_ais_text_fixed(
            data['CallSign'],
            length: 7,
            field_name: 'CallSign'
          )
        end
      end
    end
  end
end
