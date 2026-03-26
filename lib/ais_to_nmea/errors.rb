module AisToNmea
  # Base error class for AIS to NMEA conversion
  class Error < StandardError; end

  # Raised when JSON input is invalid
  class InvalidJsonError < Error; end

  # Raised when an AIS message is missing required fields
  class MissingFieldError < Error; end

  # Raised when an AIS message field has an invalid value
  class InvalidFieldError < Error; end

  # Raised when the message type is not supported
  class UnsupportedMessageTypeError < Error; end

  # Raised when AIS encoding fails
  class EncodingError < Error; end

  # Raised when an unexpected internal encoding exception occurs
  class EncodingFailureError < EncodingError; end

  # Raised when memory allocation fails
  class MemoryError < Error; end
end
