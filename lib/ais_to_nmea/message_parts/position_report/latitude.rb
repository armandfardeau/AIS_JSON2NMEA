# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module PositionReport
      # Encodes the latitude field for a position report.
      class Latitude < Base
        normalize_value_as :float

        def validate!
          unless @value.between?(-90.0, 90.0)
            raise InvalidFieldError, "Latitude must be between -90 and 90 (got: #{@value.inspect})"
          end

          self
        end

        def pack
          pack_signed(27, (@value * 600_000).round)
        end
      end
    end
  end
end
