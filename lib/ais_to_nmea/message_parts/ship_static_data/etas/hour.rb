module AisToNmea
  module MessageParts
    module ShipStaticData
      module Etas
        class Hour < Eta
          def self.extract(data)
            extract_component(data, 'Hour', 24)
          end
        end
      end
    end
  end
end
