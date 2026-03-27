module AisToNmea
  module MessageParts
    module SafetyBroadcastMessage
      class Spare
        def self.extract(data)
          spare = Integer(data.fetch('Spare', 0))
          unless spare.between?(0, 3)
            raise InvalidFieldError, 'Spare must be between 0 and 3'
          end

          AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(spare, 2)
        rescue ArgumentError, TypeError
          raise InvalidFieldError, 'Spare must be between 0 and 3'
        end
      end
    end
  end
end
