# frozen_string_literal: true

require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
  minimum_coverage 90
end

require 'rspec'
require 'json'

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
end
