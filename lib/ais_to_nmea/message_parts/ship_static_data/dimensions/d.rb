# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module ShipStaticData
      # Encodes the vessel dimension fields for ship static data.
      module Dimensions
        class D < Base
          normalize_value_as :integer

          def validate!
            return self if value.between?(0, 63)

            raise InvalidFieldError, "Dimension values must be within valid ranges (got: #{value.inspect})"
          end

          def pack
            AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(@value, 6)
          end
        end
      end
    end
  end
end
