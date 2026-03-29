# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module PositionReport
      # Encodes the rate of turn field for a position report.
      class Rot < Base
        normalize_value_as :integer

        def validate!
          return self if @value.between?(-128, 255)

          raise InvalidFieldError, "Rot must be between -128 and 255 (got: #{@value.inspect})"
        end

        def pack
          encoded_value = @value.negative? ? (256 + @value) : @value
          pack_uint(8, encoded_value)
        end
      end
    end
  end
end
