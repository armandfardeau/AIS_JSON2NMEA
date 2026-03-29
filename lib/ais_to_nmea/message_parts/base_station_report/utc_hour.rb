# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module BaseStationReport
      # Encodes UTC hour for a base station report.
      class UtcHour < Base
        normalize_value_as :integer

        def validate!
          return self if @value.between?(0, 24)

          raise InvalidFieldError, "UtcHour must be between 0 and 24 (got: #{@value.inspect})"
        end

        def pack
          pack_uint(5)
        end
      end
    end
  end
end
