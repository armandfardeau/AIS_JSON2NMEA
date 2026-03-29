# frozen_string_literal: true

module AisToNmea
  module Encoders
    # Encoder dedicated to AIS Base Station Report messages (type 4)
    class BaseStationReport < Base
      MESSAGE_TYPES = [4].freeze
    end
  end
end
