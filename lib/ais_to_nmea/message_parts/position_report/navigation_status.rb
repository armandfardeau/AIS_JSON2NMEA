# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module PositionReport
      class NavigationStatus
        attr_reader :value

        def initialize(data = nil, value = nil)
          @data = data
          @value = value
        end

        def extract
          @value = AisToNmea::AisEncoder::Utils::Input.optional_int_from(
            @data,
            %w[NavigationStatus NavigationalStatus],
            field_name: 'NavigationStatus/NavigationalStatus',
            default: 0
          )
          self
        end

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
