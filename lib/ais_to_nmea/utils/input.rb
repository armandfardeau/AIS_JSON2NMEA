# frozen_string_literal: true

module AisToNmea
  module AisEncoder
    module Utils
      module Input
        def self.value_for_key(data, key)
          return [true, data[key]] if data.key?(key)

          symbol_key = key.to_sym
          return [true, data[symbol_key]] if data.key?(symbol_key)

          [false, nil]
        end

        def self.first_available(data, *keys)
          keys.each do |key|
            present, value = value_for_key(data, key)
            return [key, value] if present
          end

          [nil, nil]
        end

        def self.required_int(data, key)
          present, value = value_for_key(data, key)
          raise MissingFieldError, "Missing required field: #{key}" unless present

          Integer(value)
        rescue ArgumentError, TypeError
          raise InvalidFieldError, "Invalid integer value for #{key}"
        end

        def self.required_int_from(data, keys, field_name:)
          key, value = first_available(data, *keys)
          raise MissingFieldError, "Missing required field: #{field_name}" if key.nil?

          Integer(value)
        rescue ArgumentError, TypeError
          raise InvalidFieldError, "Invalid integer value for #{field_name}"
        end

        def self.optional_int_from(data, keys, field_name:, default:)
          key, value = first_available(data, *keys)
          return default if key.nil?

          Integer(value)
        rescue ArgumentError, TypeError
          raise InvalidFieldError, "Invalid integer value for #{field_name}"
        end

        def self.required_float(data, key)
          present, value = value_for_key(data, key)
          raise MissingFieldError, "Missing required field: #{key}" unless present

          Float(value)
        rescue ArgumentError, TypeError
          raise InvalidFieldError, "Invalid numeric value for #{key}"
        end

        def self.required_float_from(data, keys, field_name:)
          key, value = first_available(data, *keys)
          raise MissingFieldError, "Missing required field: #{field_name}" if key.nil?

          Float(value)
        rescue ArgumentError, TypeError
          raise InvalidFieldError, "Invalid numeric value for #{field_name}"
        end

        def self.optional_bool_from(data, keys, field_name:, default:)
          key, value = first_available(data, *keys)
          return default if key.nil?

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
