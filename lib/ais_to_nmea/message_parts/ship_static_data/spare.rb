# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module ShipStaticData
      class Spare
        attr_reader :value

        def initialize(data = nil, value = nil)
          @data = data
          @value = value
        end

        def extract
          present, value = AisToNmea::AisEncoder::Utils::Input.value_for_key(@data, 'Spare')
          @value = present ? value : false
          self
        end

        def validate!
          @value = !@value.nil?
          self
        end

        def pack
          AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(@value ? 1 : 0, 1)
        end
      end
    end
  end
end
