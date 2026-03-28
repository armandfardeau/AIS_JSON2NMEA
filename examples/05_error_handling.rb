#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '_helper'

missing_user_id = {
  'MessageID' => 1,
  'Latitude' => 48.8566,
  'Longitude' => 2.3522,
  'SpeedOverGround' => 12.3,
  'CourseOverGround' => 254.8,
  'TrueHeading' => 255
}

invalid_latitude = {
  'MessageID' => 1,
  'UserID' => 123_456_789,
  'Latitude' => 95.0,
  'Longitude' => 2.3522,
  'SpeedOverGround' => 12.3,
  'CourseOverGround' => 254.8,
  'TrueHeading' => 255
}

ExampleHelper.print_expected_error('Error handling - missing required field') do
  AisToNmea.to_nmea(missing_user_id)
end

ExampleHelper.print_expected_error('Error handling - out-of-range value') do
  AisToNmea.to_nmea(invalid_latitude)
end
