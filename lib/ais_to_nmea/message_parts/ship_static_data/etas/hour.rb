# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module ShipStaticData
      module Etas
        # Encodes the ETA hour component.
        class Hour < Base
          normalize_value_as :integer

          def validate!
            return self if @value.between?(0, 24)

            raise InvalidFieldError, "ETA Hour must be between 0 and 24 (got: #{@value.inspect})"
          end

          def pack
            pack_uint(5)
          end
        end
      end
    end
  end
end
