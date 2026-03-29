# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module PositionReport
      # Encodes the true heading field for a position report.
      class Heading < Base
        normalize_value_as :integer

        def validate!
          return self if @value&.between?(0, 359) || @value == 511

          raise InvalidFieldError,
                "True Heading must be between 0 and 359, or 511 for unavailable (got: #{@value.inspect})"
        end

        def pack
          pack_uint(9)
        end
      end
    end
  end
end
