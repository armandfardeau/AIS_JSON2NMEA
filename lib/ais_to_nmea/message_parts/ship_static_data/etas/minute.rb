module AisToNmea
  module MessageParts
    module ShipStaticData
      module Etas
        class Minute < Eta
          def extract
            extract_component('Minute', 60)
          end

          def validate!
            validate_component!(min: 0, max: 60, key: 'Minute')
          end

          def pack
            AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(@value, 6)
          end
        end
      end
    end
  end
end
