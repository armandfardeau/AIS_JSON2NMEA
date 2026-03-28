module AisToNmea
  module MessageParts
    module SafetyBroadcastMessage
      class Spare
        attr_reader :value

        def initialize(data = nil, value = nil)
          @data = data
          @value = value
        end

        def extract
          @value = AisToNmea::AisEncoder::Utils::Input.optional_int_from(
            @data,
            ['Spare'],
            field_name: 'Spare',
            default: 0
          )
          self
        end

        def validate!
          return self if @value.between?(0, 3)

          raise InvalidFieldError, 'Spare must be between 0 and 3'
        end

        def pack
          AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(@value, 2)
        end
      end
    end
  end
end
