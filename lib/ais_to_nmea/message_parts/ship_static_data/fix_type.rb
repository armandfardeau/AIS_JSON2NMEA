# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module ShipStaticData
      # Encodes the electronic position fix type for ship static data.
      class FixType
        attr_reader :value

        def initialize(data = nil, value = nil)
          @data = data
          @value = value
        end

        def extract
          @value = AisToNmea::AisEncoder::Utils::Input.optional_int_from(
            @data,
            ['FixType'],
            field_name: 'FixType',
            default: 0
          )
          self
        end

        def validate!
          return self if @value.between?(0, 15)

          raise InvalidFieldError, "FixType must be between 0 and 15 (got: #{@value.inspect})"
        end

        def pack
          AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(@value, 4)
        end
      end
    end
  end
end
