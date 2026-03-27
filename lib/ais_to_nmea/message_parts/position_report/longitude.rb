module AisToNmea
  module MessageParts
    module PositionReport
      class Longitude
        def self.extract(value, packed: false)
          if packed
            AisToNmea::AisEncoder::Utils::BitPacking.pack_signed((value * 600000).round, 28)
          else
            AisToNmea::AisEncoder::Utils::Input.required_float(value, 'Longitude')
          end
        end
      end
    end
  end
end
