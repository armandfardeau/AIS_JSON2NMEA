#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '_helper'

message = ExampleHelper.base_position_report(
  user_id: 555_555_555,
  latitude: 37.7749,
  longitude: -122.4194,
  speed_over_ground: 13.1,
  course_over_ground: 318.2,
  true_heading: 320
)

puts('=' * 70)
puts 'Using AisToNmea::Encoder directly'
puts('=' * 70)
puts 'Input:'
puts JSON.pretty_generate(message)

result = AisToNmea::Encoder.new(data: message).encode

puts
puts 'Output (NMEA 0183):'
puts result
