module AisToNmea
  module MessageParts
    module ShipStaticData
      module Etas
        class Hour < Eta
          def extract
            extract_component('Hour', 24)
          end

          def validate!
            validate_component!(min: 0, max: 24, key: 'Hour')
          end

          def pack
            AisToNmea::AisEncoder::Utils::BitPacking.pack_uint(@value, 5)
          end
        end
      end
    end
  end
end
