# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module PositionReport
      # Encodes the RAIM flag for a position report.
      class Raim
        attr_reader :value

        def initialize(data = nil, value = nil)
          @data = data
          @value = value
        end

        def extract
          raim = AisToNmea::AisEncoder::Utils::Input.optional_bool_from(
            @data,
            ['Raim'],
            field_name: 'Raim',
            default: false
          )
          @value = raim ? 1 : 0
          self
        end

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
