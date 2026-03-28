# frozen_string_literal: true

module AisToNmea
  module AisEncoder
    module Utils
      # Input normalization helpers for reading AIS payload fields.
      module Input
        def self.required_int(value, key)
          raise MissingFieldError, "Missing required field: #{key}" if value.nil?

          Integer(value)
        rescue ArgumentError, TypeError
          raise InvalidFieldError, "Invalid integer value for #{key}"
        end

        def self.required_int_from(value, field_name:)
          raise MissingFieldError, "Missing required field: #{field_name}" if value.nil?

          Integer(value)
        rescue ArgumentError, TypeError
          raise InvalidFieldError, "Invalid integer value for #{field_name}"
        end

        def self.optional_int_from(value, field_name:, default:)
          return default if value.nil?

          Integer(value)
        rescue ArgumentError, TypeError
          raise InvalidFieldError, "Invalid integer value for #{field_name}"
        end

        def self.required_float(value, key)
          raise MissingFieldError, "Missing required field: #{key}" if value.nil?

          Float(value)
        rescue ArgumentError, TypeError
          raise InvalidFieldError, "Invalid numeric value for #{key}"
        end

        def self.required_float_from(value, field_name:)
          raise MissingFieldError, "Missing required field: #{field_name}" if value.nil?

          Float(value)
        rescue ArgumentError, TypeError
          raise InvalidFieldError, "Invalid numeric value for #{field_name}"
        end

        def self.optional_bool_from(value, field_name:, default:)
          return default if value.nil?

          normalize_boolean(value, field_name)
        end

        def self.normalize_boolean(value, field_name)
          return value if [true, false].include?(value)
          return true if [1, '1'].include?(value)
          return false if [0, '0'].include?(value)

          value_str = value.to_s.strip.downcase
          return true if value_str == 'true'
          return false if value_str == 'false'

          raise InvalidFieldError, "Invalid boolean value for #{field_name}"
        end
      end
    end
  end
end
