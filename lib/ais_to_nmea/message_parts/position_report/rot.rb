# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module PositionReport
      # Encodes the rate of turn field for a position report.
      class Rot
        attr_reader :value

        def initialize(data = nil, value = nil)
          @data = data
          @value = value
        end

        def extract
          @value = AisToNmea::AisEncoder::Utils::Input.optional_int_from(
            @data,
            %w[RateOfTurn Rot],
            field_name: 'RateOfTurn/Rot',
            default: 128
          )
          self
        end

        def validate!
          return self if @value.between?(-128, 255)

          raise InvalidFieldError, "Rot must be between -128 and 255 (got: #{@value.inspect})"
        end

        def pack
          encoded_value = @value.negative? ? (256 + @value) : @value
          AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(encoded_value, 8)
        end
      end
    end
  end
end
