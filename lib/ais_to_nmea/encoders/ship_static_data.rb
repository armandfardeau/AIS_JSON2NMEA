# frozen_string_literal: true

module AisToNmea
  module Encoders
    # Encoder dedicated to AIS Ship Static Data (type 5)
    class ShipStaticData < Base
      MESSAGE_TYPES = [5].freeze
    end
  end
end
