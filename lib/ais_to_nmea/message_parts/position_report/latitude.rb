module AisToNmea
  module MessageParts
    module PositionReport
      class Latitude
        attr_reader :value

        def initialize(data = nil, value = nil)
          @data = data
          @value = value
        end

        def extract
          @value = AisToNmea::AisEncoder::Utils::Input.required_float(@data, 'Latitude')
          self
        end

        def validate!
          unless @value.between?(-90.0, 90.0)
            raise InvalidFieldError, "Latitude must be between -90 and 90 (got: #{@value.inspect})"
          end

          self
        end

        def pack
          AisToNmea::AisEncoder::Utils::BitPacking.pack_signed((value * 600000).round, 27)
        end
      end
    end
  end
end
