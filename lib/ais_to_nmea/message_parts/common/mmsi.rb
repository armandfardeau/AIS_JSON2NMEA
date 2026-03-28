# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module Common
      class Mmsi
        attr_reader :value

        def initialize(data = nil, value = nil)
          @data = data
          @value = value
        end

        def extract
          @value = AisToNmea::AisEncoder::Utils::Input.required_int(@data, 'UserID')
          self
        end

        def validate!
          return self if @value.between?(0, 1_073_741_823)

          raise InvalidFieldError, "UserID must be between 0 and 1073741823 (got: #{@value.inspect})"
        end

        def pack
          AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(@value, 30)
        end
      end
    end
  end
end
