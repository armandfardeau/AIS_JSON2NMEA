# frozen_string_literal: true

module AisToNmea
  module Encoders
    # Base class shared by all AIS encoder implementations.
    class Base
      attr_reader :message

      def initialize
        @message = +''
      end

      private

      def add_part(part)
        @message << part
      end
    end
  end
end
