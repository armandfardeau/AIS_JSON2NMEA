#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '_helper'

hash_input = {
  'MessageID' => 1,
  'UserID' => 333_333_333,
  'Latitude' => 60.1699,
  'Longitude' => 18.6414,
  'SpeedOverGround' => 10.5,
  'CourseOverGround' => 90.0,
  'TrueHeading' => 90
}

json_string_input = <<~JSON
  {
    "MessageID": 1,
    "UserID": 987654321,
    "Latitude": 51.5074,
    "Longitude": -0.1278,
    "SpeedOverGround": 8.5,
    "CourseOverGround": 123.4,
    "TrueHeading": 120
  }
JSON

nested_message = {
  'MessageType' => 'PositionReport',
  'Message' => {
    'MessageID' => 1,
    'UserID' => 444_444_444,
    'Latitude' => -33.8688,
    'Longitude' => 151.2093,
    'SpeedOverGround' => 20.1,
    'CourseOverGround' => 270.0,
    'TrueHeading' => 270
  }
}

ExampleHelper.print_case('Input format - Ruby hash', hash_input)
ExampleHelper.print_case('Input format - JSON string', json_string_input)
ExampleHelper.print_case('Input format - nested message', nested_message)
