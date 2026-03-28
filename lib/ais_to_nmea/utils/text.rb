# frozen_string_literal: true

module AisToNmea
  module AisEncoder
    module Utils
      # Text encoding helpers for AIS six-bit character payloads.
      module Text
        AIS_CHARSET = '@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^- !"#$%&\'()*+,-./0123456789:;<=>?'

        def self.encode_ais_text(value, max_length:)
          raise MissingFieldError, 'Missing required field: Text' if value.nil?

          text = value.to_s.upcase
          raise InvalidFieldError, "Text is too long (max #{max_length} characters)" if text.length > max_length

          text.each_char.map do |char|
            idx = AIS_CHARSET.index(char)
            raise InvalidFieldError, "Unsupported AIS character: #{char}" if idx.nil?

            BitPacking.pack_uint(idx, 6)
          end.join
        end

        def self.encode_ais_text_fixed(value, length:, field_name:)
          raise MissingFieldError, "Missing required field: #{field_name}" if value.nil?

          text = value.to_s.upcase
          raise InvalidFieldError, "#{field_name} is too long (max #{length} characters)" if text.length > length

          padded = text.ljust(length, '@')
          padded.each_char.map do |char|
            idx = AIS_CHARSET.index(char)
            raise InvalidFieldError, "Unsupported AIS character in #{field_name}: #{char}" if idx.nil?

            BitPacking.pack_uint(idx, 6)
          end.join
        end
      end
    end
  end
end
