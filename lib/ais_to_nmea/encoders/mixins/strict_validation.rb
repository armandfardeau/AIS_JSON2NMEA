# frozen_string_literal: true

module AisToNmea
  module Encoders
    module Mixins
      # Strict field validation helpers for JSON payload encoders.
      module StrictValidation
        def missing_required_fields(data, mapping)
          mapping.map do |key, values|
            if values[:nested]
              missing_required_fields(data.send(key), values[:nested])
            else
              missing_required_field(data, key)
            end
          end.flatten.compact
        end

        def missing_required_field(data, field)
          data.send(field).nil? ? field : nil
        end

        def raise_missing_fields!(context_name = self.class.name.split('::').last, data = @data,
                                  mapping = self.class.parts_mapping)
          missing_fields = missing_required_fields(data, mapping)
          return if missing_fields.empty?

          raise MissingFieldError,
                "Missing required field(s) for #{context_name}: #{missing_fields.join(', ')}"
        end
      end
    end
  end
end
