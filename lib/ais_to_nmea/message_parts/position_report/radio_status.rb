module AisToNmea
  module MessageParts
    module PositionReport
      class RadioStatus
        attr_reader :value

        def initialize(data = nil, value = nil)
          @data = data
          @value = value
        end

        def extract
          @value = AisToNmea::AisEncoder::Utils::Input.optional_int_from(
            @data,
            ['RadioStatus'],
            field_name: 'RadioStatus',
            default: 0
          )
          self
        end

        def validate!
          return self if @value.between?(0, 524_287)

          raise InvalidFieldError, "RadioStatus must be between 0 and 524287 (got: #{@value.inspect})"
        end

        def pack
          AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(@value, 19)
        end
      end
    end
  end
end
