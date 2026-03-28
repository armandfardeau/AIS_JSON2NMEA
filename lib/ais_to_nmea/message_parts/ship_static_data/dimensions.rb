# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module ShipStaticData
      # Encodes the vessel dimension fields for ship static data.
      class Dimensions
        attr_reader :value

        def initialize(data = nil, value = nil)
          @data = data
          @value = value
        end

        def extract
          @value = build_dimension_values(normalized_dimension)
          self
        rescue ArgumentError, TypeError
          raise InvalidFieldError, 'Invalid integer value in Dimension'
        end

        def validate!
          validate_component!(@value[:a], min: 0, max: 511, key: 'Dimension.A')
          validate_component!(@value[:b], min: 0, max: 511, key: 'Dimension.B')
          validate_component!(@value[:c], min: 0, max: 63, key: 'Dimension.C')
          validate_component!(@value[:d], min: 0, max: 63, key: 'Dimension.D')
          self
        end

        def pack
          {
            a: AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(@value[:a], 9),
            b: AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(@value[:b], 9),
            c: AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(@value[:c], 6),
            d: AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(@value[:d], 6)
          }
        end

        private

        def fetch_dimension(dimension, key, default)
          if dimension.key?(key)
            Integer(dimension[key])
          elsif dimension.key?(key.to_sym)
            Integer(dimension[key.to_sym])
          else
            default
          end
        end

        def validate_component!(value, min:, max:, key:)
          return if value.between?(min, max)

          raise InvalidFieldError, "#{key} must be between #{min} and #{max} (got: #{value.inspect})"
        end

        def normalized_dimension
          present, dimension_value = AisToNmea::AisEncoder::Utils::Input.value_for_key(@data, 'Dimension')
          present && dimension_value.is_a?(Hash) ? dimension_value : {}
        end

        def build_dimension_values(dimension)
          {
            a: fetch_dimension(dimension, 'A', 0),
            b: fetch_dimension(dimension, 'B', 0),
            c: fetch_dimension(dimension, 'C', 0),
            d: fetch_dimension(dimension, 'D', 0)
          }
        end
      end
    end
  end
end
