module AisToNmea
  module AisEncoder
    module Utils
      module Validation
        def self.validate_ranges!(lat, lon, sog, cog, heading, nav_status)
          raise InvalidFieldError, "Latitude must be between -90 and 90 (got: #{lat.inspect})" unless lat.between?(-90.0, 90.0)
          raise InvalidFieldError, "Longitude must be between -180 and 180 (got: #{lon.inspect})" unless lon.between?(-180.0, 180.0)
          raise InvalidFieldError, "Sog/SpeedOverGround must be between 0 and 102.2 (got: #{sog.inspect})" unless sog.between?(0.0, 102.2)
          raise InvalidFieldError, "Cog/CourseOverGround must be between 0 and 359.9 (got: #{cog.inspect})" unless cog.between?(0.0, 359.9)
          valid_heading = heading.between?(0, 359) || heading == 511
          raise InvalidFieldError, "TrueHeading must be between 0 and 359 (or 511 for unavailable) (got: #{heading.inspect})" unless valid_heading
          raise InvalidFieldError, "NavigationStatus/NavigationalStatus must be between 0 and 15 (got: #{nav_status.inspect})" unless nav_status.between?(0, 15)
        end
      end
    end
  end
end
