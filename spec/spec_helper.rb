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
    def fixture_json(file_name)
      path = File.join(__dir__, 'fixtures', file_name)
      JSON.parse(File.read(path))
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
