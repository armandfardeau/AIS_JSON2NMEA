# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module ShipStaticData
      module Etas
        # Encodes the ETA minute component.
        class Minute < Base
          normalize_value_as :integer

          def validate!
            return self if @value.between?(0, 60)

            raise InvalidFieldError, "ETA Minute must be between 0 and 60 (got: #{@value.inspect})"
          end

          def pack
            pack_uint(6)
          end
        end
      end
    end
  end
end
