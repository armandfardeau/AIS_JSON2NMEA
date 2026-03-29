# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module ShipStaticData
      # Encodes the vessel dimension fields for ship static data.
      module Dimensions
        # Encodes the D (starboard bow) dimension for vessel dimensions.
        class D < Base
          normalize_value_as :integer

          def validate!
            return self if @value.between?(0, 63)

            raise InvalidFieldError, "Dimension D must be between 0 and 63 (got: #{@value.inspect})"
          end

          def pack
            pack_uint(6)
          end
        end
      end
    end
  end
end
