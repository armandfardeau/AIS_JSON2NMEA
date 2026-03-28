# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module Common
      class MessageId
        attr_reader :value

        def initialize(data = nil, value = nil)
          @data = data
          @value = value
        end

        def extract
          @value = Integer(@data)
          self
        rescue ArgumentError, TypeError
          raise InvalidFieldError, 'Invalid integer value for MessageID'
        end

        def validate!
          return self if @value.between?(0, 63)

          raise InvalidFieldError, "MessageID must be between 0 and 63 (got: #{@value.inspect})"
        end

        def pack
          AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(@value, 6)
        end
      end
    end
  end
end
