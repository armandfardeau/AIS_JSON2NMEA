# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module ShipStaticData
      # Encodes the ship type field for ship static data.
      class ShipType < Base
        normalize_value_as :integer

        def validate!
          return self if @value.between?(0, 255)

          raise InvalidFieldError, "Type must be between 0 and 255 (got: #{@value.inspect})"
        end

        def pack
          AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(@value, 8)
        end
      end
    end
  end
end
