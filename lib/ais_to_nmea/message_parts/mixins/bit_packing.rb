# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module Mixins
      # Bit packing helpers for AIS field serialization.
      module BitPacking
        def pack_uint(width, value = @value)
          AisToNmea::AisEncoder::BitPacking.pack_uint(value, width)
        end

        def pack_signed(width, value = @value)
          AisToNmea::AisEncoder::BitPacking.pack_signed(value, width)
        end
      end
    end
  end
end
