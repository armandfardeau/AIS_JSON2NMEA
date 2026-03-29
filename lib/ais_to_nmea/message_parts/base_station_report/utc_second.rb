# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module BaseStationReport
      # Encodes UTC second for a base station report.
      class UtcSecond < Base
        normalize_value_as :integer

        def validate!
          return self if @value.between?(0, 63)

          raise InvalidFieldError, "UtcSecond must be between 0 and 63 (got: #{@value.inspect})"
        end

        def pack
          pack_uint(6)
        end
      end
    end
  end
end
