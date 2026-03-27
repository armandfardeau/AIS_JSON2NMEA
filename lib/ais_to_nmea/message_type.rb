module AisToNmea
  # Utility module for detecting and working with AIS message types
  module MessageType
    SUPPORTED_TYPES = [1, 2, 3, 5, 14].freeze

    # Detect message type from JSON string or Hash
    # 
    # @param input [String, Hash] JSON string or Ruby Hash
    # @return [Integer] Supported message type
    # @raise [InvalidJsonError] if input is invalid JSON
    # @raise [UnsupportedMessageTypeError] if message type is not supported
    def self.detect(input)
      data = parse_input(input)
      
      # Try direct MessageID
      msg_id = data['MessageID'] || data[:MessageID]
      
      # Try nested Message.MessageID
      if msg_id.nil?
        nested = data['Message'] || data[:Message]
        msg_id = nested['MessageID'] || nested[:MessageID] if nested.is_a?(Hash)
      end
      
      if msg_id.nil?
        raise MissingFieldError, "Missing required field: MessageID"
      end

      msg_id = msg_id.to_i
      unless SUPPORTED_TYPES.include?(msg_id)
        raise UnsupportedMessageTypeError, 
              "MessageID must be one of #{SUPPORTED_TYPES.join(', ')}, got: #{msg_id}"
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
