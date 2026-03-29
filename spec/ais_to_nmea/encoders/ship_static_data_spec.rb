# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable Layout/LineLength, RSpec/MultipleExpectations

RSpec.describe AisToNmea::Encoders::ShipStaticData do
  subject(:encoder) { described_class.new(data: normalize_ship_static_data_input(ship_static_fixture['input'])) }

  let(:fixtures) { fixture_json(message_type: :ship_static_data) }

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
    mapping = encoder.parts_mapping

    expect(mapping.keys).to include(:eta, :dimension, :dte)
    expect(mapping[:message_id][:field]).to eq('MessageID')
    expect(mapping[:mmsi][:field]).to eq('UserID')
    expect(mapping[:dte][:field]).to eq('DTE')
    expect(mapping[:eta][:nested].keys).to eq(%i[month day hour minute])
    expect(mapping[:dimension][:nested].keys).to eq(%i[a b c d])
    expect(mapping[:eta][:nested][:month][:class]).to eq(AisToNmea::MessageParts::ShipStaticData::Etas::Month)
  end

  it 'accepts normalized ship static fixture input and delegates to encode_message' do
    output = encoder.encode

    expect(output).to start_with('!AIVDM,')
  end

  context 'with a json string' do
    let(:json_input) { JSON.generate(normalize_ship_static_data_input(ship_static_fixture['input'])) }
    let(:encoder) { described_class.new(data: json_input) }

    it 'accepts fixture input provided as a JSON string' do
      output = encoder.encode

      expect(output).to start_with('!AIVDM,')
    end
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
# rubocop:enable Layout/LineLength, RSpec/MultipleExpectations
