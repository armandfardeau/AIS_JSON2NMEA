# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module PositionReport
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
          return self if @value.between?(0, 255)

          raise InvalidFieldError, "Rot must be between 0 and 255 (got: #{@value.inspect})"
        end

        def pack
          AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(@value, 8)
        end
      end
    end
  end
end
