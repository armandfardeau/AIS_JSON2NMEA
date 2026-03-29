# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module ShipStaticData
      # Encodes the repeat indicator for ship static data.
      class RepeatIndicator < Base
        normalize_value_as :integer

        def validate!
          return self if @value.between?(0, 3)

          raise InvalidFieldError, "RepeatIndicator must be between 0 and 3 (got: #{@value.inspect})"
        end

        def pack
          pack_uint(2)
        end
      end
    end
  end
end
