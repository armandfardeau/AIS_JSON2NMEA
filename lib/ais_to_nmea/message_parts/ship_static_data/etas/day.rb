# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module ShipStaticData
      module Etas
        # Encodes the ETA day component.
        class Day < Eta
          def extract
            extract_component('Day', 0)
          end

          def validate!
            validate_component!(min: 0, max: 31, key: 'Day')
          end

          def pack
            AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(@value, 5)
          end
        end
      end
    end
  end
end
