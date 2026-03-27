module AisToNmea
  module MessageParts
    module ShipStaticData
      module Etas
        class Day < Eta
          def self.extract(data)
            extract_component(data, 'Day', 0)
          end
        end
      end
    end
  end
end
