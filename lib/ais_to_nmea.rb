# frozen_string_literal: true

require 'json'
require 'zeitwerk'

loader = Zeitwerk::Loader.for_gem
loader.setup

# Load error classes first to make them available to all modules
require_relative 'ais_to_nmea/error'

# Main namespace for AIS to NMEA conversion helpers and public APIs.
module AisToNmea
  # Convenience method for simple usage
  #
  # @param data [Hash] JSON string or Ruby Hash
  # @param options [Hash] Additional options
  # @return [String] NMEA sentence(s)
  def self.to_nmea(data, options: {}, encoder: nil)
    if encoder
      EncoderFactory.build(data: data, options: options, encoder: encoder).encode
    else
      Encoder.new(data: data, options: options).encode
    end
  end
end
