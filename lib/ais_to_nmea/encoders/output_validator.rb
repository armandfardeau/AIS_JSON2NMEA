# frozen_string_literal: true

require 'nmea_plus'
require 'stringio'
require 'yaml'

module AisToNmea
  module Encoders
    # Utility class for validating output values before encoding.
    class OutputValidator
      include Mixins::OutputValidationMatchers

      VALIDATION_CONFIG_PATH = File.expand_path('../config/validation_mapping.yml', __dir__).freeze

      TYPE_MAPPINGS = {
        1 => :position_report,
        2 => :position_report,
        3 => :position_report,
        4 => :base_station_report,
        5 => :ship_static_data,
        14 => :safety_broadcast_message
      }.freeze

      def self.validate!(data, output)
        new.validate!(data, output)
      end

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
          raw = YAML.safe_load_file(VALIDATION_CONFIG_PATH)
          normalize_validation_mappings(raw)
        rescue Errno::ENOENT => e
          raise InvalidFieldError, "Validation mapping file not found: #{e.message}"
        rescue Psych::SyntaxError => e
          raise InvalidFieldError, "Invalid validation mapping YAML: #{e.message}"
        end
      end

      # rubocop:disable Metrics/AbcSize
      def normalize_validation_mappings(mapping)
        ensure_hash!(mapping)

        mapping.each_with_object({}) do |(encoder_key, rules), normalized|
          ensure_hash!(rules)

          normalized[encoder_key.to_sym] = rules.each_with_object({}) do |(field_name, rule), fields|
            ensure_hash!(rule)
            ensure_rule!(rule['actual'], "Missing 'actual' for #{encoder_key}.#{field_name}")

            fields[field_name.to_sym] = {
              actual: rule.fetch('actual'),
              comparator: (rule['comparator'] || 'exact').to_sym,
              tolerance: rule['tolerance']
            }
          end
        end
      end
      # rubocop:enable Metrics/AbcSize

      def ensure_hash!(value)
        return if value.is_a?(Hash)

        raise InvalidFieldError, "Invalid structure: expected Hash, got #{value.class}"
      end

      def ensure_rule!(rule, error_message)
        return if rule.is_a?(String)

        raise InvalidFieldError, "#{error_message}: expected String, got #{rule.class}"
      end

      def decode_output(output)
        complete_message = nil
        source_decoder(output).each_complete_message { |message| complete_message = message }

        if complete_message.nil?
          parsed_message = NMEAPlus::Decoder.new.parse(output)
          complete_message = parsed_message if parsed_message.respond_to?(:ais) && parsed_message.ais
        end

        return complete_message if complete_message.respond_to?(:ais) && complete_message.ais

        raise InvalidFieldError, 'Unable to decode encoder output for validation'
      rescue Racc::ParseError => e
        raise InvalidFieldError, "Unable to parse encoder output for validation: #{e.message}"
      end

      def resolve_path(root, path)
        path.to_s.split('.').reduce(root) do |value, segment|
          break nil if value.nil?

          raise InvalidFieldError, "Validation reader not found: #{path}" unless value.respond_to?(segment)

          value.public_send(segment)
        end
      end
    end
  end
end
