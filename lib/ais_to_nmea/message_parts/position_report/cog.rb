# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module PositionReport
      # Encodes the course over ground field for a position report.
      class Cog < Base
        normalize_value_as :float

        def validate!
          return self if @value&.between?(0.0, 360.0)

          raise InvalidFieldError,
                "Course Over Ground must be between 0 and 359.9 (or 360.0 for unavailable) (got: #{@value.inspect})"
        end

        def pack
          pack_uint(12, (@value * 10).round)
        end
      end
    end
  end
end
