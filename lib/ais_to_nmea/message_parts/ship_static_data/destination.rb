# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module ShipStaticData
      # Encodes the destination field for ship static data.
      class Destination
        attr_reader :value

        def initialize(data = nil, value = nil)
          @data = data
          @value = value
        end

        def extract
          present, value = AisToNmea::AisEncoder::Utils::Input.value_for_key(@data, 'Destination')
          raise MissingFieldError, 'Missing required field: Destination' unless present

          @value = value
          self
        end

        def validate!
          raise MissingFieldError, 'Missing required field: Destination' if @value.nil?

          @value = @value.to_s
          self
        end

        def pack
          AisToNmea::AisEncoder::Utils::Text.encode_ais_text_fixed(
            @value,
            length: 20,
            field_name: 'Destination'
          )
        end
      end
    end
  end
end
