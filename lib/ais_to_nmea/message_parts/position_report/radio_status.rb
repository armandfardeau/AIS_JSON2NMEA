# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module PositionReport
      # Encodes the radio status field for a position report.
      class RadioStatus < Base
        normalize_value_as :integer

        def validate!
          return self if @value.between?(0, 524_287)

          raise InvalidFieldError, "RadioStatus must be between 0 and 524287 (got: #{@value.inspect})"
        end

        def pack
          pack_uint(19)
        end
      end
    end
  end
end
