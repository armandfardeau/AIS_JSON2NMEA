# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module BaseStationReport
      # Encodes UTC year for a base station report.
      class UtcYear < Base
        normalize_value_as :integer

        def validate!
          return self if @value.between?(0, 9999)

          raise InvalidFieldError, "UtcYear must be between 0 and 9999 (got: #{@value.inspect})"
        end

        def pack
          pack_uint(14)
        end
      end
    end
  end
end
