module AisToNmea
  module MessageParts
    module ShipStaticData
      class Dte
        def self.extract(data)
          dte = data.fetch('Dte', false) ? 1 : 0
          AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(dte, 1)
        end
      end
    end
  end
end
