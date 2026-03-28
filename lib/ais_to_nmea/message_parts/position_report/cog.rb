# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module PositionReport
      class Cog
        attr_reader :value

        def initialize(data = nil, value = nil)
          @data = data
          @value = value
        end

        def extract
          @value = AisToNmea::AisEncoder::Utils::Input.required_float_from(
            @data,
            %w[Cog CourseOverGround],
            field_name: 'Cog/CourseOverGround'
          )
          self
        end

        def validate!
          self
        end

        def pack
          AisToNmea::AisEncoder::Utils::BitPacking.pack_uint((@value * 10).round, 12)
        end
      end
    end
  end
end
