# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module ShipStaticData
      module Etas
        # Base class for individual ETA components.
        class Eta
          attr_reader :value

          def initialize(data = nil, value = nil)
            @data = data
            @value = value
          end

          private

          def extract_component(key, default)
            @value = Integer(component_value(key, default))
            self
          rescue ArgumentError, TypeError
            raise InvalidFieldError, "Invalid integer value for Eta.#{key}"
          end

          def eta_payload
            if @data.key?('Eta')
              @data['Eta'] || {}
            elsif @data.key?(:Eta)
              @data[:Eta] || {}
            else
              {}
            end
          end

          def validate_component!(min:, max:, key:)
            return self if @value.between?(min, max)

            raise InvalidFieldError, "Eta.#{key} must be between #{min} and #{max}"
          end

          def component_value(key, default)
            eta = eta_payload
            return eta[key] if eta.key?(key)
            return eta[key.to_sym] if eta.key?(key.to_sym)

            default
          end
        end
      end
    end
  end
end
