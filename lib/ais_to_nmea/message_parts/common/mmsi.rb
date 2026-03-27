module AisToNmea
  module MessageParts
    module Common
      class Mmsi
        def self.extract(data)
          AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(
            AisToNmea::AisEncoder::Utils::Input.required_int(data, 'UserID'),
            30
          )
        end
      end
    end
  end
end
