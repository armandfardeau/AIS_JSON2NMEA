# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AisToNmea::EncoderFactory do
  describe '.key_for_message_type' do
    it 'maps supported AIS message ids to the registered encoder keys', :aggregate_failures do
      expect(described_class.key_for_message_type(1)).to eq(:position_report)
      expect(described_class.key_for_message_type(2)).to eq(:position_report)
      expect(described_class.key_for_message_type(3)).to eq(:position_report)
      expect(described_class.key_for_message_type(5)).to eq(:ship_static_data)
      expect(described_class.key_for_message_type(14)).to eq(:safety_broadcast_message)
    end

    it 'raises for unsupported AIS message ids' do
      expect { described_class.key_for_message_type(18) }
        .to raise_error(AisToNmea::UnsupportedMessageTypeError, /Unsupported MessageID/)
    end
  end

  describe '.build' do
    it 'builds the position report encoder for its registry key' do
      input = fixture_json(message_type: :position_report).fetch('messages').first.fetch('input')

      expect(described_class.build(data: input, encoder: :position_report))
        .to be_a(AisToNmea::Encoders::PositionReport)
    end

    it 'builds the ship static data encoder for its registry key' do
      input = fixture_json(message_type: :ship_static_data).fetch('messages').first.fetch('input')

      expect(described_class.build(data: input, encoder: :ship_static_data))
        .to be_a(AisToNmea::Encoders::ShipStaticData)
    end

    it 'builds the safety broadcast message encoder for its registry key' do
      input = fixture_json(message_type: :safety_broadcast_message).fetch('messages').first.fetch('input')

      expect(described_class.build(data: input, encoder: :safety_broadcast_message))
        .to be_a(AisToNmea::Encoders::SafetyBroadcastMessage)
    end

    it 'raises for unknown encoder keys' do
      expect { described_class.build(data: {}, encoder: :unknown) }
        .to raise_error(AisToNmea::InvalidFieldError, /Unknown encoder/)
    end
  end

  describe '.registered' do
    it 'includes the built-in encoder keys used for dispatch' do
      expect(described_class.registered).to include(
        :position_report,
        :ship_static_data,
        :safety_broadcast_message
      )
    end
  end
end
