module AisToNmea
  # Base error class for AIS to NMEA conversion
  class Error < StandardError; end

  # Raised when JSON input is invalid
  class InvalidJsonError < Error; end

  # Raised when an AIS message is missing required fields
  class MissingFieldError < Error; end

  # Raised when an AIS message field has an invalid value
  class InvalidFieldError < Error; end

  # Raised when the message type is not supported (must be 1, 2, or 3)
  class UnsupportedMessageTypeError < Error; end

  # Raised when AIS encoding fails
  class EncodingError < Error; end

  # Raised when memory allocation fails
  class MemoryError < Error; end
end
