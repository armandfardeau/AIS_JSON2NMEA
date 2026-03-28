module AisToNmea
  module MessageParts
    module PositionReport
      class RepeatIndicator
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
          return self if @value.between?(0, 3)

          raise InvalidFieldError, "RepeatIndicator must be between 0 and 3 (got: #{@value.inspect})"
        end

        def pack
          AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(@value, 2)
        end
      end
    end
  end
end
