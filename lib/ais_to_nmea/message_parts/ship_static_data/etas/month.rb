module AisToNmea
  module MessageParts
    module ShipStaticData
      module Etas
        class Month < Eta
          def self.extract(data)
            extract_component(data, 'Month', 0)
          end
        end
      end
    end
  end
end
