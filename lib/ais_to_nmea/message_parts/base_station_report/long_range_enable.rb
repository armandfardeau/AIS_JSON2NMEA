# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module BaseStationReport
      # Accepts an input flag for compatibility with upstream payload schemas.
      # This field is not represented as a dedicated AIS bit in message type 4.
      class LongRangeEnable < Base
        normalize_value_as :bool

        def validate!
          return self if @value.between?(0, 1)

          raise InvalidFieldError, "LongRangeEnable must be between 0 and 1 (got: #{@value.inspect})"
        end

        def pack
          ''
        end
      end
    end
  end
end
