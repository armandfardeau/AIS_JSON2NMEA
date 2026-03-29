# frozen_string_literal: true

module AisToNmea
  module MessageParts
    # Base class for AIS message parts, providing common normalization and validation logic.
    class Base
      include AisToNmea::MessageParts::Mixins::BitPacking
      include AisToNmea::MessageParts::Mixins::Text

      VALUE_NORMALIZER = {
        integer: ->(value) { Integer(value) unless value.nil? },
        float: ->(value) { Float(value) unless value.nil? },
        string: ->(value) { value.to_s unless value.nil? },
        bool: lambda { |value|
          unless value.nil?
            value.nil? ? 0 : 1
          end
        },
        default: ->(value) { value }
      }.freeze
      attr_reader :value

      def initialize(value = nil)
        @value = self.class.value_normalizer.call(value)
      end

      def validate!
        self
      end

      class << self
        def normalize_value_with(normalizer)
          @value_normalizer = if normalizer.respond_to?(:call)
                                normalizer
                              else
                                VALUE_NORMALIZER.fetch(normalizer) do
                                  raise ArgumentError, "Unknown normalizer: #{normalizer.inspect}"
                                end
                              end
        end

        def normalize_value_as(type)
          normalize_value_with(type)
        end

        def value_normalizer
          @value_normalizer ||= VALUE_NORMALIZER[:default]
        end
      end

      private

      def normalize_value
        @value
      end
    end
  end
end
