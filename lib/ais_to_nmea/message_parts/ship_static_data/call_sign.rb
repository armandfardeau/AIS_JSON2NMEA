# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module ShipStaticData
      # Encodes the call sign field for ship static data.
      class CallSign < Base
        normalize_value_as :string

        def validate!
          return self if @value.is_a?(String) && @value.length <= 7

          raise InvalidFieldError,
                "CallSign must be a string with a maximum length of 7 characters (got: #{@value.inspect})"
        end

        def pack
          encode_ais_text_fixed(length: 7, field_name: 'CallSign')
        end
      end
    end
  end
end
