# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module SafetyBroadcastMessage
      # Encodes the broadcast text payload for a safety message.
      class Text
        attr_reader :value

        def initialize(data = nil, value = nil)
          @data = data
          @value = value
        end

        def extract
          present, value = AisToNmea::AisEncoder::Utils::Input.value_for_key(@data, 'Text')
          @value = present ? value : nil
          self
        end

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
