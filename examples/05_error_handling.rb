#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '_helper'

missing_user_id = ExampleHelper.base_position_report
missing_user_id.delete('UserID')

invalid_latitude = ExampleHelper.base_position_report(latitude: 95.0)

ExampleHelper.print_expected_error('Error handling - missing required field') do
  AisToNmea.to_nmea(missing_user_id)
end

ExampleHelper.print_expected_error('Error handling - out-of-range value') do
  AisToNmea.to_nmea(invalid_latitude)
end
