# frozen_string_literal: true

module AisToNmea
  # Validation helpers for normalized AIS field values.
  module Validation
    RANGE_RULES = [
      [:lat, -90.0, 90.0, 'Latitude must be between -90 and 90'],
      [:lon, -180.0, 180.0, 'Longitude must be between -180 and 180'],
      [:sog, 0.0, 102.2, 'Sog/SpeedOverGround must be between 0 and 102.2'],
      [:cog, 0.0, 359.9, 'Cog/CourseOverGround must be between 0 and 359.9'],
      [:nav_status, 0, 15, 'NavigationStatus/NavigationalStatus must be between 0 and 15']
    ].freeze

    def self.validate_ranges!(**values)
      RANGE_RULES.each do |key, min, max, message|
        assert_between!(values.fetch(key), min, max, message)
      end

      heading = values.fetch(:heading)
      assert_predicate!(
        heading.between?(0, 359) || heading == 511,
        heading,
        'TrueHeading must be between 0 and 359 (or 511 for unavailable)'
      )
    end

    def self.assert_between!(value, min, max, error_message)
      return if value.between?(min, max)

      raise InvalidFieldError, "#{error_message} (got: #{value.inspect})"
    end

    def self.assert_predicate!(valid, value, error_message)
      return if valid

      raise InvalidFieldError, "#{error_message} (got: #{value.inspect})"
    end
  end
end
