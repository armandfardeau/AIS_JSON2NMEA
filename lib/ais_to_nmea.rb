# frozen_string_literal: true

require 'json'
require_relative 'ais_to_nmea/version'
require_relative 'ais_to_nmea/errors'
require_relative 'ais_to_nmea/message_type'
require_relative 'ais_to_nmea/utils'
require_relative 'ais_to_nmea/encoders/base'
require_relative 'ais_to_nmea/encoders/position_report'
require_relative 'ais_to_nmea/encoders/ship_static_data'
require_relative 'ais_to_nmea/encoders/safety_broadcast_message'
require_relative 'ais_to_nmea/encoder'
require_relative 'ais_to_nmea/encoder_factory'
require_relative 'ais_to_nmea/message_parts/common'
require_relative 'ais_to_nmea/message_parts/common/message_id'
require_relative 'ais_to_nmea/message_parts/common/mmsi'

require_relative 'ais_to_nmea/message_parts/position_report'
require_relative 'ais_to_nmea/message_parts/position_report/latitude'
require_relative 'ais_to_nmea/message_parts/position_report/longitude'
require_relative 'ais_to_nmea/message_parts/position_report/sog'
require_relative 'ais_to_nmea/message_parts/position_report/cog'
require_relative 'ais_to_nmea/message_parts/position_report/heading'
require_relative 'ais_to_nmea/message_parts/position_report/navigation_status'
require_relative 'ais_to_nmea/message_parts/position_report/repeat_indicator'
require_relative 'ais_to_nmea/message_parts/position_report/rot'
require_relative 'ais_to_nmea/message_parts/position_report/position_accuracy'
require_relative 'ais_to_nmea/message_parts/position_report/timestamp'
require_relative 'ais_to_nmea/message_parts/position_report/maneuver'
require_relative 'ais_to_nmea/message_parts/position_report/spare'
require_relative 'ais_to_nmea/message_parts/position_report/raim'
require_relative 'ais_to_nmea/message_parts/position_report/radio_status'

require_relative 'ais_to_nmea/message_parts/safety_broadcast_message'
require_relative 'ais_to_nmea/message_parts/safety_broadcast_message/repeat_indicator'
require_relative 'ais_to_nmea/message_parts/safety_broadcast_message/spare'
require_relative 'ais_to_nmea/message_parts/safety_broadcast_message/text'

require_relative 'ais_to_nmea/message_parts/ship_static_data'
require_relative 'ais_to_nmea/message_parts/ship_static_data/call_sign'
require_relative 'ais_to_nmea/message_parts/ship_static_data/name'
require_relative 'ais_to_nmea/message_parts/ship_static_data/destination'
require_relative 'ais_to_nmea/message_parts/ship_static_data/dte'
require_relative 'ais_to_nmea/message_parts/ship_static_data/spare'
require_relative 'ais_to_nmea/message_parts/ship_static_data/repeat_indicator'
require_relative 'ais_to_nmea/message_parts/ship_static_data/ais_version'
require_relative 'ais_to_nmea/message_parts/ship_static_data/imo_number'
require_relative 'ais_to_nmea/message_parts/ship_static_data/ship_type'
require_relative 'ais_to_nmea/message_parts/ship_static_data/dimensions'
require_relative 'ais_to_nmea/message_parts/ship_static_data/fix_type'
require_relative 'ais_to_nmea/message_parts/ship_static_data/maximum_static_draught'
require_relative 'ais_to_nmea/message_parts/ship_static_data/etas'
require_relative 'ais_to_nmea/message_parts/ship_static_data/etas/eta'
require_relative 'ais_to_nmea/message_parts/ship_static_data/etas/month'
require_relative 'ais_to_nmea/message_parts/ship_static_data/etas/day'
require_relative 'ais_to_nmea/message_parts/ship_static_data/etas/hour'
require_relative 'ais_to_nmea/message_parts/ship_static_data/etas/minute'

module AisToNmea
  module AisEncoder
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
