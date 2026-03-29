# frozen_string_literal: true

module AisToNmea
  module Encoders
    module Mixins
      # Matchers for comparing encoded NMEA output against expected values,
      # with support for multiple comparison rules.
      module OutputValidationMatchers
        DEFAULT_FLOAT_TOLERANCE = 1e-6
        HEADING_UNAVAILABLE = 511
        TIMESTAMP_UNAVAILABLE = 63

        # rubocop:disable Metrics/MethodLength
        def values_match?(expected, actual, rule)
          comparator = rule.fetch(:comparator)

          case comparator
          when :exact
            expected == actual
          when :float_tolerance
            float_values_match?(expected, actual, rule[:tolerance])
          when :normalized_string
            normalize_string(expected) == normalize_string(actual)
          when :bool_int
            boolean_like?(expected) == boolean_like?(actual)
          when :heading_sentinel
            heading_value(expected) == heading_value(actual)
          when :timestamp_sentinel
            timestamp_value(expected) == timestamp_value(actual)
          else
            raise InvalidFieldError, "Unknown validation comparator: #{comparator}"
          end
        end
        # rubocop:enable Metrics/MethodLength

        def float_values_match?(expected, actual, tolerance)
          return expected == actual if expected.nil? || actual.nil?

          (Float(expected) - Float(actual)).abs <= (tolerance || DEFAULT_FLOAT_TOLERANCE)
        rescue ArgumentError, TypeError
          false
        end

        def normalize_string(value)
          value.to_s.strip
        end

        def boolean_like?(value)
          case value
          when true, 1, '1', 'true', 'TRUE'
            true
          when false, 0, '0', 'false', 'FALSE', nil
            false
          else
            !!value
          end
        end

        def heading_value(value)
          return HEADING_UNAVAILABLE if value.nil?

          Integer(value)
        rescue ArgumentError, TypeError
          value
        end

        def timestamp_value(value)
          return TIMESTAMP_UNAVAILABLE if value.nil?

          Integer(value)
        rescue ArgumentError, TypeError
          value
        end
      end
    end
  end
end
