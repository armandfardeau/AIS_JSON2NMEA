# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module PositionReport
      # Encodes the special maneuver indicator for a position report.
      class Maneuver < Base
        normalize_value_as :integer

        def validate!
          return self if @value.between?(0, 3)

          raise InvalidFieldError, "Maneuver must be between 0 and 3 (got: #{@value.inspect})"
        end

        def pack
          pack_uint(2)
        end
      end
    end
  end
end
