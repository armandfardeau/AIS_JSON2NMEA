#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '_helper'

hash_input = ExampleHelper.base_position_report(
  user_id: 333_333_333,
  latitude: 60.1699,
  longitude: 18.6414,
  speed_over_ground: 10.5,
  course_over_ground: 90.0,
  true_heading: 90
)

json_string_input = <<~JSON
  {
    "MessageID": 1,
    "RepeatIndicator": 0,
    "UserID": 987654321,
    "NavigationalStatus": 0,
    "RateOfTurn": 128,
    "Latitude": 51.5074,
    "Longitude": -0.1278,
    "SpeedOverGround": 8.5,
    "PositionAccuracy": 0,
    "CourseOverGround": 123.4,
    "TrueHeading": 120,
    "Timestamp": 0,
    "SpecialManoeuvreIndicator": 0,
    "Spare": 0,
    "Raim": 0,
    "RadioStatus": 0
  }
JSON

hash_with_explicit_encoder = ExampleHelper.base_position_report(
  user_id: 444_444_444,
  latitude: -33.8688,
  longitude: 151.2093,
  speed_over_ground: 20.1,
  course_over_ground: 270.0,
  true_heading: 270
)

ExampleHelper.print_case('Input format - Ruby hash', hash_input)
ExampleHelper.print_case('Input format - JSON string (explicit encoder)', json_string_input, encoder: :position_report)
ExampleHelper.print_case('Input format - hash with explicit encoder', hash_with_explicit_encoder,
                         encoder: :position_report)
