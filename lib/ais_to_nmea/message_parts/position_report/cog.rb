module AisToNmea
  module MessageParts
    module PositionReport
      class Cog
        def self.extract(value, packed: false)
          if packed
            AisToNmea::AisEncoder::Utils::BitPacking.pack_uint((value * 10).round, 12)
          else
            AisToNmea::AisEncoder::Utils::Input.required_float_from(
              value,
              ['Cog', 'CourseOverGround'],
              field_name: 'Cog/CourseOverGround'
            )
          end
        end
      end
    end
  end
end
