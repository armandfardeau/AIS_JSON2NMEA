# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AisToNmea::MessageParts::PositionReport::Timestamp do
  it 'normalizes the input value' do
    expect(described_class.new('59').value).to eq(59)
  end

  it 'accepts a valid value' do
    part = described_class.new(59)
    expect(part.validate!).to eq(part)
  end

  it 'rejects an invalid value' do
    expect { described_class.new(64).validate! }.to raise_error(AisToNmea::InvalidFieldError)
  end

  describe '#pack' do
    subject(:message_part) { described_class.new(59) }

    it 'packs value into AIS bits' do
      expect(message_part.pack.length).to eq(6)
    end
  end
end
