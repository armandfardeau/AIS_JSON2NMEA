# frozen_string_literal: true

require 'nmea_plus'

module AisToNmea
  module AisEncoder
    module Utils
      # Utility class for validating output values before encoding.
      module OutputValidator
        TYPE_MAPPINGS = {
            1 => :position_report,
            2 => :position_report,
            3 => :position_report,
        }.freeze

        MAPPINGS = {
          position_report: {
            latitude: :lat,
            longitude: :lon,
            speed_over_ground: :sog,
            course_over_ground: :cog,
            time_stamp: :timestamp
          }
        }.freeze

        def validate!(data, output)
          message = decoder.parse(output)

          mapping_for(message.ais.message_type).each do |nmea_plus_method, internal_method|
            expected_value = data.send(internal_method)
            actual_value = message.ais.send(nmea_plus_method)

            unless actual_value == expected_value
              raise InvalidFieldError,
                    "Validation failed for #{nmea_plus_method}: expected #{expected_value.inspect}, got #{actual_value.inspect}"
            end
          end
        end

        def decoder
          @decoder ||= NMEAPlus::Decoder.new
        end

        def mapping_for(message_id)
            type = TYPE_MAPPINGS[message_id]
            MAPPINGS.fetch(type) { raise UnsupportedMessageTypeError, "No mapping defined for message type: #{message_id}" }
        end

        def sned_based_on_data_type(message, method)
            if message.data_type == "VDM"
                message.ais.send(method)
            else
                message.send(method)
            end
        end
      end
    end
  end
end
