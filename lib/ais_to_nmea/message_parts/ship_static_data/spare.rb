# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module ShipStaticData
      # Encodes the spare bits for ship static data.
      class Spare < Base
        normalize_value_as :bool

        def validate!
          return self unless @value.nil?

          raise InvalidFieldError, "Spare field must be present (got: #{@value.inspect})"
        end

        def pack
          AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(@value, 1)
        end
      end
    end
  end
end
