# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AisToNmea::MessageParts::Common::MessageId do
  it 'normalizes the input value' do
    expect(described_class.new('7').value).to eq(7)
  end

  it 'accepts a valid value' do
    part = described_class.new(7)
    expect(part.validate!).to eq(part)
  end

  it 'rejects an invalid value' do
    expect { described_class.new(64).validate! }.to raise_error(AisToNmea::InvalidFieldError)
  end

  describe '#pack' do
    subject(:message_part) { described_class.new(7) }

    it 'packs value into AIS bits' do
      expect(message_part.pack.length).to eq(6)
    end
  end
end
