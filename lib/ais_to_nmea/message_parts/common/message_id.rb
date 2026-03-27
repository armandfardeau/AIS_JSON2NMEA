module AisToNmea
  module MessageParts
    module Common
      class MessageId
        def self.extract(message_type)
          AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(Integer(message_type), 6)
        rescue ArgumentError, TypeError
          raise InvalidFieldError, 'Invalid integer value for MessageID'
        end
      end
    end
  end
end
