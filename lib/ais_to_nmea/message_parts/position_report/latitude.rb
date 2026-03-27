module AisToNmea
  module MessageParts
    module PositionReport
      class Latitude
        def self.extract(value, packed: false)
          if packed
            AisToNmea::AisEncoder::Utils::BitPacking.pack_signed((value * 600000).round, 27)
          else
            AisToNmea::AisEncoder::Utils::Input.required_float(value, 'Latitude')
          end
        end
      end
    end
  end
end
