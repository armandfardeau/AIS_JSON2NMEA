module AisToNmea
  module MessageParts
    module PositionReport
      class PositionAccuracy
        attr_reader :value

        def initialize(data = nil, value = nil)
          @data = data
          @value = value
        end

        def extract
          @value = 0
          self
        end

        def validate!
          return self if @value.between?(0, 1)

          raise InvalidFieldError, "PositionAccuracy must be between 0 and 1 (got: #{@value.inspect})"
        end

        def pack
          AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(@value, 1)
        end
      end
    end
  end
end
