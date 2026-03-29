# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module PositionReport
      # Encodes the speed over ground field for a position report.
      class Sog < Base
        normalize_value_as :float

        def validate!
          self
        end

        def pack
          packed_value = @value > 102.2 ? 1023 : (@value * 10).round
          pack_uint(10, packed_value)
        end
      end
    end
  end
end
