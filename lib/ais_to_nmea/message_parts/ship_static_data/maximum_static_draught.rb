# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module ShipStaticData
      # Encodes the maximum static draught field for ship static data.
      class MaximumStaticDraught < Base
        normalize_value_as :float

        def validate!
          @value = 0.0 if @value.nil?
          return self if @value.between?(0.0, 25.5)

          raise InvalidFieldError, "MaximumStaticDraught must be between 0.0 and 25.5 (got: #{@value.inspect})"
        end

        def pack
          draught_dm = (@value * 10).round
          AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(draught_dm, 8)
        end
      end
    end
  end
end
