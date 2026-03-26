require 'json'
require_relative 'ais_to_nmea/version'
require_relative 'ais_to_nmea/errors'
require_relative 'ais_to_nmea/message_type'
require_relative 'ais_to_nmea/utils'
require_relative 'ais_to_nmea/position_report_encoder'
require_relative 'ais_to_nmea/safety_broadcast_message_encoder'
require_relative 'ais_to_nmea/encoder'
require_relative 'ais_to_nmea/encoder_factory'

module AisToNmea
  module AisEncoder
    def self.encode_position_report(message_type, data)
      mmsi = Utils::Input.required_int(data, 'UserID')
      lat = Utils::Input.required_float(data, 'Latitude')
      lon = Utils::Input.required_float(data, 'Longitude')
      sog = Utils::Input.required_float(data, 'Sog')
      cog = Utils::Input.required_float(data, 'Cog')
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

    def self.encode_safety_broadcast_message(message_type, data)
      mmsi = Utils::Input.required_int(data, 'UserID')
      repeat_indicator = data.fetch('RepeatIndicator', 0).to_i
      spare = data.fetch('Spare', 0).to_i
      text_bits = Utils::Text.encode_ais_text(data['Text'], max_length: 156)

      unless repeat_indicator.between?(0, 3)
        raise InvalidFieldError, 'RepeatIndicator must be between 0 and 3'
      end

      unless spare.between?(0, 3)
        raise InvalidFieldError, 'Spare must be between 0 and 3'
      end

      bits = +''
      bits << Utils::BitPacking.pack_uint(message_type, 6)
      bits << Utils::BitPacking.pack_uint(repeat_indicator, 2)
      bits << Utils::BitPacking.pack_uint(mmsi, 30)
      bits << Utils::BitPacking.pack_uint(spare, 2)
      bits << text_bits

      payload, fill_bits = Utils::SixBit.encode(bits)
      Utils::Nmea.build_sentences(payload, fill_bits)
    end
  end

  # Convenience method for simple usage
  # 
  # @param input [String, Hash] JSON string or Ruby Hash
  # @param options [Hash] Additional options
  # @return [String] NMEA sentence(s)
  def self.to_nmea(input, options = {})
    if options.key?(:encoder)
      EncoderFactory.build(options).encode(input, options)
    else
      Encoder.new.encode(input, options)
    end
  end
end
