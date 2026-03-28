# frozen_string_literal: true

module AisToNmea
  # Generic encoder that dispatches to a message-specific encoder.
  class Encoder
    def encode(input, options = {})
      data = MessageType.parse_input(input)
      message_type = MessageType.detect(data)
      encoder_key = EncoderFactory.key_for_message_type(message_type)

      EncoderFactory.build(encoder: encoder_key).encode(data, options)
    rescue InvalidJsonError, MissingFieldError, InvalidFieldError, UnsupportedMessageTypeError
      raise
    rescue StandardError => e
      raise EncodingFailureError, e.message
    end
  end
end
