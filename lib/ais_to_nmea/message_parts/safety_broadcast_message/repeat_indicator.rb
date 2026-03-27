module AisToNmea
  module MessageParts
    module SafetyBroadcastMessage
      class RepeatIndicator
        def self.extract(data)
          repeat_indicator = Integer(data.fetch('RepeatIndicator', 0))
          unless repeat_indicator.between?(0, 3)
            raise InvalidFieldError, 'RepeatIndicator must be between 0 and 3'
          end

          AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(repeat_indicator, 2)
        rescue ArgumentError, TypeError
          raise InvalidFieldError, 'RepeatIndicator must be between 0 and 3'
        end
      end
    end
  end
end
