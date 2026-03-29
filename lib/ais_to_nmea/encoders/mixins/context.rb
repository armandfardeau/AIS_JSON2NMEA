# frozen_string_literal: true

module AisToNmea
  module Encoders
    module Mixins
      module Context
        def context_name
          self.class.name.split('::').last
        end

        def context_mapping
          self.class.parts_mapping
        end

        def context_mapping_message_types
          self.class::MESSAGE_TYPES
        end
      end
    end
  end
end
