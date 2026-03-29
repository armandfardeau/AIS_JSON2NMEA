# frozen_string_literal: true

module AisToNmea
  module Encoders
    module Mixins
      # Context helper methods for encoders, providing access to class-level metadata and mappings.
      module Context
        def context_name
          self.class.name.split('::').last
        end
      end
    end
  end
end
