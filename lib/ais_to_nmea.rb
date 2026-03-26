require 'json'
require_relative 'ais_to_nmea/version'
require_relative 'ais_to_nmea/errors'
require_relative 'ais_to_nmea/message_type'

module AisToNmea
  module AisEncoder
    module Utils
      module Input
        module_function

        def required_int(data, key)
          raise MissingFieldError, "Missing required field: #{key}" unless data.key?(key)

          Integer(data[key])
        rescue ArgumentError, TypeError
          raise InvalidFieldError, "Invalid integer value for #{key}"
        end

        def required_float(data, key)
          raise MissingFieldError, "Missing required field: #{key}" unless data.key?(key)

          Float(data[key])
        rescue ArgumentError, TypeError
          raise InvalidFieldError, "Invalid numeric value for #{key}"
        end
      end

      module Validation
        module_function

        def validate_ranges!(lat, lon, sog, cog, heading, nav_status)
          raise InvalidFieldError, 'Latitude must be between -90 and 90' unless lat.between?(-90.0, 90.0)
          raise InvalidFieldError, 'Longitude must be between -180 and 180' unless lon.between?(-180.0, 180.0)
          raise InvalidFieldError, 'SpeedOverGround must be between 0 and 102.2' unless sog.between?(0.0, 102.2)
          raise InvalidFieldError, 'CourseOverGround must be between 0 and 359.9' unless cog.between?(0.0, 359.9)
          valid_heading = heading.between?(0, 359) || heading == 511
          raise InvalidFieldError, 'TrueHeading must be between 0 and 359 (or 511 for unavailable)' unless valid_heading
          raise InvalidFieldError, 'NavigationStatus must be between 0 and 15' unless nav_status.between?(0, 15)
        end
      end

      module BitPacking
        module_function

        def pack_uint(value, width)
          raise InvalidFieldError, "Value #{value} does not fit in #{width} bits" if value.negative? || value >= (1 << width)

          value.to_s(2).rjust(width, '0')
        end

        def pack_signed(value, width)
          min = -(1 << (width - 1))
          max = (1 << (width - 1)) - 1
          raise InvalidFieldError, "Signed value #{value} does not fit in #{width} bits" unless value.between?(min, max)

          encoded = value.negative? ? ((1 << width) + value) : value
          encoded.to_s(2).rjust(width, '0')
        end
      end

      module SixBit
        module_function

        def encode(bit_string)
          fill_bits = (6 - (bit_string.length % 6)) % 6
          padded = bit_string + ('0' * fill_bits)
          payload = padded.scan(/.{6}/).map { |chunk| char(chunk.to_i(2)) }.join
          [payload, fill_bits]
        end

        def char(value)
          c = value + 48
          c += 8 if c > 87
          c.chr
        end
      end

      module Nmea
        module_function

        def build_sentences(payload, fill_bits)
          max_payload = 60
          parts = payload.scan(/.{1,#{max_payload}}/)
          total = parts.length
          seq_id = 0

          result = parts.each_with_index.map do |part, idx|
            part_fill = (idx == total - 1) ? fill_bits : 0
            content = "AIVDM,#{total},#{idx + 1},#{seq_id},A,#{part},#{part_fill}"
            checksum = checksum(content)
            "!#{content}*#{checksum}"
          end.join("\n")

          "#{result}\n"
        end

        def checksum(content)
          value = content.each_byte.reduce(0) { |acc, byte| acc ^ byte }
          format('%02X', value)
        end
      end
    end

    module_function

    def encode_position_report(message_type, data)
      mmsi = Utils::Input.required_int(data, 'UserID')
      lat = Utils::Input.required_float(data, 'Latitude')
      lon = Utils::Input.required_float(data, 'Longitude')
      sog = Utils::Input.required_float(data, 'SpeedOverGround')
      cog = Utils::Input.required_float(data, 'CourseOverGround')
      heading = Utils::Input.required_int(data, 'TrueHeading')
      nav_status = data.fetch('NavigationStatus', 0).to_i

      Utils::Validation.validate_ranges!(lat, lon, sog, cog, heading, nav_status)

      bits = +''
      bits << Utils::BitPacking.pack_uint(message_type, 6)
      bits << Utils::BitPacking.pack_uint(0, 2) # repeat indicator
      bits << Utils::BitPacking.pack_uint(mmsi, 30)
      bits << Utils::BitPacking.pack_uint(nav_status, 4)
      bits << Utils::BitPacking.pack_uint(128, 8) # ROT unavailable
      bits << Utils::BitPacking.pack_uint((sog * 10).round, 10)
      bits << Utils::BitPacking.pack_uint(0, 1) # position accuracy
      bits << Utils::BitPacking.pack_signed((lon * 600000).round, 28)
      bits << Utils::BitPacking.pack_signed((lat * 600000).round, 27)
      bits << Utils::BitPacking.pack_uint((cog * 10).round, 12)
      bits << Utils::BitPacking.pack_uint(heading, 9)
      bits << Utils::BitPacking.pack_uint(0, 6) # timestamp
      bits << Utils::BitPacking.pack_uint(0, 2) # maneuver
      bits << Utils::BitPacking.pack_uint(0, 3) # spare
      bits << Utils::BitPacking.pack_uint(0, 1) # RAIM
      bits << Utils::BitPacking.pack_uint(0, 19) # radio status

      payload, fill_bits = Utils::SixBit.encode(bits)
      Utils::Nmea.build_sentences(payload, fill_bits)
    end
  end

  # Main API class for converting AIS JSON to NMEA sentences
  class Encoder
    # Convert AIS JSON message to NMEA 0183 sentence(s)
    #
    # @param input [String, Hash] JSON string or Ruby Hash containing AIS message data
    # @param options [Hash] Additional options (reserved for future use)
    #
    # @return [String] NMEA sentence(s), joined with newlines for multi-part
    #
    # @raise [InvalidJsonError] if JSON is malformed
    # @raise [MissingFieldError] if required fields are missing
    # @raise [InvalidFieldError] if field values are out of valid ranges
    # @raise [UnsupportedMessageTypeError] if message type is not 1, 2, or 3
    # @raise [EncodingError] if AIS encoding fails
    # @raise [MemoryError] if memory allocation fails
    #
    # Example:
    #   input = {
    #     "MessageID" => 1,
    #     "UserID" => 123456789,
    #     "Latitude" => 48.8566,
    #     "Longitude" => 2.3522,
    #     "SpeedOverGround" => 12.3,
    #     "CourseOverGround" => 254.8,
    #     "TrueHeading" => 255
    #   }
    #   encoder = AisToNmea::Encoder.new
    #   nmea = encoder.encode(input)
    #   puts nmea  # => "!AIVDM,1,1,,A,15M67...*XX"
    def encode(input, options = {})
      data = MessageType.parse_input(input)
      message_type = MessageType.detect(data)
      message_data = data.key?('Message') ? data['Message'] : data

      AisEncoder.encode_position_report(message_type, message_data)
    rescue InvalidJsonError, MissingFieldError, InvalidFieldError, UnsupportedMessageTypeError
      raise
    rescue StandardError => e
      raise EncodingError, e.message
    end
  end

  # Convenience method for simple usage
  # 
  # @param input [String, Hash] JSON string or Ruby Hash
  # @param options [Hash] Additional options
  # @return [String] NMEA sentence(s)
  def self.to_nmea(input, options = {})
    Encoder.new.encode(input, options)
  end
end
