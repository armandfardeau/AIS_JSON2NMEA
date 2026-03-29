# frozen_string_literal: true

module AisToNmea
  # Generic encoder that dispatches to a message-specific encoder.
  class Encoder
    def initialize(data:)
      @data = data
    end

    def encode
      message_type = MessageType.detect(@data)
      encoder_key = EncoderFactory.key_for_message_type(message_type)

      EncoderFactory.build(data: @data, encoder: encoder_key).encode
    rescue InvalidJsonError, MissingFieldError, InvalidFieldError, UnsupportedMessageTypeError
      raise
    rescue StandardError => e
      raise EncodingFailureError, e.message
    end
  end
end
