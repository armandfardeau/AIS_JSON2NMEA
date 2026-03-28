# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module SafetyBroadcastMessage
      # Encodes the spare bits for a safety broadcast message.
      class Spare < Base
        normalize_value_as :integer

        def validate!
          return self if @value.between?(0, 3)

          raise InvalidFieldError, 'Spare must be between 0 and 3'
        end

        def pack
          AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(@value, 2)
        end
      end
    end
  end
end
