module AisToNmea
  class EncoderFactory
    @registry = {
      position_report: AisToNmea::PositionReportEncoder,
      safety_broadcast_message: AisToNmea::SafetyBroadcastMessageEncoder
    }

    @message_type_map = {
      1 => :position_report,
      2 => :position_report,
      3 => :position_report,
      14 => :safety_broadcast_message
    }

    class << self
      def register(name, encoder_class)
        unless encoder_class.respond_to?(:new)
          raise InvalidFieldError, 'Encoder class must implement .new'
        end

        @registry[name.to_sym] = encoder_class
      end

      def build(options = {})
        key = options.fetch(:encoder, :position_report).to_sym
        encoder_class = @registry[key]
        raise InvalidFieldError, "Unknown encoder: #{key}" unless encoder_class

        encoder_class.new
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