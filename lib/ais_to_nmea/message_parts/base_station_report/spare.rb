# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module BaseStationReport
      # Encodes the spare bits for a base station report.
      class Spare < Base
        normalize_value_as :integer

        def validate!
          return self if @value.between?(0, 1023)

          raise InvalidFieldError, "Spare must be between 0 and 1023 (got: #{@value.inspect})"
        end

        def pack
          pack_uint(10)
        end
      end
    end
  end
end
