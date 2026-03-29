# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AisToNmea::Encoder do
  let(:message_fixtures) do
    {
      position_report: {
        input: fixture_json(message_type: :position_report).fetch('messages').first.fetch('input'),
        encoder_class: AisToNmea::Encoders::PositionReport
      },
      ship_static_data: {
        input: fixture_json(message_type: :ship_static_data).fetch('messages').first.fetch('input'),
        encoder_class: AisToNmea::Encoders::ShipStaticData
      },
      safety_broadcast_message: {
        input: fixture_json(message_type: :safety_broadcast_message).fetch('messages').first.fetch('input'),
        encoder_class: AisToNmea::Encoders::SafetyBroadcastMessage
      }
    }
  end

  describe '#encode' do
    it 'dispatches supported position report messages to the matching encoder' do
      fixture = message_fixtures.fetch(:position_report)
      expected_nmea = fixture.fetch(:encoder_class).new(data: fixture.fetch(:input)).encode

      expect(described_class.new(data: fixture.fetch(:input)).encode).to eq(expected_nmea)
    end

    it 'dispatches supported ship static data messages to the matching encoder' do
      fixture = message_fixtures.fetch(:ship_static_data)
      expected_nmea = fixture.fetch(:encoder_class).new(data: fixture.fetch(:input)).encode

      expect(described_class.new(data: fixture.fetch(:input)).encode).to eq(expected_nmea)
    end

    it 'dispatches supported safety broadcast messages to the matching encoder' do
      fixture = message_fixtures.fetch(:safety_broadcast_message)
      expected_nmea = fixture.fetch(:encoder_class).new(data: fixture.fetch(:input)).encode

      expect(described_class.new(data: fixture.fetch(:input)).encode).to eq(expected_nmea)
    end

    it 'passes through unsupported message type errors' do
      expect { described_class.new(data: { 'MessageID' => 99 }).encode }
        .to raise_error(AisToNmea::UnsupportedMessageTypeError)
    end

    it 'wraps unexpected internal errors as EncodingFailureError' do
      allow(AisToNmea::MessageType).to receive(:detect).and_return(1)
      allow(AisToNmea::EncoderFactory).to receive(:build).and_raise(StandardError, 'boom')

      expect { described_class.new(data: { 'MessageID' => 1 }).encode }
        .to raise_error(AisToNmea::EncodingFailureError, 'boom')
    end
  end

  describe '.to_nmea' do
    it 'uses the generic encoder path for supported message types' do
      message_fixtures.each_value do |fixture|
        expected_nmea = described_class.new(data: fixture.fetch(:input)).encode

        expect(AisToNmea.to_nmea(fixture.fetch(:input))).to eq(expected_nmea)
      end
    end
  end
end
