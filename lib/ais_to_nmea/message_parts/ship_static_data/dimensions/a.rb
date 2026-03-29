# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module ShipStaticData
      # Encodes the vessel dimension fields for ship static data.
      module Dimensions
        # Encodes the A (port side) dimension for vessel dimensions.
        class A < Base
          normalize_value_as :integer

          def validate!
            return self if @value.between?(0, 511)

            raise InvalidFieldError, "Dimension A must be between 0 and 511 (got: #{@value.inspect})"
          end

          def pack
            pack_uint(9)
          end
        end
      end
    end
  end
end
