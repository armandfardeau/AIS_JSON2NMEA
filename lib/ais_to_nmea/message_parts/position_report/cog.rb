# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module PositionReport
      # Encodes the course over ground field for a position report.
      class Cog < Base
        normalize_value_as :float

        def validate!
          self
        end

        def pack
          AisToNmea::AisEncoder::Utils::BitPacking.pack_uint((@value * 10).round, 12)
        end
      end
    end
  end
end
