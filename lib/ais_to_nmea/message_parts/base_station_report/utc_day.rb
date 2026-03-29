# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module BaseStationReport
      # Encodes UTC day for a base station report.
      class UtcDay < Base
        normalize_value_as :integer

        def validate!
          return self if @value.between?(0, 31)

          raise InvalidFieldError, "UtcDay must be between 0 and 31 (got: #{@value.inspect})"
        end

        def pack
          pack_uint(5)
        end
      end
    end
  end
end
