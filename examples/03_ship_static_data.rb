#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '_helper'

ship_static_data = {
  'MessageID' => 5,
  'RepeatIndicator' => 0,
  'UserID' => 636_024_245,
  'Valid' => true,
  'AISVersion' => 0,
  'IMONumber' => 9_876_543,
  'CallSign' => 'FRA1234',
  'Name' => 'TEST VESSEL',
  'ShipType' => 70,
  'Dimension' => {
    'A' => 50,
    'B' => 20,
    'C' => 5,
    'D' => 5
  },
  'FixType' => 1,
  'Eta' => {
    'Month' => 12,
    'Day' => 31,
    'Hour' => 23,
    'Minute' => 59
  },
  'MaximumStaticDraught' => 7.4,
  'Destination' => 'LE HAVRE',
  'DTE' => false,
  'Spare' => false
}

ExampleHelper.print_case('Ship static data - message type 5', ship_static_data)
