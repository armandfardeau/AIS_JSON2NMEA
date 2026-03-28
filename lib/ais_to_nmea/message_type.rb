# frozen_string_literal: true

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
    def self.detect(data)
      msg_id = extract_message_id(data)
      validate_supported_type!(msg_id)
      msg_id
    end

    def self.extract_message_id(data)
      msg_id = data['MessageID'] || data[:MessageID]
      return msg_id.to_i unless msg_id.nil?

      nested = data['Message'] || data[:Message]
      nested_msg_id = nested['MessageID'] || nested[:MessageID] if nested.is_a?(Hash)

      raise MissingFieldError, 'Missing required field: MessageID' if nested_msg_id.nil?

      nested_msg_id.to_i
    end

    def self.validate_supported_type!(msg_id)
      raise MissingFieldError, 'Missing required field: MessageID' if msg_id.nil?

      return if SUPPORTED_TYPES.include?(msg_id)

      raise UnsupportedMessageTypeError,
            "MessageID must be one of #{SUPPORTED_TYPES.join(', ')}, got: #{msg_id}"
    end
  end
end
