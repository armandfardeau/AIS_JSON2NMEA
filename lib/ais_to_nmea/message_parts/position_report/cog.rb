# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module PositionReport
      # Encodes the course over ground field for a position report.
      class Cog < Base
        normalize_value_as :float

        def validate!
          return self if @value&.between?(0.0, 359.9)

          raise InvalidFieldError, "Course Over Ground must be between 0 and 359.9 (got: #{@value.inspect})"
        end

        def pack
          AisToNmea::AisEncoder::Utils::BitPacking.pack_uint((@value * 10).round, 12)
        end
      end
    end
  end
end
