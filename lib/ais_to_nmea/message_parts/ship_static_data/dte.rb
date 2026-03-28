# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module ShipStaticData
      # Encodes the data terminal equipment flag for ship static data.
      class Dte < Base
        normalize_value_as :bool

        def pack
          AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(@value)
        end
      end
    end
  end
end
