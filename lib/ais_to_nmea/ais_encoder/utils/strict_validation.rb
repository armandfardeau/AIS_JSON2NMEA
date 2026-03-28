# frozen_string_literal: true

module AisToNmea
  module AisEncoder
    module Utils
      # Strict field validation helpers for JSON payload encoders.
      module StrictValidation
        def self.missing_required_fields(data, mapping)
          mapping.map do |key, values|
            if values[:nested]
              missing_required_fields(data.send(key), values[:nested])
            else
              missing_required_field(data, key)
            end
          end.flatten.compact
        end

        def self.missing_required_field(data, field)
          data.send(field) ? nil : field
        end

        def self.raise_missing_fields!(context_name, data, mapping)
          missing_fields = missing_required_fields(data, mapping)
          return if missing_fields.empty?

          raise MissingFieldError,
                "Missing required field(s) for #{context_name}: #{missing_fields.join(', ')}"
        end

        def self.validate_required_true_flag!(value, field_name)
          raise MissingFieldError, "Missing required field(s) for #{field_name}: Valid" unless value

          valid = Input.normalize_boolean(value, 'Valid')
          return if valid

          raise InvalidFieldError, "Valid must be true for #{field_name} encoding"
        end
      end
    end
  end
end
