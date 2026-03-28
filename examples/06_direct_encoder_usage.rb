#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '_helper'

message = {
  'MessageID' => 1,
  'UserID' => 555_555_555,
  'Latitude' => 37.7749,
  'Longitude' => -122.4194,
  'SpeedOverGround' => 13.1,
  'CourseOverGround' => 318.2,
  'TrueHeading' => 320
}

puts "#{'=' * 70}"
puts 'Using AisToNmea::Encoder directly'
puts "#{'=' * 70}"
puts 'Input:'
puts JSON.pretty_generate(message)

result = AisToNmea::Encoder.new(data: message).encode

puts '\nOutput (NMEA 0183):'
puts result
