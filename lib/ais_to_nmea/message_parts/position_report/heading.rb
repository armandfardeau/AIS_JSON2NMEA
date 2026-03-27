module AisToNmea
  module MessageParts
    module PositionReport
      class Heading
        def self.extract(value, packed: false)
          if packed
            AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(value, 9)
          else
            AisToNmea::AisEncoder::Utils::Input.required_int(value, 'TrueHeading')
          end
        end
      end
    end
  end
end
