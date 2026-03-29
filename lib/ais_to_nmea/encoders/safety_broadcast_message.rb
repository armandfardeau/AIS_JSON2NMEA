# frozen_string_literal: true

module AisToNmea
  module Encoders
    # Encoder dedicated to AIS Safety Broadcast Message (type 14)
    class SafetyBroadcastMessage < Base
      MESSAGE_TYPES = [14].freeze
    end
  end
end
