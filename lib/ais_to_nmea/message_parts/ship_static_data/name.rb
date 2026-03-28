# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module ShipStaticData
      # Encodes the vessel name field for ship static data.
      class Name < Base
        normalize_value_as :string

        def validate!
          raise MissingFieldError, 'Missing required field: Name' if @value.nil?

          self
        end

        def pack
          AisToNmea::AisEncoder::Utils::Text.encode_ais_text_fixed(
            @value,
            length: 20,
            field_name: 'Name'
          )
        end
      end
    end
  end
end
