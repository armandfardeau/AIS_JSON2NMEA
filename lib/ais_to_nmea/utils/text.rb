module AisToNmea
  module AisEncoder
    module Utils
      module Text
        AIS_CHARSET = '@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^- !"#$%&\'()*+,-./0123456789:;<=>?'.freeze

        def self.encode_ais_text(value, max_length:)
          raise MissingFieldError, 'Missing required field: Text' if value.nil?

          text = value.to_s.upcase
          if text.length > max_length
            raise InvalidFieldError, "Text is too long (max #{max_length} characters)"
          end

          text.each_char.map do |char|
            idx = AIS_CHARSET.index(char)
            raise InvalidFieldError, "Unsupported AIS character: #{char}" if idx.nil?

            BitPacking.pack_uint(idx, 6)
          end.join
        end

        def self.encode_ais_text_fixed(value, length:, field_name:)
          raise MissingFieldError, "Missing required field: #{field_name}" if value.nil?

          text = value.to_s.upcase
          if text.length > length
            raise InvalidFieldError, "#{field_name} is too long (max #{length} characters)"
          end

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
