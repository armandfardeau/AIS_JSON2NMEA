module AisToNmea
  module MessageParts
    module ShipStaticData
      module Etas
        class Eta
          attr_reader :value

          def initialize(data = nil, value = nil)
            @data = data
            @value = value
          end

          private

          def extract_component(key, default)
            eta = eta_payload
            component = if eta.key?(key)
                          eta[key]
                        elsif eta.key?(key.to_sym)
                          eta[key.to_sym]
                        else
                          default
                        end

            @value = Integer(component)
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
        end
      end
    end
  end
end
