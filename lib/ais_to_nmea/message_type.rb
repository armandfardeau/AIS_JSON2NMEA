module AisToNmea
  # Utility module for detecting and working with AIS message types
  module MessageType
    SUPPORTED_TYPES = [1, 2, 3].freeze

    # Detect message type from JSON string or Hash
    # 
    # @param input [String, Hash] JSON string or Ruby Hash
    # @return [Integer] Message type (1, 2, or 3)
    # @raise [InvalidJsonError] if input is invalid JSON
    # @raise [UnsupportedMessageTypeError] if message type is not 1, 2, or 3
    def self.detect(input)
      data = parse_input(input)
      
      # Try direct MessageID
      msg_id = data["MessageID"]
      
      # Try nested Message.MessageID
      msg_id = data.dig("Message", "MessageID") if msg_id.nil?
      
      if msg_id.nil?
        raise MissingFieldError, "Missing required field: MessageID"
      end

      msg_id = msg_id.to_i
      unless SUPPORTED_TYPES.include?(msg_id)
        raise UnsupportedMessageTypeError, 
              "MessageID must be 1, 2, or 3, got: #{msg_id}"
      end

      msg_id
    end

    # Parse JSON string or Hash input
    #
    # @param input [String, Hash] JSON string or Ruby Hash
    # @return [Hash] Parsed data
    # @raise [InvalidJsonError] if input is invalid JSON
    def self.parse_input(input)
      case input
      when Hash
        input
      when String
        require 'json'
        JSON.parse(input)
      else
        raise InvalidJsonError, "Input must be a JSON string or Hash"
      end
    rescue JSON::ParserError => e
      raise InvalidJsonError, "Invalid JSON: #{e.message}"
    end
  end
end
