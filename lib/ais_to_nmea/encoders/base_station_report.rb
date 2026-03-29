# frozen_string_literal: true

module AisToNmea
  module Encoders
    # Encoder dedicated to AIS Base Station Report messages (type 4)
    class BaseStationReport < Base
      MESSAGE_TYPES = [4].freeze

      def encode
        validate_message_type!
        StrictValidation.raise_missing_fields!(context_name: context_name, data: @data, mapping: parts_mapping)

        encoded_output = encode_message
        OutputValidator.validate!(context_name: context_name, data: @data, encoded_output: encoded_output)
        encoded_output
      end
    end
  end
end
