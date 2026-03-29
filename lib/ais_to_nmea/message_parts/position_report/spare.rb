# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module PositionReport
      # Encodes the spare bits for a position report.
      class Spare < Base
        normalize_value_as :integer

        def validate!
          return self if @value.between?(0, 7)

          raise InvalidFieldError, "Spare must be between 0 and 7 (got: #{@value.inspect})"
        end

        def pack
          pack_uint(3)
        end
      end
    end
  end
end
