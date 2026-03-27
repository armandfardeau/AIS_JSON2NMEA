module AisToNmea
  # Encoder dedicated to AIS Ship Static Data (type 5)
  class ShipStaticDataEncoder
    def encode(input, options = {})
      data = MessageType.parse_input(input)
      message_type = MessageType.detect(data)
      message_data = data.key?('Message') ? data['Message'] : data

      unless message_type == 5
        raise UnsupportedMessageTypeError, "MessageID must be 5 for ShipStaticData, got: #{message_type}"
      end

      AisEncoder.encode_ship_static_data(message_type, message_data)
    rescue InvalidJsonError, MissingFieldError, InvalidFieldError, UnsupportedMessageTypeError
      raise
    rescue StandardError => e
      raise EncodingFailureError, e.message
    end
  end
end
