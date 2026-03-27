module AisToNmea
  module MessageParts
    module PositionReport
      class NavigationStatus
        def self.extract(value, packed: false)
          if packed
            AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(value, 4)
          else
            AisToNmea::AisEncoder::Utils::Input.optional_int_from(
              value,
              ['NavigationStatus', 'NavigationalStatus'],
              field_name: 'NavigationStatus/NavigationalStatus',
              default: 0
            )
          end
        end
      end
    end
  end
end
