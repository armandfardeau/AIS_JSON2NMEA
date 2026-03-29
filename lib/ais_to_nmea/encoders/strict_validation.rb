# frozen_string_literal: true

module AisToNmea
  module Encoders
    # Strict field validation for encoder intermediate representations.
    class StrictValidation
      def self.missing_required_fields(data, mapping)
        new(data, mapping).missing_required_fields
      end

      def self.raise_missing_fields!(context_name:, data:, mapping:)
        missing_fields = missing_required_fields(data, mapping)
        return if missing_fields.empty?

        raise MissingFieldError,
              "Missing required field(s) for #{context_name}: #{missing_fields.join(', ')}"
      end

      def initialize(data, mapping)
        @data = data
        @mapping = mapping
      end

      def missing_required_fields
        @mapping.flat_map do |key, values|
          if values[:nested]
            self.class.missing_required_fields(@data.public_send(key), values[:nested])
          else
            missing_required_field(key)
          end
        end.compact
      end

      private

      def missing_required_field(field)
        @data.public_send(field).nil? ? field : nil
      end
    end
  end
end
