module AisToNmea
  module MessageParts
    module SafetyBroadcastMessage
      class Text
        attr_reader :value

        def initialize(data = nil, value = nil)
          @data = data
          @value = value
        end

        def extract
          present, value = AisToNmea::AisEncoder::Utils::Input.value_for_key(@data, 'Text')
          @value = present ? value : nil
          self
        end

        def validate!
          self
        end

        def pack
          AisToNmea::AisEncoder::Utils::Text.encode_ais_text(@value, max_length: 156)
        end
      end
    end
  end
end
