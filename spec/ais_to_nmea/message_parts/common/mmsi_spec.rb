# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AisToNmea::MessageParts::Common::Mmsi do
  it 'normalizes the input value' do
    expect(described_class.new('123456789').value).to eq(123_456_789)
  end

  it 'accepts a valid value' do
    part = described_class.new(123_456_789)
    expect(part.validate!).to eq(part)
  end

  it 'rejects an invalid value' do
    expect { described_class.new(-1).validate! }.to raise_error(AisToNmea::InvalidFieldError)
  end

  describe '#pack' do
    subject(:message_part) { described_class.new(123_456_789) }

    it 'packs value into AIS bits' do
      expect(message_part.pack.length).to eq(30)
    end
  end
end
