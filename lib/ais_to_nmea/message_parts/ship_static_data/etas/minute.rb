module AisToNmea
  module MessageParts
    module ShipStaticData
      module Etas
        class Minute < Eta
          def self.extract(data)
            extract_component(data, 'Minute', 60)
          end
        end
      end
    end
  end
end
