# frozen_string_literal: true

require 'json'

module AisToNmea
  module Encoders
    # Base class shared by all AIS encoder implementations.
    class Base
      attr_reader :message

      def initialize(data: {}, options: {})
        @message = +''
        @raw_data = data
        @data = build_data_ir(data)
        @options = options
      end

      private

      def add_part(part)
        @message << part
      end

      def add_parts(parts)
        parts.each { |part| add_part(part) }
      end

      def build_data_ir(data)
        parse_input(data)
      end

      # Parse JSON string or Hash input
    #
    # @param input [String, Hash] JSON string or Ruby Hash
    # @return [Hash] Parsed data
    # @raise [InvalidJsonError] if input is invalid JSON
    def parse_input(input)
      return input if input.is_a?(Hash)
      return parse_json_input(input) if input.is_a?(String)

      raise InvalidJsonError, 'Input must be a JSON string or Hash'
    end

    def parse_json_input(input)
      JSON.parse(input)
    rescue JSON::ParserError => e
      raise InvalidJsonError, "Invalid JSON: #{e.message}"
    end
    end
  end
end
