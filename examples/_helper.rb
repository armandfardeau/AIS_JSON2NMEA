# frozen_string_literal: true

begin
  require 'ais_to_nmea'
rescue LoadError
  require_relative '../lib/ais_to_nmea'
end
require 'json'

module ExampleHelper
  module_function

  def print_case(title, payload)
    puts "\n#{'=' * 70}"
    puts title
    puts "#{'=' * 70}"
    puts 'Input:'
    puts payload.is_a?(String) ? payload : JSON.pretty_generate(payload)

    output = if payload.is_a?(String)
               AisToNmea.to_nmea(payload)
             else
               AisToNmea.to_nmea(payload)
             end

    puts '\nOutput (NMEA 0183):'
    puts output
  end

  def print_expected_error(title)
    puts "\n#{'=' * 70}"
    puts title
    puts "#{'=' * 70}"

    yield
  rescue AisToNmea::Error => e
    puts "Expected error: #{e.class} - #{e.message}"
  end
end
