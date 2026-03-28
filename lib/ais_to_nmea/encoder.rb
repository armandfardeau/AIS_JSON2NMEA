# frozen_string_literal: true

module AisToNmea
  # Generic encoder that dispatches to a message-specific encoder.
  class Encoder
    def initialize(data:, options: {})
      @data = data
      @options = options
    end

    def encode
      data = MessageType.parse_input(@data)
      message_type = MessageType.detect(data)
      encoder_key = EncoderFactory.key_for_message_type(message_type)

      EncoderFactory.build(data: data, options: @options, encoder: encoder_key).encode
    rescue InvalidJsonError, MissingFieldError, InvalidFieldError, UnsupportedMessageTypeError
      raise
    rescue StandardError => e
      raise EncodingFailureError, e.message
    end
  end
end
