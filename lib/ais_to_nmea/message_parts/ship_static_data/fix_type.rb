# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module ShipStaticData
      # Encodes the electronic position fix type for ship static data.
      class FixType < Base
        normalize_value_as :integer

        def validate!
          return self if @value.between?(0, 15)

          raise InvalidFieldError, "FixType must be between 0 and 15 (got: #{@value.inspect})"
        end

        def pack
          pack_uint(4)
        end
      end
    end
  end
end
