module AisToNmea
  module MessageParts
    module PositionReport
      class Longitude
        attr_reader :value

        def initialize(data = nil, value = nil)
          @data = data
          @value = value
        end

        def extract
          @value = AisToNmea::AisEncoder::Utils::Input.required_float(@data, 'Longitude')
          self
        end

        def validate!
          self
        end

        def pack
          AisToNmea::AisEncoder::Utils::BitPacking.pack_signed((@value * 600000).round, 28)
        end
      end
    end
  end
end
