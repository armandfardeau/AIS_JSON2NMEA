#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '_helper'

safety_message = {
  'MessageID' => 14,
  'RepeatIndicator' => 1,
  'UserID' => 123_456_789,
  'Valid' => true,
  'Spare' => 0,
  'Text' => 'SECURITE NAVIGATION - SHALLOW WATER AHEAD'
}

safety_message_json = <<~JSON
  {
    "MessageID": 14,
    "RepeatIndicator": 2,
    "UserID": 987654321,
    "Valid": true,
    "Spare": 1,
    "Text": "ROCKS REPORTED 2NM EAST OF FAIRWAY"
  }
JSON

ExampleHelper.print_case('Safety broadcast message - flat payload', safety_message)
ExampleHelper.print_case(
  'Safety broadcast message - JSON string payload (explicit encoder)',
  safety_message_json,
  encoder: :safety_broadcast_message
)
