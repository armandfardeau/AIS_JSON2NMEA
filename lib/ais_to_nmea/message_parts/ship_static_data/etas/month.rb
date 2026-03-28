# frozen_string_literal: true

module AisToNmea
  module MessageParts
    module ShipStaticData
      module Etas
        # Encodes the ETA month component.
        class Month < Eta
          def extract
            extract_component('Month', 0)
          end

          def validate!
            validate_component!(min: 0, max: 12, key: 'Month')
          end

          def pack
            AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(@value, 4)
          end
        end
      end
    end
  end
end
