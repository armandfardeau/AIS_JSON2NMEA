module AisToNmea
  module AisEncoder
    module Utils
      module Input
        def self.first_available(data, *keys)
          key = keys.find { |k| data.key?(k) }
          return [nil, nil] if key.nil?

          [key, data[key]]
        end

        def self.required_int(data, key)
          raise MissingFieldError, "Missing required field: #{key}" unless data.key?(key)

          Integer(data[key])
        rescue ArgumentError, TypeError
          raise InvalidFieldError, "Invalid integer value for #{key}"
        end

        def self.required_int_from(data, keys, field_name:)
          key, value = first_available(data, *keys)
          raise MissingFieldError, "Missing required field: #{field_name}" if key.nil?

          Integer(value)
        rescue ArgumentError, TypeError
          raise InvalidFieldError, "Invalid integer value for #{field_name}"
        end

        def self.optional_int_from(data, keys, field_name:, default:)
          key, value = first_available(data, *keys)
          return default if key.nil?

          Integer(value)
        rescue ArgumentError, TypeError
          raise InvalidFieldError, "Invalid integer value for #{field_name}"
        end

        def self.required_float(data, key)
          raise MissingFieldError, "Missing required field: #{key}" unless data.key?(key)

          Float(data[key])
        rescue ArgumentError, TypeError
          raise InvalidFieldError, "Invalid numeric value for #{key}"
        end

        def self.required_float_from(data, keys, field_name:)
          key, value = first_available(data, *keys)
          raise MissingFieldError, "Missing required field: #{field_name}" if key.nil?

          Float(value)
        rescue ArgumentError, TypeError
          raise InvalidFieldError, "Invalid numeric value for #{field_name}"
        end
      end

      module Validation
        def self.validate_ranges!(lat, lon, sog, cog, heading, nav_status)
          raise InvalidFieldError, 'Latitude must be between -90 and 90' unless lat.between?(-90.0, 90.0)
          raise InvalidFieldError, 'Longitude must be between -180 and 180' unless lon.between?(-180.0, 180.0)
          raise InvalidFieldError, 'Sog/SpeedOverGround must be between 0 and 102.2' unless sog.between?(0.0, 102.2)
          raise InvalidFieldError, 'Cog/CourseOverGround must be between 0 and 359.9' unless cog.between?(0.0, 359.9)
          valid_heading = heading.between?(0, 359) || heading == 511
          raise InvalidFieldError, 'TrueHeading must be between 0 and 359 (or 511 for unavailable)' unless valid_heading
          raise InvalidFieldError, 'NavigationStatus/NavigationalStatus must be between 0 and 15' unless nav_status.between?(0, 15)
        end
      end

      module BitPacking
        def self.pack_uint(value, width)
          raise InvalidFieldError, "Value #{value} does not fit in #{width} bits" if value.negative? || value >= (1 << width)

          value.to_s(2).rjust(width, '0')
        end

        def self.pack_signed(value, width)
          min = -(1 << (width - 1))
          max = (1 << (width - 1)) - 1
          raise InvalidFieldError, "Signed value #{value} does not fit in #{width} bits" unless value.between?(min, max)

          encoded = value.negative? ? ((1 << width) + value) : value
          encoded.to_s(2).rjust(width, '0')
        end
      end

      module SixBit
        def self.encode(bit_string)
          fill_bits = (6 - (bit_string.length % 6)) % 6
          padded = bit_string + ('0' * fill_bits)
          payload = padded.scan(/.{6}/).map { |chunk| self.char(chunk.to_i(2)) }.join
          [payload, fill_bits]
        end

        def self.char(value)
          c = value + 48
          c += 8 if c > 87
          c.chr
        end
      end

      module Nmea
        def self.build_sentences(payload, fill_bits)
          max_payload = 60
          parts = payload.scan(/.{1,#{max_payload}}/)
          total = parts.length
          seq_id = 0

          result = parts.each_with_index.map do |part, idx|
            part_fill = (idx == total - 1) ? fill_bits : 0
            content = "AIVDM,#{total},#{idx + 1},#{seq_id},A,#{part},#{part_fill}"
            checksum = self.checksum(content)
            "!#{content}*#{checksum}"
          end.join("\n")

          "#{result}\n"
        end

        def self.checksum(content)
          value = content.each_byte.reduce(0) { |acc, byte| acc ^ byte }
          format('%02X', value)
        end
      end

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
