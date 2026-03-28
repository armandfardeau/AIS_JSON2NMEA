# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module PositionReport
      # Encodes the true heading field for a position report.
      class Heading
        attr_reader :value

        def initialize(data = nil, value = nil)
          @data = data
          @value = value
        end

        def extract
          @value = AisToNmea::AisEncoder::Utils::Input.required_int(@data, 'TrueHeading')
          self
        end

        def validate!
          self
        end

        def pack
          AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(@value, 9)
        end
      end
    end
  end
end
