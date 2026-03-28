# frozen_string_literal: true

require 'nmea_plus'

module AisToNmea
  module AisEncoder
    module Utils
      # Utility class for validating output values before encoding.
      module OutputValidator
        MAPPINGS = {
          5 => {
            latitude: :lat
          }
        }.freeze

        def validate!(data, output)
          message = decoder.parse(output)

          MAPPINGS[message.ais.message_type].each do |nmea_plus_method, internal_method|
            expected_value = data.fetch(internal_method.to_s)
            actual_value = message.send(nmea_plus_method)

            unless actual_value == expected_value
              raise InvalidFieldError,
                    "Validation failed for #{nmea_plus_method}: expected #{expected_value.inspect}, got #{actual_value.inspect}"
            end
          end
        end

        def decoder
          @decoder ||= NMEAPlus::Decoder.new
        end
      end
    end
  end
end
