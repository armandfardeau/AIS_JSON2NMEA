# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module SafetyBroadcastMessage
      # Encodes the broadcast text payload for a safety message.
      class Text < Base
        normalize_value_as :string

        def validate!
          raise MissingFieldError, 'Missing required field: Text' if @value.nil?

          self
        end

        def pack
          AisToNmea::AisEncoder::Utils::Text.encode_ais_text(@value, max_length: 156)
        end
      end
    end
  end
end
