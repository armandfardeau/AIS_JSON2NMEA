# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module ShipStaticData
      module Etas
        # Encodes the ETA day component.
        class Day < Base
          normalize_value_as :integer

          def validate!
            return self if @value.between?(0, 31)

            raise InvalidFieldError, "ETA Day must be between 0 and 31 (got: #{@value.inspect})"
          end

          def pack
            AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(@value, 5)
          end
        end
      end
    end
  end
end
