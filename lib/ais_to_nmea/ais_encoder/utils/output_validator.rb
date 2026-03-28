# frozen_string_literal: true

require 'nmea_plus'
require 'stringio'
require 'yaml'

module AisToNmea
  module AisEncoder
    module Utils
      # Utility class for validating output values before encoding.
      module OutputValidator
        VALIDATION_CONFIG_PATH = File.expand_path('../../config/validation_mapping.yml', __dir__).freeze
        DEFAULT_FLOAT_TOLERANCE = 1e-6

        TYPE_MAPPINGS = {
          1 => :position_report,
          2 => :position_report,
          3 => :position_report,
          5 => :ship_static_data,
          14 => :safety_broadcast_message
        }.freeze

        def validate!(data, output)
          decoded_message = decode_output(output)
          ais_payload = decoded_message.ais

          mapping_for(ais_payload.message_type).each do |field_name, rule|
            expected_value = resolve_path(data, field_name)
            actual_value = resolve_path(ais_payload, rule.fetch(:actual))

            next if values_match?(expected_value, actual_value, rule)

            raise InvalidFieldError,
                  "Validation failed for #{field_name}: expected #{expected_value.inspect}, got #{actual_value.inspect}"
          end

          true
        end

        def source_decoder(output)
          NMEAPlus::SourceDecoder.new(StringIO.new(output))
        end

        def mapping_for(message_id)
          type = TYPE_MAPPINGS[message_id]
          raise UnsupportedMessageTypeError, "No mapping defined for message type: #{message_id}" unless type

          validation_mappings.fetch(type) do
            raise UnsupportedMessageTypeError, "No validation mapping defined for message type: #{message_id}"
          end
        end

        def validation_mappings
          @validation_mappings ||= begin
            raw = YAML.safe_load(File.read(VALIDATION_CONFIG_PATH))
            normalize_validation_mappings(raw)
          rescue Errno::ENOENT => e
            raise InvalidFieldError, "Validation mapping file not found: #{e.message}"
          rescue Psych::SyntaxError => e
            raise InvalidFieldError, "Invalid validation mapping YAML: #{e.message}"
          end
        end

        def normalize_validation_mappings(mapping)
          unless mapping.is_a?(Hash)
            raise InvalidFieldError, "Invalid validation mapping structure: expected Hash, got #{mapping.class}"
          end

          mapping.each_with_object({}) do |(encoder_key, rules), normalized|
            unless rules.is_a?(Hash)
              raise InvalidFieldError, "Invalid validation mapping for #{encoder_key}: expected Hash, got #{rules.class}"
            end

            normalized[encoder_key.to_sym] = rules.each_with_object({}) do |(field_name, rule), fields|
              unless rule.is_a?(Hash) && rule['actual'].is_a?(String)
                raise InvalidFieldError,
                      "Invalid validation rule for #{encoder_key}.#{field_name}: expected an actual reader path"
              end

              fields[field_name.to_sym] = {
                actual: rule.fetch('actual'),
                comparator: (rule['comparator'] || 'exact').to_sym,
                tolerance: rule['tolerance']
              }
            end
          end
        end

        def decode_output(output)
          complete_message = nil
          source_decoder(output).each_complete_message { |message| complete_message = message }

          return complete_message if complete_message&.respond_to?(:ais) && complete_message.ais

          raise InvalidFieldError, 'Unable to decode encoder output for validation'
        rescue Racc::ParseError => e
          raise InvalidFieldError, "Unable to parse encoder output for validation: #{e.message}"
        end

        def resolve_path(root, path)
          path.to_s.split('.').reduce(root) do |value, segment|
            break nil if value.nil?

            unless value.respond_to?(segment)
              raise InvalidFieldError, "Validation reader not found: #{path}"
            end

            value.public_send(segment)
          end
        end

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
            boolean_like(expected) == boolean_like(actual)
          when :heading_sentinel
            heading_value(expected) == heading_value(actual)
          when :timestamp_sentinel
            timestamp_value(expected) == timestamp_value(actual)
          else
            raise InvalidFieldError, "Unknown validation comparator: #{comparator}"
          end
        end

        def float_values_match?(expected, actual, tolerance)
          return expected == actual if expected.nil? || actual.nil?

          (Float(expected) - Float(actual)).abs <= (tolerance || DEFAULT_FLOAT_TOLERANCE)
        rescue ArgumentError, TypeError
          false
        end

        def normalize_string(value)
          value.to_s.strip
        end

        def boolean_like(value)
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
          return 511 if value.nil?

          Integer(value)
        rescue ArgumentError, TypeError
          value
        end

        def timestamp_value(value)
          return 63 if value.nil?

          Integer(value)
        rescue ArgumentError, TypeError
          value
        end
      end
    end
  end
end
