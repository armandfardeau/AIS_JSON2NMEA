# frozen_string_literal: true

module AisToNmea
  module Encoders
    module Mixins
      # Context helper methods for encoders, providing access to class-level metadata and mappings.
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
