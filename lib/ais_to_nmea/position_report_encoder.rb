module AisToNmea
  # Encoder dedicated to AIS Position Report messages (types 1, 2, 3)
  class PositionReportEncoder
    # Convert AIS JSON message to NMEA 0183 sentence(s)
    #
    # @param input [String, Hash] JSON string or Ruby Hash containing AIS message data
    # @param options [Hash] Additional options (reserved for future use)
    #
    # @return [String] NMEA sentence(s), joined with newlines for multi-part
    #
    # @raise [InvalidJsonError] if JSON is malformed
    # @raise [MissingFieldError] if required fields are missing
    # @raise [InvalidFieldError] if field values are out of valid ranges
    # @raise [UnsupportedMessageTypeError] if message type is not 1, 2, or 3
    # @raise [EncodingError] if AIS encoding fails
    # @raise [MemoryError] if memory allocation fails
    def encode(input, options = {})
      data = MessageType.parse_input(input)
      message_type = MessageType.detect(data)
      message_data = data.key?('Message') ? data['Message'] : data

      unless [1, 2, 3].include?(message_type)
        raise UnsupportedMessageTypeError,
              "MessageID must be 1, 2, or 3 for PositionReport, got: #{message_type}"
      end

      AisEncoder.encode_position_report(message_type, message_data)
    rescue InvalidJsonError, MissingFieldError, InvalidFieldError, UnsupportedMessageTypeError
      raise
    rescue StandardError => e
      raise EncodingFailureError, e.message
    end
  end
end