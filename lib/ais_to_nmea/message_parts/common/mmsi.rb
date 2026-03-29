# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module Common
      # Encodes and validates the AIS MMSI/UserID field.
      class Mmsi < Base
        normalize_value_as :integer

        def validate!
          return self if @value.between?(0, 1_073_741_823)

          raise InvalidFieldError, "UserID must be between 0 and 1073741823 (got: #{@value.inspect})"
        end

        def pack
          pack_uint(30)
        end
      end
    end
  end
end
