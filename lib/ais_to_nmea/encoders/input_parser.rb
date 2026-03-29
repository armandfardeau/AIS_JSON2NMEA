# frozen_string_literal: true

module AisToNmea
  module Encoders
    # Parses supported encoder input formats into a normalized hash.
    class InputParser
      def self.parse(input)
        new(input).parse
      end

      def initialize(input)
        @input = input
      end

      def parse
        return @input if @input.is_a?(Hash)
        return parse_json_input if @input.is_a?(String)

        raise InvalidJsonError, 'Input must be a JSON string or Hash'
      end

      private

      def parse_json_input
        JSON.parse(@input)
      rescue JSON::ParserError => e
        raise InvalidJsonError, "Invalid JSON: #{e.message}"
      end
    end
  end
end
