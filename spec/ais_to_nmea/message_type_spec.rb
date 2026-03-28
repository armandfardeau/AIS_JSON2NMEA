# frozen_string_literal: true

require 'spec_helper'

describe AisToNmea::MessageType do
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
