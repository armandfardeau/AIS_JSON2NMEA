module AisToNmea
  module MessageParts
    module PositionReport
      class Sog
        def self.extract(value, packed: false)
          if packed
            AisToNmea::AisEncoder::Utils::BitPacking.pack_uint((value * 10).round, 10)
          else
            AisToNmea::AisEncoder::Utils::Input.required_float_from(
              value,
              ['Sog', 'SpeedOverGround'],
              field_name: 'Sog/SpeedOverGround'
            )
          end
        end
      end
    end
  end
end
