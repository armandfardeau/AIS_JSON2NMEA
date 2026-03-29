# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module BaseStationReport
      # Encodes UTC month for a base station report.
      class UtcMonth < Base
        normalize_value_as :integer

        def validate!
          return self if @value.between?(0, 12)

          raise InvalidFieldError, "UtcMonth must be between 0 and 12 (got: #{@value.inspect})"
        end

        def pack
          pack_uint(4)
        end
      end
    end
  end
end
