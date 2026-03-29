# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module Common
      # Encodes the valid field for common data.
      class Valid < Base
        normalize_value_as :string

        def validate!
          raise MissingFieldError, 'Missing required field: Valid' if @value.nil?

          self
        end

        def pack
          encode_ais_text_fixed(length: 7, field_name: 'Valid')
        end
      end
    end
  end
end
