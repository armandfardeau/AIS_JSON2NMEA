# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module PositionReport
      # Encodes the RAIM flag for a position report.
      class Raim < Base
        normalize_value_as :integer

        def validate!
          return self if @value.between?(0, 1)

          raise InvalidFieldError, "Raim must be between 0 and 1 (got: #{@value.inspect})"
        end

        def pack
          AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(@value, 1)
        end
      end
    end
  end
end
