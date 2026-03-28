# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AisToNmea::Encoders::ShipStaticData do
  let(:fixtures) { fixture_json('sample_ais_messages.json') }

  let(:ship_static_fixture) do
    fixtures.fetch('messages').find do |test_case|
      input = test_case['input']
      input.is_a?(Hash) && input['MessageID'] == 5
    end
  end

  def normalize_ship_static_data_input(input)
    return input unless input.is_a?(Hash)

    normalized = input.dup

    normalized['AISVersion'] = normalized.delete('AisVersion') if normalized.key?('AisVersion')
    normalized['IMONumber'] = normalized.delete('ImoNumber') if normalized.key?('ImoNumber')
    normalized['ShipType'] = normalized.delete('Type') if normalized.key?('Type')
    normalized['DTE'] = normalized.delete('Dte') if normalized.key?('Dte')

    normalized
  end

  def encode_with_new_instance(input)
    described_class.new(data: normalize_ship_static_data_input(input)).encode
  end

  it 'is defined' do
    expect(described_class).not_to be_nil
  end

  it 'loads a ship static data fixture (type 5)' do
    expect(ship_static_fixture).not_to be_nil
  end

  it 'loads parts mapping from YAML including nested sections' do
    mapping = described_class.parts_mapping

    expect(mapping.keys).to include(:eta, :dimension, :valid)
    expect(mapping[:message_id][:field]).to eq('MessageID')
    expect(mapping[:mmsi][:field]).to eq('UserID')
    expect(mapping[:valid][:field]).to eq('Valid')
    expect(mapping[:eta][:nested].keys).to eq(%i[month day hour minute])
    expect(mapping[:dimension][:nested].keys).to eq(%i[a b c d])
    expect(mapping[:eta][:nested][:month][:class]).to eq(AisToNmea::MessageParts::ShipStaticData::Etas::Month)
  end

  it 'accepts normalized ship static fixture input and delegates to encode_message' do
    encoder = described_class.new(data: normalize_ship_static_data_input(ship_static_fixture['input']))
    allow(encoder).to receive(:encode_message).and_return('stubbed')

    expect(encoder.encode).to eq('stubbed')
  end

  it 'accepts fixture input provided as a JSON string' do
    json_input = JSON.generate(normalize_ship_static_data_input(ship_static_fixture['input']))
    encoder = described_class.new(data: json_input)
    allow(encoder).to receive(:encode_message).and_return('stubbed')

    expect(encoder.encode).to eq('stubbed')
  end

  it 'encodes a valid fixture end-to-end without stubbing' do
    output = encode_with_new_instance(ship_static_fixture['input'])

    expect(output).to start_with('!AIVDM,')
    expect(output).to end_with("\n")
  end

  it 'rejects unsupported message type values for this encoder' do
    encoder = described_class.new(data: normalize_ship_static_data_input(ship_static_fixture['input']).merge('MessageID' => 14))

    expect { encoder.encode }.to raise_error(AisToNmea::UnsupportedMessageTypeError)
  end
end
