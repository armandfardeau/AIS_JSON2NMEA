# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AisToNmea::Encoders::BaseStationReport do
  subject(:encoder) { described_class.new(data: base_station_fixture['input']) }

  let(:fixtures) { fixture_json(message_type: :base_station_report) }

  let(:base_station_fixture) do
    fixtures.fetch('messages').find do |test_case|
      input = test_case['input']
      input.is_a?(Hash) && input['MessageID'] == 4
    end
  end

  def normalize_input(input)
    return input unless input.is_a?(Hash)

    normalized = input.dup

    if [true, false].include?(normalized['PositionAccuracy'])
      normalized['PositionAccuracy'] = normalized['PositionAccuracy'] ? 1 : 0
    end

    if [true, false].include?(normalized['Raim'])
      normalized['Raim'] = normalized['Raim'] ? 1 : 0
    end

    normalized
  end

  def encode_with_new_instance(input)
    described_class.new(data: normalize_input(input)).encode
  end

  it 'is defined' do
    expect(described_class).not_to be_nil
  end

  it 'supports only AIS message type 4' do
    expect(described_class::MESSAGE_TYPES).to eq([4])
  end

  it 'loads a base station fixture (type 4)' do
    expect(base_station_fixture).not_to be_nil
  end

  it 'loads parts mapping from YAML with expected keys and fields', :aggregate_failures do
    mapping = encoder.parts_mapping

    expect(mapping.keys).to eq(
      %i[message_id repeat_indicator mmsi utc_year utc_month utc_day utc_hour utc_minute utc_second
         position_accuracy lon lat fix_type long_range_enable spare raim communication_state]
    )

    expect(mapping[:message_id][:field]).to eq('MessageID')
    expect(mapping[:mmsi][:field]).to eq('UserID')
    expect(mapping[:utc_year][:field]).to eq('UtcYear')
    expect(mapping[:communication_state][:field]).to eq('CommunicationState')
    expect(mapping[:utc_year][:class]).to eq(AisToNmea::MessageParts::BaseStationReport::UtcYear)
  end

  it 'encodes valid fixture end-to-end without stubbing', :aggregate_failures do
    output = encode_with_new_instance(base_station_fixture['input'])

    expect(output).to start_with('!AIVDM,')
    expect(output).to end_with("\n")
  end

  it 'accepts fixture input provided as a JSON string' do
    encoder = described_class.new(data: JSON.generate(base_station_fixture['input']))

    output = encoder.encode

    expect(output).to start_with('!AIVDM,')
  end

  it 'rejects unsupported message type values for this encoder' do
    invalid_input = base_station_fixture['input'].merge('MessageID' => 5)

    expect { described_class.new(data: invalid_input).encode }
      .to raise_error(AisToNmea::UnsupportedMessageTypeError)
  end
end
