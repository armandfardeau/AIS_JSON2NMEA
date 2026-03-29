# frozen_string_literal: true

module AisToNmea
  # Registry and builder for encoder implementations.
  class EncoderFactory
    @registry = {
      position_report: -> { AisToNmea::Encoders::PositionReport },
      base_station_report: -> { AisToNmea::Encoders::BaseStationReport },
      ship_static_data: -> { AisToNmea::Encoders::ShipStaticData },
      safety_broadcast_message: -> { AisToNmea::Encoders::SafetyBroadcastMessage }
    }

    @message_type_map = {
      1 => :position_report,
      2 => :position_report,
      3 => :position_report,
      4 => :base_station_report,
      5 => :ship_static_data,
      14 => :safety_broadcast_message
    }

    class << self
      def register(name, encoder_class)
        raise InvalidFieldError, 'Encoder class must implement .new' unless encoder_class.respond_to?(:new)

        @registry[name.to_sym] = encoder_class
      end

      def build(data:, encoder: nil)
        key = encoder
        encoder_klass = @registry[key]
        raise InvalidFieldError, "Unknown encoder: #{key}" unless encoder_klass

        # Resolve lambda if present (lazy-loaded encoder)
        encoder_class = encoder_klass.is_a?(Proc) ? encoder_klass.call : encoder_klass
        encoder_class.new(data: data)
      end

      def key_for_message_type(message_type)
        key = @message_type_map[message_type]
        raise UnsupportedMessageTypeError, "Unsupported MessageID: #{message_type}" if key.nil?

        key
      end

      def registered
        @registry.keys
      end
    end
  end
end
