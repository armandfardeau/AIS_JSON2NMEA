# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module ShipStaticData
      module Etas
        # Encodes the ETA month component.
        class Month < Base
          normalize_value_as :integer
          def validate!
            return self if @value.between?(0, 12)

            raise InvalidFieldError, "ETA Month must be between 0 and 12 (got: #{@value.inspect})"
          end

          def pack
            pack_uint(4)
          end
        end
      end
    end
  end
end
