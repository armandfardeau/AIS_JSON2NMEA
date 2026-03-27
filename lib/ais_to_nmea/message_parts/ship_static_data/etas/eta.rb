module AisToNmea
  module MessageParts
    module ShipStaticData
      module Etas
        class Eta
          class << self
            private

            def extract_component(data, key, default)
              eta = eta_payload(data)
              value = if eta.key?(key)
                        eta[key]
                      elsif eta.key?(key.to_sym)
                        eta[key.to_sym]
                      else
                        default
                      end

              Integer(value)
            rescue ArgumentError, TypeError
              raise InvalidFieldError, "Invalid integer value for Eta.#{key}"
            end

            def eta_payload(data)
              if data.key?('Eta')
                data['Eta'] || {}
              elsif data.key?(:Eta)
                data[:Eta] || {}
              else
                {}
              end
            end
          end
        end
      end
    end
  end
end
