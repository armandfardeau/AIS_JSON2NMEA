module AisToNmea
  module Encoders
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