module AisToNmea
  module MessageParts
    module PositionReport
      class Timestamp
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
          return self if @value.between?(0, 63)

          raise InvalidFieldError, "Timestamp must be between 0 and 63 (got: #{@value.inspect})"
        end

        def pack
          AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(@value, 6)
        end
      end
    end
  end
end
