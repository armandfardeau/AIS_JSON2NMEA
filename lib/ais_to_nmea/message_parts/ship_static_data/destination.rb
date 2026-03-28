# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module ShipStaticData
      # Encodes the destination field for ship static data.
      class Destination < Base
        normalize_value_as :string

        def validate!
          raise MissingFieldError, 'Missing required field: Destination' if @value.nil?

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
