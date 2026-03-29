# frozen_string_literal: true

module AisToNmea
  module AisEncoder
    module Utils
      # Base class shared by all AIS encoder implementations.
      module InputParser
        # Parse JSON string or Hash input
        #
        # @param input [String, Hash] JSON string or Ruby Hash
        # @return [Hash] Parsed data
        # @raise [InvalidJsonError] if input is invalid JSON
        def self.parse_input(input)
          return input if input.is_a?(Hash)
          return parse_json_input(input) if input.is_a?(String)

          raise InvalidJsonError, 'Input must be a JSON string or Hash'
        end

        def self.parse_json_input(input)
          JSON.parse(input)
        rescue JSON::ParserError => e
          raise InvalidJsonError, "Invalid JSON: #{e.message}"
        end
      end
    end
  end
end
