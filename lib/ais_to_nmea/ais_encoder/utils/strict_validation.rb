# frozen_string_literal: true

module AisToNmea
  module AisEncoder
    module Utils
      # Strict field validation helpers for JSON payload encoders.
      module StrictValidation
        def self.missing_required_simple_fields(data, required_fields)
          required_fields.filter_map do |field|
            present, = Input.value_for_key(data, field)
            field unless present
          end
        end

        def self.missing_required_nested_fields(data, parent_key, required_keys)
          parent = nested_hash_or_nil(data, parent_key)
          return [parent_key] if parent.nil?

          required_keys.filter_map do |key|
            present, = Input.value_for_key(parent, key)
            "#{parent_key}.#{key}" unless present
          end
        end

        def self.nested_hash_or_nil(data, key)
          present, value = Input.value_for_key(data, key)
          return nil unless present
          return value if value.is_a?(Hash)

          nil
        end

        def self.raise_missing_fields!(context_name, missing_fields)
          return if missing_fields.empty?

          raise MissingFieldError,
                "Missing required field(s) for #{context_name}: #{missing_fields.join(', ')}"
        end

        def self.validate_required_true_flag!(data, context_name)
          present, raw = Input.value_for_key(data, 'Valid')
          raise MissingFieldError, "Missing required field(s) for #{context_name}: Valid" unless present

          valid = Input.normalize_boolean(raw, 'Valid')
          return if valid

          raise InvalidFieldError, "Valid must be true for #{context_name} encoding"
        end
      end
    end
  end
end
