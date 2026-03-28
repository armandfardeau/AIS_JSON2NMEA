# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module PositionReport
      # Encodes the position accuracy flag for a position report.
      class PositionAccuracy < Base
        normalize_value_as :integer

        def validate!
          return self if @value.between?(0, 1)

          raise InvalidFieldError, "PositionAccuracy must be between 0 and 1 (got: #{@value.inspect})"
        end

        def pack
          AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(@value, 1)
        end
      end
    end
  end
end
