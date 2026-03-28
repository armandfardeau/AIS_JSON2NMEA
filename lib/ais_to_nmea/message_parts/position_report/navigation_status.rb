# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module PositionReport
      # Encodes the navigation status field for a position report.
      class NavigationStatus < Base
        normalize_value_as :integer

        def validate!
          self
        end

        def pack
          AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(@value, 4)
        end
      end
    end
  end
end
