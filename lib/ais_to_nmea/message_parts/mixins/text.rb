# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module Mixins
      # Bit packing helpers for AIS field serialization.
      module Text
        def encode_ais_text(max_length:)
          Encodings::Text.encode_ais_text(@value, max_length: max_length)
        end

        def encode_ais_text_fixed(length:, field_name:)
          Encodings::Text.encode_ais_text_fixed(@value, length: length, field_name: field_name)
        end
      end
    end
  end
end
