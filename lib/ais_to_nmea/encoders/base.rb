# frozen_string_literal: true

module AisToNmea
  module Encoders
    # Base class shared by all AIS encoder implementations.
    class Base
      attr_reader :message

      def initialize(data: {}, options: {})
        @message = +''
        @data = data
        @options = options
      end

      private

      def add_part(part)
        @message << part
      end

      def add_parts(parts)
        parts.each { |part| add_part(part) }
      end
    end
  end
end
