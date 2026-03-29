# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module Common
      # Encodes the valid field for common data.
      class Valid < Base
        attr_reader :value

        def initialize(value = nil)
          super
          @value = value
        end

        def validate!
          raise MissingFieldError, 'Missing required field: Valid' if @value.nil?

          @value = @value.to_s
          self
        end

        def pack
          AisToNmea::AisEncoder::Utils::Text.encode_ais_text_fixed(
            @value,
            length: 7,
            field_name: 'Valid'
          )
        end
      end
    end
  end
end
