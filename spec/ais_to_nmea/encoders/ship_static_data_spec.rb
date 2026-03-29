# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AisToNmea::Encoders::ShipStaticData do
  subject(:encoder) { described_class.new(data: ship_static_fixture['input']) }

  let(:fixtures) { fixture_json(message_type: :ship_static_data) }

  let(:ship_static_fixture) do
    fixtures.fetch('messages').find do |test_case|
      input = test_case['input']
      input.is_a?(Hash) && input['MessageID'] == 5
    end
  end

  def encode_with_new_instance(input)
    described_class.new(data: input).encode
  end

  it 'is defined' do
    expect(described_class).not_to be_nil
  end

  it 'loads a ship static data fixture (type 5)' do
    expect(ship_static_fixture).not_to be_nil
  end

  it 'loads parts mapping from YAML including nested sections', :aggregate_failures do
    mapping = encoder.parts_mapping

    expect(mapping.keys).to include(:eta, :dimension, :dte)
    expect(mapping[:message_id][:field]).to eq('MessageID')
    expect(mapping[:mmsi][:field]).to eq('UserID')
    expect(mapping[:dte][:field]).to eq('Dte')
    expect(mapping[:eta][:nested].keys).to eq(%i[month day hour minute])
    expect(mapping[:dimension][:nested].keys).to eq(%i[a b c d])
    expect(mapping[:eta][:nested][:month][:class]).to eq(AisToNmea::MessageParts::ShipStaticData::Etas::Month)
  end

  it 'accepts normalized ship static fixture input and delegates to encode_message' do
    output = encoder.encode

    expect(output).to start_with('!AIVDM,')
  end

  context 'with a json string' do
    let(:json_input) { JSON.generate(ship_static_fixture['input']) }
    let(:encoder) { described_class.new(data: json_input) }

    it 'accepts fixture input provided as a JSON string' do
      output = encoder.encode

      expect(output).to start_with('!AIVDM,')
    end
  end

  it 'encodes a valid fixture end-to-end without stubbing', :aggregate_failures do
    output = encode_with_new_instance(ship_static_fixture['input'])

    expect(output).to start_with('!AIVDM,')
    expect(output).to end_with("\n")
  end

  it 'rejects unsupported message type values for this encoder' do
    encoder = described_class.new(data: ship_static_fixture['input'].merge('MessageID' => 14))

    expect { encoder.encode }.to raise_error(AisToNmea::UnsupportedMessageTypeError)
  end

  it 'raises InvalidJsonError for malformed JSON input' do
    expect { described_class.new(data: '{invalid json}') }
      .to raise_error(AisToNmea::InvalidJsonError, /Invalid JSON/)
  end

  it 'raises InvalidJsonError for unsupported input type' do
    expect { described_class.new(data: 123) }
      .to raise_error(AisToNmea::InvalidJsonError, /Input must be a JSON string or Hash/)
  end

  it 'raises MissingFieldError when required nested fields are missing' do
    input = ship_static_fixture['input'].merge('Eta' => nil)

    expect { described_class.new(data: input).encode }
      .to raise_error(AisToNmea::MissingFieldError, /Missing required field\(s\) for ShipStaticData/)
  end
end
