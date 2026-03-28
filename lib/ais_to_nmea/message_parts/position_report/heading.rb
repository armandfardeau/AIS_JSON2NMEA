# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module PositionReport
      # Encodes the true heading field for a position report.
      class Heading < Base
        normalize_value_as :integer

        def validate!
          self
        end

        def pack
          AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(@value, 9)
        end
      end
    end
  end
end
