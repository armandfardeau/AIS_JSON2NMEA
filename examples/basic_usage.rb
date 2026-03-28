#!/usr/bin/env ruby
# frozen_string_literal: true

#
# Example usage of the AisToNmea gem
#
# This demonstrates converting AIS JSON messages to NMEA 0183 sentences

begin
  require 'ais_to_nmea'
rescue LoadError
  # Allow running this example from the repository without installing the gem.
  require_relative '../lib/ais_to_nmea'
end
require 'json'

puts '=' * 70
puts 'AIS JSON to NMEA 0183 Conversion Examples'
puts '=' * 70
puts

# Example 1: Simple Position Report (Type 1) via Hash
puts 'Example 1: Position Report (Type 1) - Hash Input'
puts '-' * 70

position_report = {
  'MessageID' => 1,
  'UserID' => 123_456_789,
  'Latitude' => 48.8566,      # Paris latitude
  'Longitude' => 2.3522,      # Paris longitude
  'SpeedOverGround' => 12.3,
  'CourseOverGround' => 254.8,
  'TrueHeading' => 255
}

puts 'Input (Hash):'
puts JSON.pretty_generate(position_report)
puts

begin
  result = AisToNmea.to_nmea(position_report)
  puts 'Output (NMEA 0183):'
  puts result
  puts
rescue StandardError => e
  puts "Error: #{e.class} - #{e.message}"
  puts
end

# Example 2: Position Report via JSON string
puts 'Example 2: Position Report (Type 1) - JSON String Input'
puts '-' * 70

json_string = %(
{
  "MessageID": 1,
  "UserID": 987654321,
  "Latitude": 51.5074,         # London latitude
  "Longitude": -0.1278,        # London longitude
  "SpeedOverGround": 8.5,
  "CourseOverGround": 123.4,
  "TrueHeading": 120
}
)

puts 'Input (JSON String):'
puts json_string

begin
  result = AisToNmea.to_nmea(json_string)
  puts 'Output (NMEA 0183):'
  puts result
  puts
rescue StandardError => e
  puts "Error: #{e.class} - #{e.message}"
  puts
end

# Example 3: Type 2 - Position Report (assigned schedule)
puts 'Example 3: Position Report (Type 2) - Assigned Schedule'
puts '-' * 70

type_2_message = {
  'MessageID' => 2,
  'UserID' => 111_111_111,
  'Latitude' => 40.7128,       # New York latitude
  'Longitude' => -74.0060,     # New York longitude
  'SpeedOverGround' => 15.8,
  'CourseOverGround' => 45.5,
  'TrueHeading' => 46
}

puts 'Input (Type 2 Message):'
puts JSON.pretty_generate(type_2_message)
puts

begin
  result = AisToNmea.to_nmea(type_2_message)
  puts 'Output (NMEA 0183):'
  puts result
  puts
rescue StandardError => e
  puts "Error: #{e.class} - #{e.message}"
  puts
end

# Example 4: Type 3 - Position Report (response to interrogation)
puts 'Example 4: Position Report (Type 3) - Response to Interrogation'
puts '-' * 70

type_3_message = {
  'MessageID' => 3,
  'UserID' => 222_222_222,
  'Latitude' => 35.6762,       # Tokyo latitude
  'Longitude' => 139.6503,     # Tokyo longitude
  'SpeedOverGround' => 0.0,    # Moored
  'CourseOverGround' => 0.0,
  'TrueHeading' => 511         # Not available
}

puts 'Input (Type 3 Message):'
puts JSON.pretty_generate(type_3_message)
puts

begin
  result = AisToNmea.to_nmea(type_3_message)
  puts 'Output (NMEA 0183):'
  puts result
  puts
rescue StandardError => e
  puts "Error: #{e.class} - #{e.message}"
  puts
end

# Example 5: Nested Message structure
puts 'Example 5: Nested Message Structure'
puts '-' * 70

nested_message = {
  'MessageType' => 'PositionReport',
  'Message' => {
    'MessageID' => 1,
    'UserID' => 333_333_333,
    'Latitude' => 60.1699,      # Stockholm latitude
    'Longitude' => 18.6414,     # Stockholm longitude
    'SpeedOverGround' => 10.5,
    'CourseOverGround' => 90.0,
    'TrueHeading' => 90
  }
}

puts 'Input (Nested Structure):'
puts JSON.pretty_generate(nested_message)
puts

begin
  result = AisToNmea.to_nmea(nested_message)
  puts 'Output (NMEA 0183):'
  puts result
  puts
rescue StandardError => e
  puts "Error: #{e.class} - #{e.message}"
  puts
end

# Example 6: Error handling - Missing field
puts 'Example 6: Safety Broadcast Message (Type 14)'
puts '-' * 70

safety_broadcast_message = {
  'MessageID' => 14,
  'RepeatIndicator' => 1,
  'UserID' => 123_456_789,
  'Valid' => true,
  'Spare' => 0,
  'Text' => 'SECURITE NAVIGATION - SHALLOW WATER AHEAD'
}

puts 'Input (Type 14 Message):'
puts JSON.pretty_generate(safety_broadcast_message)
puts

begin
  result = AisToNmea.to_nmea(safety_broadcast_message)
  puts 'Output (NMEA 0183):'
  puts result
  puts
rescue StandardError => e
  puts "Error: #{e.class} - #{e.message}"
  puts
end

# Example 7: Error handling - Missing field
puts 'Example 7: Error Handling - Missing UserID'
puts '-' * 70

invalid_message = {
  'MessageID' => 1,
  # Missing UserID!
  'Latitude' => 48.8566,
  'Longitude' => 2.3522,
  'SpeedOverGround' => 12.3,
  'CourseOverGround' => 254.8,
  'TrueHeading' => 255
}

puts 'Input (Missing UserID):'
puts JSON.pretty_generate(invalid_message)
puts

begin
  result = AisToNmea.to_nmea(invalid_message)
  puts 'Output (NMEA 0183):'
  puts result
rescue AisToNmea::MissingFieldError => e
  puts "Error (Expected): #{e.class} - #{e.message}"
rescue StandardError => e
  puts "Error (Unexpected): #{e.class} - #{e.message}"
end
puts

# Example 8: Error handling - Out of range latitude
puts 'Example 8: Error Handling - Invalid Latitude'
puts '-' * 70

out_of_range_message = {
  'MessageID' => 1,
  'UserID' => 123_456_789,
  'Latitude' => 95.0, # Invalid! Must be [-90, 90]
  'Longitude' => 2.3522,
  'SpeedOverGround' => 12.3,
  'CourseOverGround' => 254.8,
  'TrueHeading' => 255
}

puts 'Input (Latitude out of range):'
puts JSON.pretty_generate(out_of_range_message)
puts

begin
  result = AisToNmea.to_nmea(out_of_range_message)
  puts 'Output (NMEA 0183):'
  puts result
rescue AisToNmea::InvalidFieldError => e
  puts "Error (Expected): #{e.class} - #{e.message}"
rescue StandardError => e
  puts "Error (Unexpected): #{e.class} - #{e.message}"
end
puts

# Example 9: Using encoder directly with options
puts 'Example 9: Using Encoder Class Directly'
puts '-' * 70

encoder = AisToNmea::Encoder.new

message = {
  'MessageID' => 1,
  'UserID' => 444_444_444,
  'Latitude' => -33.8688,      # Sydney latitude
  'Longitude' => 151.2093,     # Sydney longitude
  'SpeedOverGround' => 20.1,
  'CourseOverGround' => 270.0,
  'TrueHeading' => 270
}

puts 'Using AisToNmea::Encoder.new.encode():'
puts JSON.pretty_generate(message)
puts

begin
  result = encoder.encode(message)
  puts 'Output (NMEA 0183):'
  puts result
rescue StandardError => e
  puts "Error: #{e.class} - #{e.message}"
end
puts

puts '=' * 70
puts 'Examples completed!'
puts '=' * 70
