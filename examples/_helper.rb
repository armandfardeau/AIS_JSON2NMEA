# frozen_string_literal: true

begin
  require 'ais_to_nmea'
rescue LoadError
  require_relative '../lib/ais_to_nmea'
end
require 'json'

# Helper methods for AIS to NMEA examples, including test data generation and output formatting.
module ExampleHelper
  # rubocop:disable Metrics/ParameterLists
  def self.base_position_report(message_id: 1, user_id: 123_456_789, latitude: 48.8566, longitude: 2.3522,
                                speed_over_ground: 12.3, course_over_ground: 254.8, true_heading: 255)
    {
      'MessageID' => message_id,
      'RepeatIndicator' => 0,
      'UserID' => user_id,
      'NavigationalStatus' => 0,
      'RateOfTurn' => 128,
      'SpeedOverGround' => speed_over_ground,
      'PositionAccuracy' => 0,
      'Longitude' => longitude,
      'Latitude' => latitude,
      'CourseOverGround' => course_over_ground,
      'TrueHeading' => true_heading,
      'Timestamp' => 0,
      'SpecialManoeuvreIndicator' => 0,
      'Spare' => 0,
      'Raim' => 0,
      'RadioStatus' => 0
    }
  end
  # rubocop:enable Metrics/ParameterLists

  def self.print_case(title, payload, **)
    puts "\n#{'=' * 70}"
    puts title
    puts('=' * 70)
    puts 'Input:'
    puts payload.is_a?(String) ? payload : JSON.pretty_generate(payload)

    output = AisToNmea.to_nmea(payload, **)

    puts
    puts 'Output (NMEA 0183):'
    puts output
  end

  def self.print_expected_error(title)
    puts "\n#{'=' * 70}"
    puts title
    puts('=' * 70)

    yield
  rescue AisToNmea::Error => e
    puts "Expected error: #{e.class} - #{e.message}"
  end
end
