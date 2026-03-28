# frozen_string_literal: true

require 'json'
require 'zeitwerk'

loader = Zeitwerk::Loader.for_gem
loader.setup
loader.eager_load

# Main namespace for AIS to NMEA conversion helpers and public APIs.
module AisToNmea
  # Convenience method for simple usage
  #
  # @param input [String, Hash] JSON string or Ruby Hash
  # @param options [Hash] Additional options
  # @return [String] NMEA sentence(s)
  def self.to_nmea(input, options = {})
    if options.key?(:encoder)
      EncoderFactory.build(options).encode(input, options)
    else
      Encoder.new.encode(input, options)
    end
  end
end
