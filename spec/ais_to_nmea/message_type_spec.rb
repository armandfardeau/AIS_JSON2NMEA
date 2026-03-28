# frozen_string_literal: true

require 'spec_helper'

describe AisToNmea::MessageType do
  describe '.parse_input' do
    it 'returns hash unchanged when input is already a hash' do
      input = { 'MessageID' => 1 }

      expect(described_class.parse_input(input)).to eq(input)
    end

    it 'parses valid JSON string input' do
      parsed = described_class.parse_input('{"MessageID":14}')

      expect(parsed).to eq('MessageID' => 14)
    end

    it 'raises invalid json error for malformed JSON' do
      expect { described_class.parse_input('{bad-json}') }
        .to raise_error(AisToNmea::InvalidJsonError, /Invalid JSON/)
    end

    it 'raises invalid json error for unsupported input type' do
      expect { described_class.parse_input(123) }
        .to raise_error(AisToNmea::InvalidJsonError, /JSON string or Hash/)
    end
  end

  describe '.detect' do
    it 'detects direct MessageID from hash' do
      expect(described_class.detect('MessageID' => 1)).to eq(1)
    end

    it 'detects direct MessageID from symbol key' do
      expect(described_class.detect(MessageID: 2)).to eq(2)
    end

    it 'detects nested Message.MessageID' do
      input = { 'Message' => { 'MessageID' => 14 } }

      expect(described_class.detect(input)).to eq(14)
    end

    it 'supports JSON string input' do
      expect(described_class.detect('{"MessageID":5}')).to eq(5)
    end

    it 'raises missing field when MessageID cannot be found' do
      expect { described_class.detect('UserID' => 123_456_789) }
        .to raise_error(AisToNmea::MissingFieldError, /MessageID/)
    end

    it 'raises unsupported message type for non supported ids' do
      expect { described_class.detect('MessageID' => 18) }
        .to raise_error(AisToNmea::UnsupportedMessageTypeError, /must be one of/)
    end
  end
end
