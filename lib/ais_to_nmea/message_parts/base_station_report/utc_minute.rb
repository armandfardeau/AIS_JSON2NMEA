# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module BaseStationReport
      # Encodes UTC minute for a base station report.
      class UtcMinute < Base
        normalize_value_as :integer

        def validate!
          return self if @value.between?(0, 59)

          raise InvalidFieldError, "UtcMinute must be between 0 and 59 (got: #{@value.inspect})"
        end

        def pack
          pack_uint(6)
        end
      end
    end
  end
end
