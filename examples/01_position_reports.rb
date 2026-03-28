#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '_helper'

position_type_1 = {
  'MessageID' => 1,
  'UserID' => 123_456_789,
  'Latitude' => 48.8566,
  'Longitude' => 2.3522,
  'SpeedOverGround' => 12.3,
  'CourseOverGround' => 254.8,
  'TrueHeading' => 255
}

position_type_2 = {
  'MessageID' => 2,
  'UserID' => 111_111_111,
  'Latitude' => 40.7128,
  'Longitude' => -74.0060,
  'SpeedOverGround' => 15.8,
  'CourseOverGround' => 45.5,
  'TrueHeading' => 46
}

position_type_3 = {
  'MessageID' => 3,
  'UserID' => 222_222_222,
  'Latitude' => 35.6762,
  'Longitude' => 139.6503,
  'SpeedOverGround' => 0.0,
  'CourseOverGround' => 0.0,
  'TrueHeading' => 511
}

ExampleHelper.print_case('Position report - message type 1', position_type_1)
ExampleHelper.print_case('Position report - message type 2', position_type_2)
ExampleHelper.print_case('Position report - message type 3', position_type_3)
