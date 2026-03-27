module AisToNmea
  module MessageParts
    module ShipStaticData
      class Spare
        def self.extract(data)
          spare = data.fetch('Spare', false) ? 1 : 0
          AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(spare, 1)
        end
      end
    end
  end
end
