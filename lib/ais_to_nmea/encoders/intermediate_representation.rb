# frozen_string_literal: true

module AisToNmea
  module Encoders
    # Builds a struct-based intermediate representation from parsed input and encoder mapping.
    class IntermediateRepresentation
      def self.build(data, mapping)
        new(data, mapping).build
      end

      def initialize(data, mapping)
        @data = data
        @mapping = mapping
      end

      def build
        source_data = @data.is_a?(Hash) ? @data : {}

        values = @mapping.values.map do |part_mapping|
          if part_mapping[:nested]
            self.class.build(source_data[part_mapping[:field]], part_mapping[:nested])
          else
            source_data[part_mapping[:field]]
          end
        end

        Struct.new(*@mapping.keys).new(*values)
      end
    end
  end
end
