# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module PositionReport
      # Encodes the repeat indicator for a position report.
      class RepeatIndicator < Base
        normalize_value_as :integer

        def validate!
          return self if @value&.between?(0, 3)

          raise InvalidFieldError, "RepeatIndicator must be between 0 and 3 (got: #{@value.inspect})"
        end

        def pack
          AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(@value, 2)
        end
      end
    end
  end
end
