# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module PositionReport
      # Encodes the longitude field for a position report.
      class Longitude < Base
        normalize_value_as :float

        def validate!
          self
        end

        def pack
          AisToNmea::AisEncoder::Utils::BitPacking.pack_signed((@value * 600_000).round, 28)
        end
      end
    end
  end
end
