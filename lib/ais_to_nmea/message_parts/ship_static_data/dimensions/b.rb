# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module ShipStaticData
      # Encodes the vessel dimension fields for ship static data.
      module Dimensions
        class B < Base
          normalize_value_as :integer

          def validate!
            return self if value.between?(0, 511)

            raise InvalidFieldError, "Dimension B must be between 0 and 511 (got: #{value.inspect})"
          end

          def pack
            AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(@value, 9)
          end
        end
      end
    end
  end
end
