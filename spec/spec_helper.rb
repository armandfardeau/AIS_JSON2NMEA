# frozen_string_literal: true

require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
  minimum_coverage 90
end

require 'rspec'
require 'json'

module SpecSupport
  module Helpers
    MESSAGE_TYPE_FIXTURE_FILES = {
      position_report: 'message_types/position_report.json',
      safety_broadcast_message: 'message_types/safety_broadcast_message.json',
      ship_static_data: 'message_types/ship_static_data.json'
    }.freeze

    def fixture_json(file_name = nil, message_type: nil)
      return fixture_json_for_message_type(message_type) if message_type

      raise ArgumentError, 'file_name is required when message_type is not provided' if file_name.nil?

      path = File.join(__dir__, 'fixtures', file_name)
      JSON.parse(File.read(path))
    end

    def fixture_json_for_message_type(message_type)
      fixture_file = MESSAGE_TYPE_FIXTURE_FILES.fetch(message_type.to_sym) do
        valid_types = MESSAGE_TYPE_FIXTURE_FILES.keys.join(', ')
        raise ArgumentError, "Unknown message_type: #{message_type.inspect}. Expected one of: #{valid_types}"
      end

      fixture_json(fixture_file)
    end

    def expect_bit_string(value, width)
      expect(value).to be_a(String)
      expect(value).to match(/\A[01]{#{width}}\z/)
    end
  end
end

# Load the gem
$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'ais_to_nmea'

RSpec.configure do |config|
  config.color = true
  config.formatter = :progress

  # Allow expect syntax
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.include SpecSupport::Helpers
end
