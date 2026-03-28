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

  context 'with valid fixtures' do
    it 'encodes all valid position report fixtures to AIVDM sentences' do
      position_report_messages.each do |test_case|
        result = encode_with_new_instance(test_case['input'])
        expect(result).to start_with('!AIVDM'), "fixture failed: #{test_case['name']}"
        expect(result).to match(/\*[0-9A-F]{2}$/), "fixture failed: #{test_case['name']}"
      end
    end

    it 'encodes valid fixtures provided as JSON strings' do
      position_report_messages.each do |test_case|
        json_input = JSON.generate(test_case['input'])
        result = encode_with_new_instance(json_input)
        expect(result).to start_with('!AIVDM'), "fixture failed: #{test_case['name']}"
      end
    end
  end

  context 'with invalid fixtures' do
    it 'raises the expected error type for each fixture' do
      position_report_error_cases.each do |test_case|
        expected_error = Object.const_get("AisToNmea::#{test_case['error_type']}")

        expect do
          encode_with_new_instance(test_case['input'])
        end.to raise_error(expected_error), "fixture failed: #{test_case['name']}"
      end
    end
  end
end
