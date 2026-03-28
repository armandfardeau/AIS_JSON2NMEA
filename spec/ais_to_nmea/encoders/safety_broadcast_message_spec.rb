# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AisToNmea::Encoders::SafetyBroadcastMessage do
  let(:valid_input) do
    {
      'MessageID' => 14,
      'RepeatIndicator' => 0,
      'UserID' => 123_456_789,
      'Valid' => true,
      'Spare' => 0,
      'Text' => 'SECURITE NAVIGATION'
    }
  end

  it 'is defined' do
    expect(described_class).not_to be_nil
  end

  it 'supports only AIS message type 14' do
    expect(described_class::MESSAGE_TYPES).to eq([14])
  end

  it 'declares the expected mapping keys' do
    expect(described_class::PARTS_MAPPING.keys).to eq(
      %i[message_id repeat_indicator mmsi spare text valid]
    )
  end

  it 'uses the expected source fields in the mapping' do
    expect(described_class::PARTS_MAPPING.transform_values { |map| map[:field] }).to eq(
      message_id: 'MessageID',
      repeat_indicator: 'RepeatIndicator',
      mmsi: 'UserID',
      spare: 'Spare',
      text: 'Text',
      valid: 'Valid'
    )
  end

  it 'delegates to encode_message when MessageID is supported' do
    encoder = described_class.new(data: valid_input)
    allow(encoder).to receive(:encode_message).and_return('!AIVDM,1,1,0,A,TEST,0*00')

    expect(encoder.encode).to eq('!AIVDM,1,1,0,A,TEST,0*00')
  end

  it 'accepts JSON string input' do
    encoder = described_class.new(data: JSON.generate(valid_input))
    allow(encoder).to receive(:encode_message).and_return('stubbed')

    expect(encoder.encode).to eq('stubbed')
  end

  it 'encodes end-to-end without stubbing' do
    output = described_class.new(data: valid_input).encode

    expect(output).to start_with('!AIVDM,')
    expect(output).to end_with("\n")
  end

  it 'raises UnsupportedMessageTypeError for unsupported MessageID' do
    encoder = described_class.new(data: valid_input.merge('MessageID' => 5))

    expect { encoder.encode }
      .to raise_error(AisToNmea::UnsupportedMessageTypeError, /MessageID must be one of 14/)
  end

  it 'raises InvalidJsonError for malformed JSON input' do
    expect { described_class.new(data: '{invalid json}') }
      .to raise_error(AisToNmea::InvalidJsonError, /Invalid JSON/)
  end

  it 'raises InvalidJsonError for unsupported input type' do
    expect { described_class.new(data: 123) }
      .to raise_error(AisToNmea::InvalidJsonError, /Input must be a JSON string or Hash/)
  end
end
