# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AisToNmea::Encoders::PositionReport do
  let(:fixtures) { fixture_json('sample_ais_messages.json') }
  let(:message_ids) { [1, 2, 3] }

  let(:position_report_messages) do
    fixtures.fetch('messages').select do |test_case|
      input = test_case['input']
      input.is_a?(Hash) && message_ids.include?(input['MessageID'])
    end
  end

  let(:position_report_error_cases) do
    fixtures.fetch('error_cases').select do |test_case|
      input = test_case['input']
      message_id = input.is_a?(Hash) ? input['MessageID'] : nil
      message_id.nil? || message_ids.include?(message_id)
    end
  end

  def normalize_position_report_input(input)
    return input unless input.is_a?(Hash)

    normalized = input.dup

    normalized['SpeedOverGround'] = normalized.delete('Sog') if normalized.key?('Sog')
    normalized['CourseOverGround'] = normalized.delete('Cog') if normalized.key?('Cog')
    normalized['RadioStatus'] = normalized.delete('CommunicationState') if normalized.key?('CommunicationState')

    if [true, false].include?(normalized['PositionAccuracy'])
      normalized['PositionAccuracy'] = normalized['PositionAccuracy'] ? 1 : 0
    end

    if [true, false].include?(normalized['Raim'])
      normalized['Raim'] = normalized['Raim'] ? 1 : 0
    end

    normalized
  end

  def encode_with_new_instance(input)
    described_class.new(data: normalize_position_report_input(input)).encode
  end

  it 'is defined' do
    expect(described_class).not_to be_nil
  end

  it 'loads position report fixtures' do
    expect(position_report_messages).not_to be_empty
    expect(position_report_error_cases).not_to be_empty
  end

  it 'loads parts mapping from YAML with expected keys and fields' do
    mapping = described_class.parts_mapping

    expect(mapping.keys).to eq(
      %i[message_id repeat_indicator mmsi nav_status rot sog position_accuracy lon lat cog heading timestamp maneuver spare raim radio_status]
    )
    expect(mapping.transform_values { |map| map[:field] }).to include(
      message_id: 'MessageID',
      mmsi: 'UserID',
      nav_status: 'NavigationalStatus',
      sog: 'SpeedOverGround',
      cog: 'CourseOverGround'
    )
    expect(mapping[:message_id][:class]).to eq(AisToNmea::MessageParts::Common::MessageId)
  end

  context 'with valid fixtures' do
    it 'contains only supported message types in fixtures' do
      position_report_messages.each do |test_case|
        message_id = test_case.fetch('input').fetch('MessageID')
        expect(described_class::MESSAGE_TYPES).to include(message_id), "fixture failed: #{test_case['name']}"
      end
    end

    it 'calls #encode_message for each valid fixture when message type is supported' do
      position_report_messages.each do |test_case|
        encoder = described_class.new(data: normalize_position_report_input(test_case['input']))
        allow(encoder).to receive(:encode_message).and_return('stubbed')

        expect(encoder.encode).to eq('stubbed'), "fixture failed: #{test_case['name']}"
      end
    end

    it 'encodes valid fixtures end-to-end without stubbing' do
      position_report_messages.each do |test_case|
        output = encode_with_new_instance(test_case['input'])

        expect(output).to start_with('!AIVDM,')
        expect(output).to end_with("\n")
      end
    end
  end

  context 'with invalid fixtures' do
    it 'maps all declared fixture error types to existing AisToNmea errors' do
      position_report_error_cases.each do |test_case|
        expect { Object.const_get("AisToNmea::#{test_case['error_type']}") }
          .not_to raise_error, "fixture failed: #{test_case['name']}"
      end
    end

    it 'raises UnsupportedMessageTypeError for unsupported MessageID fixture' do
      test_case = fixtures.fetch('error_cases').find { |tc| tc['name'] == 'Invalid MessageID (4)' }

      expect(test_case).not_to be_nil
      expect do
        encode_with_new_instance(test_case.fetch('input'))
      end.to raise_error(AisToNmea::UnsupportedMessageTypeError)
    end

    it 'raises InvalidJsonError for invalid JSON string fixture' do
      test_case = fixtures.fetch('error_cases').find { |tc| tc['name'] == 'Invalid JSON string' }

      expect(test_case).not_to be_nil
      expect do
        encode_with_new_instance(test_case.fetch('input'))
      end.to raise_error(AisToNmea::InvalidJsonError)
    end
  end
end
