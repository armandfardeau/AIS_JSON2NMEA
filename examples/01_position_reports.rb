#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '_helper'

position_type_1 = {
  **ExampleHelper.base_position_report
}

position_type_2 = ExampleHelper.base_position_report(
  message_id: 2,
  user_id: 111_111_111,
  latitude: 40.7128,
  longitude: -74.0060,
  speed_over_ground: 15.8,
  course_over_ground: 45.5,
  true_heading: 46
)

position_type_3 = ExampleHelper.base_position_report(
  message_id: 3,
  user_id: 222_222_222,
  latitude: 35.6762,
  longitude: 139.6503,
  speed_over_ground: 0.0,
  course_over_ground: 0.0,
  true_heading: 511
)

ExampleHelper.print_case('Position report - message type 1', position_type_1)
ExampleHelper.print_case('Position report - message type 2', position_type_2)
ExampleHelper.print_case('Position report - message type 3', position_type_3)
